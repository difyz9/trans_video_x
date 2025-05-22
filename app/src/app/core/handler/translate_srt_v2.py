from app.core.handler.base_task_handler import BaseTaskHandler
from app.core.logger import get_logger
from app.utils.ffmpeg_utils import convert_srt_to_vtt
import asyncio
from app.core.ollama.translator_ollama_v2 import process_srt_file

logger = get_logger(__name__)


class TranslateSrtWithOllama(BaseTaskHandler):
    def __init__(self, name, state_manager):
        super().__init__(name, state_manager, "task105")



    def run(self, context):
        """
        翻译字幕文本
        """

        asyncio.run(process_srt_file(self.state_manager.original_srt,self.state_manager.translate_srt))
        convert_srt_to_vtt(self.state_manager.original_srt, self.state_manager.original_vtt)
        convert_srt_to_vtt(self.state_manager.translate_srt, self.state_manager.translate_vtt)



        return True
