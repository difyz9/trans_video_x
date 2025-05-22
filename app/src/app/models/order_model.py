

from sqlalchemy import Column, Integer,Float, Text, String, DateTime
from sqlalchemy.sql import func
import datetime

from app.models import db

class OrderModel(db.Model):
    __tablename__ = 'url_tasks'

    id = db.Column(db.Text, primary_key=True)
    url = db.Column(db.Text, nullable=False)
    title = db.Column(db.Text, nullable=True)
    description = db.Column(db.Text, nullable=True)
    playlist_id = db.Column(db.Text, nullable=True) # Corresponds to playlistId
    operation_type = db.Column(db.Text, nullable=True) # Corresponds to operationType
    timestamp = db.Column(db.DateTime, nullable=False) # Corresponds to timestamp, store as DateTime
    status = db.Column(db.Text, nullable=True, default='pending') # Add a status field
    processing_message = db.Column(db.Text, nullable=True) # For any messages during processing
    created_at = db.Column(db.DateTime, default=datetime.datetime.utcnow)

    def __repr__(self):
        return f'<UrlTask {self.id} - {self.url}>'

    def to_dict(self):
        return {
            'id': self.id,
            'url': self.url,
            'title': self.title,
            'description': self.description,
            'playlistId': self.playlist_id,
            'operationType': self.operation_type,
            'timestamp': self.timestamp.isoformat() if self.timestamp else None,
            'status': self.status,
            'processingMessage': self.processing_message,
            'createdAt': self.created_at.isoformat() if self.created_at else None
        }
