from flask import Flask
from app.api import  user_bp
from app.api.task_api import task_bp  # Import the new task blueprint
from app.api.save_url_api import url_bp
from app.models import db, User
from apscheduler.schedulers.background import BackgroundScheduler
import atexit
import os  # Added for instance path

app = Flask(__name__)

# Configure SQLAlchemy
# Ensure the instance folder exists
instance_path = os.path.join(app.instance_path)
if not os.path.exists(instance_path):
    os.makedirs(instance_path)
    print(f"Created instance folder at: {instance_path}")

app.config['SQLALCHEMY_DATABASE_URI'] = f'sqlite:///{os.path.join(instance_path, "tasks.db")}'  # Changed to tasks.db and uses instance_path
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False  # Recommended to disable

db.init_app(app)
scheduler = BackgroundScheduler()

port = 55001

def query_data():
    with app.app_context():
        user = User.query.first()
        if user:
            print(f"Query result: {user}")
        else:
            print("No data found.")

# 添加定时任务，每隔 5 秒执行一次 query_data 函数
scheduler.add_job(func=query_data, trigger='interval', seconds=5, max_instances=1)
# 启动调度器
scheduler.start()
# 在应用关闭时停止调度器
atexit.register(lambda: scheduler.shutdown())

with app.app_context():
    db.create_all()

app.register_blueprint(user_bp, url_prefix='/api')
app.register_blueprint(task_bp, url_prefix='/api')  # Register the task blueprint
app.register_blueprint(url_bp, url_prefix='/api')  # Register the URL task blueprint

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=port, debug=True)
