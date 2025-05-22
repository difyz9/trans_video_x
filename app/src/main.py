from flask import Flask
from app.api import  user_bp
from app.api.task_api import task_bp  # Import the new task blueprint
from app.api.order_api import order_bp
from app.models import db, User
from app.models.order_model import OrderModel
from apscheduler.schedulers.background import BackgroundScheduler
import atexit
import os  # Added for instance path
from dotenv import load_dotenv


load_dotenv()
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
port = os.getenv("SERVER_PORT", 8992)  # Default to 8992 if not set in .env


def query_data():
    with app.app_context():
        user = OrderModel.query.first()
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
app.register_blueprint(order_bp, url_prefix='/api')  # Register the URL task blueprint

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"


app.run(port=port)

print(f"Server is running on port {port}")