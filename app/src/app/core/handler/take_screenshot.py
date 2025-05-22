import time

from app.core.handler.base_task_handler import BaseTaskHandler
from app.core.logger import get_logger
from app.utils.ffmpeg_utils import take_screenshot

logger = get_logger(__name__)

class TaskImageFromVideo(BaseTaskHandler):
    def __init__(self, name, state_manager):
        super().__init__(name, state_manager)
    
    def run(self, context):
        """
        根据视频URL提取封面图片
        """
        logger.info(f"开始执行任务: {self.name}")
        try:
            take_screenshot(self.state_manager.input_video_path,self.state_manager.image_cover)
            return True

        except Exception as e:
            logger.error(f"封面提取过程中发生错误: {str(e)}")
            return False