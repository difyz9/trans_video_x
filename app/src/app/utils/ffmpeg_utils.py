import ffmpeg

import subprocess
import copy
import os

import sys

# sudo apt update
# sudo apt install ffmpeg



def convert_srt_to_vtt(input_srt, output_vtt):
    """
    将 .srt 文件转换为 .vtt 文件
    :param input_srt: 输入的 .srt 文件路径
    :param output_vtt: 输出的 .vtt 文件路径
    """
    try:
        # 使用 FFmpeg 进行转换
        (
            ffmpeg
            .input(input_srt)
            .output(output_vtt, format='webvtt')
            .run(overwrite_output=True)
        )
        print(f"转换成功：{output_vtt}")
        return True
    except Exception as e:
        print(f"转换失败：{str(e)}")
        return False


def extract_audio_from_video(video_path, audio_path):
    try:
        # 使用 ffmpeg-python 执行音频提取操作
        stream = ffmpeg.input(video_path)
        audio = stream.audio
        out = ffmpeg.output(audio, audio_path, acodec='mp3').overwrite_output()
        ffmpeg.run(out)
        print(f"音频已成功从 {video_path} 中分离并保存为 {audio_path}")
        return True
    except Exception as e:
        print(f"处理过程中出现错误: {str(e)}")
        return False

def take_screenshot(input_video_path, output_image_path, timestamp='00:00:01'):
    try:
        (
            ffmpeg
            .input(input_video_path, ss=timestamp)
            .output(output_image_path, vframes=1)
            .overwrite_output()
            .run()
        )
        print(f"已从 {input_video_path} 在时间 {timestamp} 处截取截图并保存到 {output_image_path}")
        return True
    except Exception as e:
        print(f"截取截图时出现错误: {str(e)}")
        return False


def extract_audio_from_video_cmd(input_video_path, output_audio_path):
    try:
        # 构建 ffmpeg 命令
        command = [
            'ffmpeg',
            '-hide_banner',
            '-ignore_unknown',
            '-y',
            '-i', input_video_path,
            '-vn',
            '-ac', '1',
            '-b:a', '192k',
            '-c:a', 'libmp3lame',
            # '-c:a', 'aac',
            output_audio_path
        ]
        # 执行 ffmpeg 命令
        subprocess.run(command, check=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"执行 ffmpeg 命令时出错: {e}")
        return False
    except FileNotFoundError:
        print("未找到 ffmpeg 可执行文件，请确保 ffmpeg 已正确安装并配置在系统路径中。")
        return False


def transcode_video(input_video_path, output_video_path, preset='fast', crf=23, audio_bitrate='128k',fps=30):
    """
    使用H.264编码器转码视频文件

    Args:
        input_video_path (str): 输入视频文件路径
        output_video_path (str): 输出视频文件路径
        preset (str, optional): 编码速度预设值. 默认为 'fast'
        crf (int, optional): 视频质量参数(0-51,值越小质量越好). 默认为 23
        audio_bitrate (str, optional): 音频比特率. 默认为 '128k'
        fps: 输出视频的帧率（默认为 30）

    Returns:
        bool: 转码成功返回True，失败返回False
    """
    try:
        command = [
            'ffmpeg',
            '-y',
            '-i', str(input_video_path),
            '-c:v', 'libx264',
            '-preset', preset,
            '-crf', str(crf),
            '-r', str(fps),  # 设置输出视频的帧率
            '-c:a', 'aac',
            '-b:a', audio_bitrate,
            str(output_video_path)
        ]

        subprocess.run(command, check=True)

        return True
    except Exception as e:
        print(f"视频转码过程出现错误: {e}")
        return False


def extract_audio_from_url(video_url, output_file):
    """
    从视频URL提取音频并保存到本地

    :param video_url: 视频URL
    :param output_file: 输出音频文件路径
    :return: 成功返回True，失败返回False
    """
    try:
        # 检查输出文件扩展名以确定格式
        ext = os.path.splitext(output_file)[1].lower()
        codec = 'libmp3lame' if ext == '.mp3' else 'copy'  # 默认保持原格式

        cmd = [
            'ffmpeg',
            '-i', video_url,
            '-vn',  # 不要视频
            '-acodec', codec,  # 音频编码器
            '-ab', '192k',  # 音频比特率
            '-y',  # 覆盖输出文件
            output_file
        ]

        # 执行命令并检查返回码
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)

        # 检查输出文件是否确实创建
        if os.path.exists(output_file) and os.path.getsize(output_file) > 0:
            print(f"音频已成功保存到: {output_file}")
            return True
        else:
            print(f"输出文件创建失败: {output_file}")
            return False

    except subprocess.CalledProcessError as e:
        print(f"提取音频失败: {e.stderr}")
        return False
    except Exception as e:
        print(f"发生错误: {e}")
        return False


# if __name__ == '__main__':
#     input_video_path = '/Users/apple/opt/difyz/0322/whisper_api/static/uploads/6b60deb452/6b60deb452.mp4'
#     output_video_path = '/Users/apple/opt/difyz/0322/whisper_api/static/uploads/6b60deb452/6b60deb452_out.mp4'
#     transcode_video(input_video_path,output_video_path)