import os
import subprocess
from app.core.handler.base_task_handler import BaseTaskHandler
from app.core.logger import get_logger
from app.core.constants.video_task_status import VideoTaskStatus

logger = get_logger(__name__)

class DownloadVideo(BaseTaskHandler):
    def __init__(self, name, state_manager):
        self.yt_dlp = os.getenv("YT_DLP_PATH", "yt-dlp")

        # Pass the task_id explicitly for database recording
        super().__init__(name, state_manager, "task100")
    
    def run(self, context):
        """
        实际执行视频下载任务
        """
        logger.info(f"开始执行任务: {self.name}")

        try:
            # -phSGLYolQw
            # yget2 -- -phSGLYolQw

            # 使用yt-dlp下载视频
            cmd = [
                self.yt_dlp,
                '-P', self.state_manager.current_dir,
                '-o', '%(id)s.%(ext)s',
                '--proxy','http://127.0.0.1:7890',
                '--cookies-from-browser', 'chrome',
                '--merge-output-format', 'mp4',
                self.state_manager.video_id
            ]

            logger.info(f"执行下载命令: {' '.join(cmd)}")

            # 执行下载命令
            process = subprocess.run(cmd, check=True, capture_output=True, text=True)

            # 检查下载结果
            if os.path.exists(self.state_manager.input_video_path):
                logger.info(f"视频下载成功: {self.state_manager.input_video_path}")

                return True
            else:
                logger.error(f"视频下载失败，文件不存在: {self.state_manager.input_video_path}")
                return False
                
        except Exception as e:
            logger.error(f"视频下载过程中发生错误: {str(e)}")
            return False