


from sqlalchemy import Column, Integer,Float, Text, String, DateTime
from sqlalchemy.sql import func

from app.models import db


class SrtInfoModel(db.Model):
    id = Column(Integer, primary_key=True, index=True)
    status = Column(Integer)
    video_id = Column(String(64), nullable=False)
    str_id = Column(Integer, nullable=False)
    begin_time = Column(Float, nullable=False)
    end_time = Column(Float, nullable=False)
    en_text = Column(Text, nullable=True)
    ch_text = Column(Text, nullable=True)
    en_audio = Column(String(255), nullable=True)
    ch_audio = Column(String(255), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=True)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now(), nullable=True)


    @staticmethod
    def find_subtitles_by_status(session, video_id, status_list=None):

            if status_list is None:
                status_list = [0, 1]
            subtitles = (
                session.query(SrtInfoModel)
                .filter(SrtInfoModel.video_id == video_id)
                .filter(SrtInfoModel.status.in_(status_list))
                .order_by(SrtInfoModel.str_id.asc())  # 按照 str_id 进行递增排序
                .all()
            )
            return subtitles
    @staticmethod
    def check_by_status(session,status):
        return session.query(SrtInfoModel).filter(SrtInfoModel.status==status).count() == 0



    def insert_or_update(self,session):
        self.session = session
        instance = (
            self.session.query(SrtInfoModel)
            .filter_by(video_id=self.video_id, str_id=self.str_id)
            .one_or_none()
        )
        if instance is None:
            self.session.add(self)
            self.session.commit()
            self.session.refresh(self)
        else:
            # 更新所有字段，而不只是 en_text
            instance.status = self.status
            instance.video_id = self.video_id
            instance.str_id = self.str_id
            instance.begin_time = self.begin_time
            instance.end_time = self.end_time
            instance.en_text = self.en_text
            instance.ch_text = self.ch_text
            instance.en_audio = self.en_audio
            instance.ch_audio = self.ch_audio
            self.session.commit()
            self.session.refresh(instance)
