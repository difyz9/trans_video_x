import os
from app.core.handler.base_task_handler import BaseTaskHandler
from app.core.logger import get_logger
from app.core.constants.video_task_status import VideoTaskStatus
from app.utils.extract_url import format_time

logger = get_logger(__name__)


import whisper


model = whisper.load_model("medium")

class AudioToText(BaseTaskHandler):
    def __init__(self, name, state_manager):
        super().__init__(name, state_manager, "task104")


    def tran2srt(self):
        logger.info("使用 Whisper 模型转录音频并生成 SRT 文件 -----> ")
        print("音频转文本")

        try:
            logger.info(f"正在将音频 {self.state_manager.original_mp3} 转录为字幕...")

            result = model.transcribe(self.state_manager.original_mp3)

            with open(self.state_manager.original_srt, 'w', encoding='utf-8') as f:
                for i, segment in enumerate(result['segments'], start=1):
                    start_time = segment['start']
                    end_time = segment['end']
                    text = segment['text'].strip()
                    if not text:
                        continue  # 跳过空字幕
                    f.write(f"{i}\n")
                    f.write(f"{format_time(start_time)} --> {format_time(end_time)}\n")
                    f.write(f"{text}\n\n")

            logger.info("转录完成。")
            print("== 转录完成 ==")

            return True

        except Exception as e:
            logger.error(f"转录音频时出错: {e}")

            return False

    def run(self, context):
        """
        上传视频到COS
        """
        logger.info(f"开始执行任务: {self.name}")
            
        try:
            # 这里应该是实际的COS上传逻辑
            # # 上传视频
            flag1 =self.tran2srt()
            if flag1:
                # 更新视频状态
                self.state_manager.update_video_status(VideoTaskStatus.SUBTITLES_READY)
                return True
            else:
                logger.error("视频上传失败")
                return False
                
        except Exception as e:
            logger.error(f"上传视频到COS过程中发生错误: {str(e)}")

            return False
