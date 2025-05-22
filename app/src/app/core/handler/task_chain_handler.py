import logging

logger = logging.getLogger(__name__)

class TaskChainHandler:
    def __init__(self):
        self.tasks = []
        self.context = {}
        
    def add_task(self, task):
        self.tasks.append(task)

    def run(self, stop_on_failure=True):
        """执行任务链
        :param stop_on_failure: 失败时是否停止后续任务
        :return: 执行结果，成功返回True，否则返回False
        """
        success = True
        
        # 如果任务链为空，返回 True 但记录日志
        if len(self.tasks) == 0:
            logger.warning("任务链为空，没有需要执行的任务")
            return True
        
        for task in self.tasks:
            task_name = task.__class__.__name__
            logger.info(f"正在执行任务: {task_name}")
            try:


                # 执行任务
                task_success = task.execute(self.context)
                if task_success:

                    logger.info(f"任务 {task_name} 执行成功")
                else:
                    # 更新任务状态为失败
                    logger.error(f"任务 {task_name} 执行失败，终止链")
                    success = False
                    if stop_on_failure:
                        break
            except Exception as e:
                # 更新任务状态为异常
                logger.error(f"任务 {task_name} 发生异常: {str(e)}", exc_info=True)
                success = False
                if stop_on_failure:
                    break
        return success

    def get_task_by_type(self, task_type):
        """通过任务类型获取任务处理器"""
        for handler in self.tasks:
            if isinstance(handler, task_type):
                return handler
        return None
