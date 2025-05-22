from app.models.video_model import YTBVideo
import re

from app.core.handler.task_state_manager import StateManager
from app.core.handler.task_chain_handler import TaskChainHandler
# from app.core.database import get_db


def extract_video_id(url: str) -> str:
    """从 YouTube URL 提取视频 ID"""
    pattern = r"(?:v=|\/)([0-9A-Za-z_-]{11})"
    match = re.search(pattern, url)
    if match:
        return match.group(1)
    raise ValueError("Invalid YouTube URL")


class ScheduleHandler:

    def __init__(self):
        self.running = False
        self.index = 1

    def start(self):
        """启动调度器"""
        self.running = True
        while self.running:
            with get_db() as session:
                video = session.query(YTBVideo).filter(YTBVideo.status == 1).first()
                if video:
                    state_manager = StateManager(video.video_id, session)
                    chain = TaskChainHandler()

                    chain.run()
                    video.status = 10   
                    video.insert_or_update(session=session)

    def stop(self):
        """停止调度器"""
        self.running = False
