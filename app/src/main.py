from flask import Flask
from app.api import user_bp
from app.api.task_api import task_bp
from app.api.order_api import order_bp
from app.models import db, User
from app.models.order_model import OrderModel
from app.core.schedule.schedule_handler import ScheduleHandler
from apscheduler.schedulers.background import BackgroundScheduler
import atexit
from app.core.handler.audio2text import AudioToText
from app.core.handler.download_video import DownloadVideo
from app.core.handler.extract_audio_from_file import ExtractAudioFromFile
from app.core.handler.generate_audio import GenerateAudio
from app.core.handler.translate_srt_v2 import TranslateSrtWithOllama
import re

from app.core.handler.task_state_manager import TaskStateManager
from app.core.handler.task_chain_handler import TaskChainHandler
import os
from dotenv import load_dotenv


load_dotenv()
app = Flask(__name__)

# Configure SQLAlchemy
instance_path = os.path.join(app.instance_path)
if not os.path.exists(instance_path):
    os.makedirs(instance_path)
    print(f"Created instance folder at: {instance_path}")

app.config['SQLALCHEMY_DATABASE_URI'] = f'sqlite:///{os.path.join(instance_path, "tasks.db")}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)
scheduler = BackgroundScheduler()
port = os.getenv("SERVER_PORT", 8992)



def schedule_handler_task():
    with app.app_context():
        try:
            handler = ScheduleHandler()
            # 查询待处理的视频任务
            video = OrderModel.query.filter_by(status='pending').first()
            if video:
                print(f"Found pending task: {video.id} - {video.url}")

                # 更新状态为处理中
                video.status = "processing"
                db.session.commit()  # 提交更改

                root_dir = os.getenv("MEDIA_DIR",".")

                # 注意这里传递 db.session 而不是 db
                task_state_manager = TaskStateManager(root_dir, video=video, mqtt_service=handler, session=db.session)
                task_chain = TaskChainHandler()

                # task_chain.add_task(DownloadVideo(name="", state_manager=task_state_manager))
                # task_chain.add_task(ExtractAudioFromFile(name="", state_manager=task_state_manager))
                # task_chain.add_task(AudioToText(name="", state_manager=task_state_manager))
                task_chain.add_task(TranslateSrtWithOllama(name="", state_manager=task_state_manager))
                task_chain.add_task(GenerateAudio(name="", state_manager=task_state_manager))

                task_chain.run()
                # 处理完成后再次更新状态
                video.status = "completed"
                db.session.commit()
            else:
                print("No pending tasks found")
        except Exception as e:
            print(f"Error in schedule handler task: {e}")
            db.session.rollback()  # 错误时回滚
            # 发生错误时更新状态为失败
            if 'video' in locals() and video:
                video.status = "failed"
                try:
                    db.session.commit()
                except Exception as commit_error:
                    print(f"Error updating status to failed: {commit_error}")
                    db.session.rollback()

# 添加定时任务
scheduler.add_job(func=schedule_handler_task, trigger='interval', seconds=5, max_instances=1)

# 启动调度器
scheduler.start()
# 在应用关闭时停止调度器
atexit.register(lambda: scheduler.shutdown())

with app.app_context():
    db.create_all()

app.register_blueprint(user_bp, url_prefix='/api')
app.register_blueprint(task_bp, url_prefix='/api')
app.register_blueprint(order_bp, url_prefix='/api')

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"


app.run(port=port)

print(f"Server is running on port {port}")