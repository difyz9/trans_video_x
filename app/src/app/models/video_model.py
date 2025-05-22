from sqlalchemy import Column, Integer, Text, String, DateTime
from sqlalchemy.sql import func
from app.models import db


# 定义 YTBVideo 模型
class YTBVideo(db.Model):
    id = Column(Integer, primary_key=True, index=True)
    status = Column(Integer, nullable=True)
    enable = Column(Integer, nullable=True)
    status_name = Column(String(65), nullable=True,comment = "状态描述")
    video_url = Column(String(255), nullable=True, comment="原视频id")
    video_id = Column(String(64), unique=True, nullable=True, comment="原视频id")
    cn_text = Column(String(64), unique=True, nullable=True, comment="中文")
    en_text = Column(String(64), unique=True, nullable=True, comment="英文")
    title = Column(Text, nullable=True)
    description = Column(Text, nullable=True)
    channel_id = Column(String(200), nullable=True, comment="图片路径")
    medium = Column(String(200), nullable=True, comment="图片路径")
    high = Column(String(200), nullable=True, comment="图片路径")
    standard = Column(String(200), nullable=True, comment="图片路径")
    maxres = Column(String(200), nullable=True, comment="图片路径")
    published_at = Column(DateTime(timezone=True), nullable=True, comment="发布日期")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())


    def find_one_by_status(self,session, status: int):
        self.session = session
        if not isinstance(status, int):
            raise ValueError("Status must be an integer")

        try:
            result = self.session.query(YTBVideo).filter(YTBVideo.status == status).first()
            return result
        except Exception as e:
            print(f"An error occurred while querying the database: {e}")
            return None  # 返回默认值


    def delete_by_id(self,session, id):
        self.session = session
        try:
            result = self.session.query(YTBVideo).filter(YTBVideo.id == id).delete()
            self.session.commit()  # 提交事务
            return result
        except Exception as e:
            self.session.rollback()  # 回滚事务
            raise e  # 重新抛出异常


    def update_by_id(self,session):
        self.session = session
        try:
            instance = self.session.query(YTBVideo).filter(YTBVideo.id == self.id).one_or_none()
            if instance is not None:
                instance.status = self.status
                instance.title = self.title
                instance.enable = self.enable
                instance.description = self.description
                instance.channel_id = self.channel_id
                instance.video_url = self.video_url
                instance.maxres = self.maxres
                instance.published_at = self.published_at
                self.session.commit()  # 提交事务
                self.session.refresh(instance)
            return instance
        except Exception as e:

            raise e  # 重新抛出异常

    def insert_or_update(self,session):

        """
        插入或更新 YTBVideo 记录。

        :param session: SQLAlchemy 会话对象
        :raises Exception: 如果数据库操作过程中发生错误
        """
        self.session = session
        try:
            # 查询是否已存在相同 video_id 的记录
            instance = self.session.query(YTBVideo).filter_by(id=self.id).one_or_none()

            if instance is None:
                # 如果不存在，则插入新记录
                self.status = 1  # 设置默认状态
                self.session.add(self)
                self.session.commit()  # 提交事务
                self.session.refresh(self)  # 刷新新添加的对象
            else:
                # 如果存在，则更新现有记录
                instance.status = self.status
                instance.title = self.title
                instance.enable = self.enable
                instance.description = self.description
                instance.channel_id = self.channel_id
                instance.video_url = self.video_url
                instance.maxres = self.maxres
                instance.published_at = self.published_at
                self.session.commit()  # 提交事务
                self.session.refresh(instance)  # 刷新更新后的对象

        except Exception as e:
            # 回滚事务
            self.session.rollback()
            # 记录日志（可选）
            print(f"An erroror occurred during insert or update: {e}")
            # 重新抛出异常，或者根据业务需求处理
            raise e