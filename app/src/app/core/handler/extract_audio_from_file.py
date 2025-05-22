from app.core.handler.base_task_handler import BaseTaskHandler
from app.core.logger import get_logger
from app.utils.ffmpeg_utils import extract_audio_from_video_cmd

logger = get_logger(__name__)

class ExtractAudioFromFile(BaseTaskHandler):
    def __init__(self, name, state_manager):
        super().__init__(name, state_manager)


    def run(self, context):
        """
        从视频的url中分离音频
        """
        logger.info(f"开始执行任务: {self.name}")
        try:

            return extract_audio_from_video_cmd(self.state_manager.input_video_path,self.state_manager.original_mp3)
        except Exception as e:
            logger.error(f"更新数据库过程中发生错误: {str(e)}")
            return False


