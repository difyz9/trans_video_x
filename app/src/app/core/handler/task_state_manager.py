import os
from app.core.config import settings

# 状态管理器
class StateManager:
    def __init__(self,video_id,session):
        self.session = session
        self.video_id = video_id
        self.cache = {}  # 内存缓存
        current_dir = os.path.join(settings.output_dir, self.video_id)
        os.makedirs(current_dir, exist_ok=True)
        self.current_dir = current_dir
        self.input_video_path = "{}/{}.mp4".format(current_dir, self.video_id)
        self.out_video_path = "{}/{}_trans.mp4".format(current_dir, self.video_id)
        self.original_mp3 = "{}/{}.mp3".format(current_dir, self.video_id)
        self.translate_mp3 = "{}/{}_trans.mp3".format(current_dir, self.video_id)
        self.translate_srt = "{}/{}_trans.srt".format(current_dir, self.video_id)
        self.translate_txt = "{}/{}_trans.txt".format(current_dir, self.video_id)

    def get_status(self):
        """获取任务状态"""
        if self.video_id in self.cache:
            return self.cache[self.video_id]

        self.session.execute("SELECT status FROM tasks WHERE id=?", (self.video_id,))
        result = self.session.fetchone()
        if result:
            status = result[0]
            self.cache[self.video_id] = status
            return status
        return None

    def update_status(self, status):
        """更新任务状态"""
        # self.cache[self.] = status

        print( "StateManager  update_status ")

        # self.session.execute("UPDATE tasks SET status=? WHERE id=?", (status, task_id))
        # self.session.commit()

