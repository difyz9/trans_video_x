from flask import Flask
from app.api import video_bp,user_bp
from app.models import db,User
from apscheduler.schedulers.background import BackgroundScheduler
import atexit
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///test.db'
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
scheduler.add_job(func=query_data, trigger='interval', seconds=5,max_instances=1)
# 启动调度器
scheduler.start()
# 在应用关闭时停止调度器
atexit.register(lambda: scheduler.shutdown())


with app.app_context():
    db.create_all()


app.register_blueprint(video_bp,url_prefix='/api')
app.register_blueprint(user_bp,url_prefix='/api')


@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"


@app.route("/python", methods=["POST"])
def run_python():
    try:
        return pr.run(request.json["command"])
    except Exception as e:
        return str(e)

app.run(port=port)
