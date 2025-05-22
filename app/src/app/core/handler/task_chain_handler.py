
from app.core.handler.task_handler import TaskHandler

# 任务链控制器

class TaskChainHandler:
    def __init__(self):
        self.tasks = []
        self.context = {}

    def add_task(self, task: TaskHandler):
        """添加任务到链中"""
        # task.state_manager.sessio
        task.insert_one()
        print("添加数据库")
        self.tasks.append(task)
        return self  # 支持链式调用

    def run(self, stop_on_failure=True):
        """执行任务链
        :param stop_on_failure: 失败时是否停止后续任务
        """
        for task in self.tasks:
            task_name = task.__class__.__name__
            print(f"正在执行任务: {task_name}")
            try:
                # 更新任务状态为运行中
                task.update_status('running')

                # 执行任务
                success = task.execute(self.context)
                if success:
                    # 更新任务状态为完成
                    task.update_status('completed')
                else:
                    # 更新任务状态为失败
                    task.update_status('failed')
                    print(f"任务 {task_name} 执行失败，终止链")
                    if stop_on_failure:
                        break
            except Exception as e:
                # 更新任务状态为异常
                task.update_status('error')
                print(f"任务 {task_name} 发生异常: {str(e)}")
                if stop_on_failure:
                    break
        return self.context
