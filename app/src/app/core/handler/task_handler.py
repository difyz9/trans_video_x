from abc import ABC, abstractmethod
from app.core.handler.task_state_manager import StateManager
from app.models.task_model import SysTask

class TaskHandler(ABC):
    def __init__(self,name:str,state_manager:StateManager):
        self.name = name
        self.state_manager = state_manager

    """任务基类，所有具体任务必须实现execute方法"""
    @abstractmethod
    def execute(self, context: dict) -> bool:
        raise NotImplementedError("子类必须实现execute方法")

    def insert_one(self):
        item = SysTask()
        item.status = 'padding'
        item.task_name = self.name
        item.video_id = self.state_manager.video_id
        self.state_manager.session.add(item)
        self.state_manager.session.commit()

    def update_status(self,status):
        self.state_manager.session.query(SysTask).filter(SysTask.task_name == self.name).update({'status':status})

