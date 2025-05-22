import os
from pathlib import Path
from app.core.logger import get_logger
from app.utils.time_utils import getTimeStamp
from app.utils.file_utils import create_and_write_file_pathlib
from app.models.VideoData import VideoData, MQTTMessageBuilder

logger = get_logger(__name__)

# 状态管理器
class TaskStateManager:
    def __init__(self, project_root, video=None, mqtt_service=None,session = None):
        self.video = video
        self.session = session
        self.id = video.id if video else None
        self.video_id = video.videoId if video else None
        self.video_url = video.url if video else None
        self.project_root = project_root
        self.task_id = getTimeStamp()
        self.mqtt_service = mqtt_service  # 添加 MQTT 服务引用

        self.state = {}
        self.cache = {}  # 内存缓存
        
        self.current_dir = None
        self.audio_dir = None
        self.input_video_path = None
        self.out_video_path = None
        self.translate_mp4 = None
        self.original_mp3 = None
        self.original_srt = None
        self.original_vtt = None
        self.translate_srt = None
        self.translate_txt = None
        self.translate_vtt = None
        self.image_cover = None
        self.up_video_path = None


        
        # 如果初始化时已提供 video，则设置相关路径
        if self.video_id:
            self._setup_paths()

    def _setup_paths(self):
        """设置与视频相关的所有路径"""
        self.current_dir = os.path.join(Path(self.project_root), self.video_id)
        
        # 确保目录存在
        os.makedirs(self.current_dir, exist_ok=True)
        os.makedirs(f'{self.current_dir}/audio', exist_ok=True)
        
        self.audio_dir = f"{self.current_dir}/audio"
        self.input_video_path = f"{self.current_dir}/{self.video_id}.mp4"
        self.out_video_path = f"{self.current_dir}/{self.video_id}_trans.mp4"
        self.translate_mp4 = f"{self.current_dir}/{self.video_id}_trans.mp4"
        self.original_mp3 = f"{self.current_dir}/{self.video_id}.mp3"
        self.original_srt = f"{self.current_dir}/en.srt"
        self.translate_txt = f"{self.current_dir}/zh.txt"
        self.mindmap_json = f"{self.current_dir}/{self.video_id}.json"
        self.translate_md = f"{self.current_dir}/{self.video_id}.md"
        self.original_vtt = f"{self.current_dir}/en.vtt"
        self.translate_srt = f"{self.current_dir}/zh.srt"
        self.translate_vtt = f"{self.current_dir}/zh.vtt"
        self.image_cover = f"{self.current_dir}/cover.jpg"
        self.ok_file = f"{self.current_dir}/ok"
        self.up_video_path = self.input_video_path

    def get_relative_path(self,pathName):
        """获取相对路径"""
        return os.path.relpath(self.current_dir, pathName)

    def set_video(self, video: VideoData):
        """动态设置 video 并更新相关路径"""
        self.video = video
        self.video_id = video.videoId
        self._setup_paths()
        
    def set_context(self, key, value):
        """设置上下文数据"""
        self.set_shared_data(key, value)

    def set_shared_data(self, key, value):
        """
        Set data to be shared between tasks.
        """
        self.state[key] = value

    def get_shared_data(self, key, default=None):
        """
        Get shared data between tasks.
        """
        return self.state.get(key, default)

    def get_file_name(self, input: str):
        return input.replace(self.project_root, "")

    def write_ok_file(self):
        create_and_write_file_pathlib(self.current_dir, "ok", "ok")


    def update_video_status(self,pamas):
        pass

    def send_mqtt_message(self, message):
        """通过 MQTT 服务发送消息"""
        if self.mqtt_service:
            return self.mqtt_service.publish(message)
        else:
            logger.error("MQTT 服务未初始化，无法发送消息")
            return None
