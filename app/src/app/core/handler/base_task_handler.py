from app.core.logger import get_logger
from app.core.handler.task_state_manager import TaskStateManager
import traceback

logger = get_logger(__name__)

class BaseTaskHandler:
    def __init__(self, name, state_manager:TaskStateManager, task_type=None):
        self.name = name
        self.state_manager = state_manager
        self.task_type = task_type
        self.status = 'pending'  # 添加状态属性
        
    def execute(self, context: dict):
        """执行任务的通用方法，子类可以重写"""
        try:
            logger.info(f"开始执行任务: {self.name}")

            result = self.run(context)
            
            if result:
                logger.info(f"任务 {self.name} 执行完成")
            else:
                logger.error(f"任务 {self.name} 执行失败")
            
            return result
        except Exception as e:
            error_stack = traceback.format_exc()
            logger.error(f"任务 {self.name} 执行异常: {str(e)}\n{error_stack}")

            raise

    def run(self,context: dict) -> bool:
        """任务实际执行的方法，子类必须实现此方法"""
        raise NotImplementedError("子类必须实现run方法")
    
    def update_status(self, status):
        """更新任务状态"""
        self.status = status
        logger.info(f"任务 {self.name} 状态更新为: {status}")

    def send_mqtt_message(self, message):
        """��送 MQTT 消息"""
            
        return self.state_manager.send_mqtt_message(message)
