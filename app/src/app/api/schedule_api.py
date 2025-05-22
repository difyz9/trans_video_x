from app.models import User
from apscheduler.schedulers.background import BackgroundScheduler

from flask import Flask, Blueprint
#  创建蓝图对象
scheduler_bp = Blueprint('scheduler', __name__)




scheduler = BackgroundScheduler()


def query_data():
    with scheduler_bp.app_context_processor():
        user = User.query.first()
        if user:
            print(f"Query result: {user}")
        else:
            print("No data found.")



scheduler.start()