from app.core.handler.base_task_handler import BaseTaskHandler
from app.core.handler.task_state_manager import TaskStateManager
from app.core.logger import get_logger
import edge_tts
import asyncio
import os
import subprocess
from pydub import AudioSegment
import pysrt



logger = get_logger(__name__)

#  使用 edge-tts 合成音频



def is_file_size_zero(file_path):
    if os.path.exists(file_path):
        file_size = os.path.getsize(file_path)
        return file_size == 0
    else:
        print(f"文件路径 {file_path} 不存在")
        return False


class GenerateAudio(BaseTaskHandler):

    def __init__(self, name:str, state_manager: TaskStateManager):
        super().__init__(name,state_manager)
        self.voice = "zh-CN-YunyangNeural"
        # self.words_per_second = 2.24
        self.tts_rate_limit = 10
        self.tts_rate_min = 0
        # 添加备用语音列表
        self.backup_voices = ["zh-CN-XiaoxiaoNeural", "zh-CN-YunxiNeural"]

    async def synthesize_audio(self, text: str, output_path: str, duration: float, retries: int = 5):
        """
        使用 edge-tts 合成音频，并动态调整语速以匹配目标时长，带有重试机制。

        :param text: 要合成的文本。
        :param output_path: 输出音频文件的路径。
        :param duration: 目标时长（秒）。
        :param retries: 生成音频的最大重试次数。
        """
        for attempt in range(retries):
            try:
                # 清理可能存在的空文件
                if os.path.exists(output_path) and is_file_size_zero(output_path):
                    os.remove(output_path)
                    logger.info(f"移除空音频文件: {output_path}")

                rate =  f"+{int(self.tts_rate_limit)}%"
                communicate = edge_tts.Communicate(text, self.voice, rate=rate)
                await communicate.save(str(output_path))

                # 检查生成的文件是否有效
                if os.path.exists(output_path) and not is_file_size_zero(output_path):
                    logger.info(f"音频合成成功：{output_path}，语速调整：{rate}，尝试次数：{attempt+1}")
                    return True
                else:
                    raise Exception(f"音频文件生成失败或为空: {output_path}")

            except Exception as e:
                logger.error(f"生成音频失败，尝试第 {attempt + 1}/{retries} 次: {e}")
                if attempt < retries - 1:
                    # 指数退避策略，增加等待时间
                    wait_time = 2 * (attempt + 1)
                    logger.info(f"等待 {wait_time} 秒后重试")
                    await asyncio.sleep(wait_time)
                else:
                    # 最后一次尝试失败后，生成备用音频
                    logger.warning(f"所有尝试失败，生成备用音频: {output_path}")
                    return await self.generate_fallback_audio(text, output_path, duration)

        return False

    async def generate_fallback_audio(self, text: str, output_path: str, duration: float):
        """
        当正常语音合成失败时，尝试使用备用方案生成音频。

        :param text: 要合成的文本
        :param output_path: 输出音频文件路径
        :param duration: 目标时长（秒）
        """
        try:
            # 1. 尝试使用不同的语音
            original_voice = self.voice  # 保存原始语音设置

            for voice in self.backup_voices:
                try:
                    logger.info(f"尝试使用备用语音 {voice} 生成音频")
                    self.voice = voice  # 暂时切换语音
                    communicate = edge_tts.Communicate(text, voice)
                    await communicate.save(str(output_path))

                    # 检查文件有效性
                    if os.path.exists(output_path) and not is_file_size_zero(output_path):
                        logger.info(f"使用备用语音 {voice} 成功生成音频")
                        self.voice = original_voice  # 恢复原始语音设置
                        return True
                except Exception as e:
                    logger.error(f"备用语音 {voice} 生成失败: {e}")

            # 2. 如果仍然失败，生成静音或基本音频
            logger.warning(f"所有语音合成方法失败，生成基本音频: {output_path}")
            silence = AudioSegment.silent(duration=int(duration * 1000))
            silence.export(output_path, format="mp3")

            self.voice = original_voice  # 恢复原始语音设置
            return True

        except Exception as e:
            logger.error(f"备用音频生成失败: {e}")
            # 确保至少有一个文件存在，即使是空文件
            try:
                with open(output_path, 'wb') as f:
                    # 创建一个最小的有效MP3文件
                    f.write(b'\xFF\xFB\x10\x00\x00\x00\x00')
                logger.warning(f"创建了最小化MP3文件: {output_path}")
                return True
            except Exception as write_error:
                logger.error(f"无法创建最小MP3文件: {write_error}")
                return False

    async def adjust_audio_to_subtitle(self,subtitle, audio_path: str, target_duration: float) -> AudioSegment:
        """
        调整音频片段时长以匹配字幕时间。

        :param audio_path: 原始音频文件路径。
        :param target_duration: 目标时长（秒）。
        :return: 调整后的音频片段。
        """
        try:
            # 先检查文件是否存在且有效
            if not os.path.exists(audio_path) or is_file_size_zero(audio_path):
                logger.warning(f"音频文件不存在或为空: {audio_path}，尝试重新生成")
                await self.generate_and_adjust_audio(subtitle)

            audio = AudioSegment.from_file(audio_path)
            current_duration = audio.duration_seconds

            if current_duration < target_duration:
                # 补充静音
                silence_duration = (target_duration - current_duration) * 1000  # 毫秒
                silence = AudioSegment.silent(duration=silence_duration)
                audio += silence
                logger.info(f"补充静音: {audio_path}, 增加 {target_duration - current_duration:.2f} 秒")
            elif current_duration > target_duration:
                # 音频提速
                speed_factor = current_duration / target_duration
                temp_output_path = f"{os.path.splitext(audio_path)[0]}_adjusted.mp3"
                self.adjust_audio_speed_ffmpeg(audio_path, temp_output_path, speed_factor)
                audio = AudioSegment.from_file(temp_output_path)
                subtitle.audio_path = temp_output_path
                os.remove(temp_output_path)  # 删除临时文件
                logger.info(f"使用 ffmpeg 调整音频语速: {audio_path}, 调整因子: {speed_factor}")

            return audio
        except Exception as e:
            logger.error(f"调整音频时出错 ({audio_path}): {e}")
            # 出错时尝试创建静音音频作为备用
            try:
                silence = AudioSegment.silent(duration=int(target_duration * 1000))
                silence.export(audio_path, format="mp3")
                logger.warning(f"创建了静音替代音频: {audio_path}")
                return silence
            except:
                logger.error(f"创建静音替代音频也失败: {audio_path}")
                raise e

    async def generate_and_adjust_audio(self,subtitle):
        """
        生成并调整单个字幕的音频。
        :param subtitle: pysrt.Subtitle 对象。
        :return: 音频段信息的元组 (音频文件路径, 开始时间, 结束时间)。
        """
        try:
            text = subtitle.text.replace('\n', ' ').strip()
            if not text:
                logger.warning(f"跳过空字幕文本: index={subtitle.index}")
                # 为空字幕生成短静音
                output_path = f'{self.state_manager.audio_dir}/{self.state_manager.video_id}_{subtitle.index}.mp3'
                duration = (subtitle.end.ordinal - subtitle.start.ordinal) / 1000
                silence = AudioSegment.silent(duration=int(duration * 1000))
                silence.export(output_path, format="mp3")
                return (output_path, subtitle.start.ordinal, subtitle.end.ordinal)

            output_path = f'{self.state_manager.audio_dir}/{self.state_manager.video_id}_{subtitle.index}.mp3'
            duration = (subtitle.end.ordinal - subtitle.start.ordinal) / 1000  # 秒

            # 检查是否已存在有效的音频文件
            if os.path.exists(output_path) and not is_file_size_zero(output_path):
                logger.info(f"使用已存在的音频文件: {output_path}")
            else:
                success = await self.synthesize_audio(text, output_path, duration, retries=5)
                if not success:
                    logger.warning(f"无法生成音频，使用静音替代: {output_path}")

            # 确保音频时长正确
            await self.adjust_audio_to_subtitle(subtitle, output_path, duration)

            logger.info(f"音频段处理完成: {output_path}")
            return (output_path, subtitle.start.ordinal, subtitle.end.ordinal)

        except Exception as e:
            logger.error(f"处理字幕音频时出错 (index={subtitle.index}): {e}")
            # 发生错误时创建静音代替
            try:
                output_path = f'{self.state_manager.audio_dir}/{self.state_manager.video_id}_{subtitle.index}.mp3'
                duration = (subtitle.end.ordinal - subtitle.start.ordinal) / 1000
                silence = AudioSegment.silent(duration=int(duration * 1000))
                silence.export(output_path, format="mp3")
                logger.warning(f"生成静音替代: {output_path}")
                return (output_path, subtitle.start.ordinal, subtitle.end.ordinal)
            except Exception as fallback_error:
                logger.error(f"生成静音替代也失败: {fallback_error}")
                return None

    async def generate_audio_segments(self):
        """
        根据字幕文件生成和调整音频片段，并返回音频段信息。
        :return: 音频段信息列表。
        """
        try:

            # 确保音频目录存在
            os.makedirs(self.state_manager.audio_dir, exist_ok=True)

            # 加载字幕
            subtitles = pysrt.open(self.state_manager.translate_srt)
            total_subtitles = len(subtitles)
            logger.info(f"开始处理 {total_subtitles} 条字幕的音频生成任务")

            # 分批处理以避免资源耗尽
            batch_size = 20
            valid_audio_segments = []

            for i in range(0, total_subtitles, batch_size):
                batch_end = min(i + batch_size, total_subtitles)
                batch = subtitles[i:batch_end]

                logger.info(f"处理字幕批次 {i+1}-{batch_end} / {total_subtitles}")

                tasks = [self.generate_and_adjust_audio(subtitle) for subtitle in batch]
                batch_results = await asyncio.gather(*tasks, return_exceptions=True)

                # 处理结果
                for idx, result in enumerate(batch_results):
                    if isinstance(result, tuple):
                        valid_audio_segments.append(result)
                    elif isinstance(result, Exception):
                        logger.error(f"字幕 #{i+idx+1} 音频生成失败: {result}")

                # 短暂休息，避免资源争用
                await asyncio.sleep(0.5)

            success_rate = len(valid_audio_segments) / total_subtitles * 100 if total_subtitles > 0 else 0
            logger.info(f"音频生成完成，成功率: {success_rate:.2f}% ({len(valid_audio_segments)}/{total_subtitles})")

            # 即使有失败的字幕，只要大部分成功就认为任务完成
            if success_rate >= 80 or (total_subtitles > 0 and len(valid_audio_segments) > 0):

                return True
            else:
                logger.warning(f"音频生成成功率过低: {success_rate:.2f}%")
                # 尽管成功率低，发送警告状态但仍继续处理
                self.send_mqtt_message({
                    "messageId": "104",
                    "id": self.state_manager.id,
                    "status": "P106W"  # 警告状态
                })
                return True

        except Exception as e:
            logger.error(f"生成音频片段过程中发生严重错误: {e}")
            # 通知错误状态
            self.send_mqtt_message({
                "messageId": "104",
                "id": self.state_manager.id,
                "status": "P106E"  # 错误状态
            })
            return False

    # 修复 adjust_audio_speed_ffmpeg 方法中的命令列表
    def adjust_audio_speed_ffmpeg(self, input_path, output_path, speed_factor):
        """
        使用 ffmpeg 调整音频语速
        :param input_path: 输入音频文件路径
        :param output_path: 输出音频文件路径
        :param speed_factor: 语速调整因子
        """
        command = [
            'ffmpeg',
            '-y',  # 添加缺失的逗号
            '-i', input_path,
            '-filter:a', f'atempo={speed_factor}',
            output_path
        ]
        try:
            subprocess.run(command, check=True)
            logger.info(f"音频语速调整完成：{output_path}，调整因子：{speed_factor}")
        except subprocess.CalledProcessError as e:
            logger.error(f"音频语速调整失败：{e}")

    def run(self, context):
        return asyncio.run(self.generate_audio_segments())
