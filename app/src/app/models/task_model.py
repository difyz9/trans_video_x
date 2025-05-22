
from app.models import db

from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func


class SysTask(db.Model):
    id = Column(Integer, primary_key=True, index=True)
    task_name = Column(String(65), nullable=True,comment = "任务名称")
    video_id = Column(String(255), nullable=True, comment="视频id")
    status =  Column(String(65), nullable=True,comment = "状态")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())