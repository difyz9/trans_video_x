import re

def extract_video_id(url: str) -> str:
    """从 YouTube URL 提取视频 ID"""
    pattern = r"(?:v=|\/)([0-9A-Za-z_-]{11})"
    match = re.search(pattern, url)
    if match:
        return match.group(1)
    raise ValueError("Invalid YouTube URL")

def extract_channel_id(url: str) -> str:
    # 定义正则表达式模式
    pattern = r'list=([^&]+)'
    # 使用 re.search 方法查找匹配项
    match = re.search(pattern, url)
    if match:
        # 提取匹配到的 list 参数的值
        return match.group(1)
    raise ValueError("Invalid YouTube URL")




def format_time(seconds):
    """
    将秒数格式化为 SRT 时间格式。
    """
    hours, remainder = divmod(seconds, 3600)
    minutes, seconds = divmod(remainder, 60)
    milliseconds = int((seconds - int(seconds)) * 1000)
    return f"{int(hours):02}:{int(minutes):02}:{int(seconds):02},{milliseconds:03}"
