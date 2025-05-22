from typing import Dict, Any, Optional, Union
from pydantic import BaseModel, Field
from typing import Dict, Any, Optional

class MQTTMessageBuilder:
    """MQTT 消息构建器，更灵活地创建不同类型的消息"""

    @staticmethod
    def create_request_message(client_id: str, topic_name: str, message_id: str = "100") -> Dict:
        """创建请求新任务的消息"""
        return {
            "clientId": client_id,
            "topicName": topic_name,
            "messageId": message_id
        }

    @staticmethod
    def update_status_message(client_id: str, topic_name: str, message_id: str = "104", **kwargs) -> Dict:
        """创建状态更新消息"""
        # 基本消息结构
        message = {
            "clientId": client_id,
            "topicName": topic_name,
            "messageId": message_id,
            "data": {}  # 初始化 data 字段为空字典
        }

        # 添加额外字段
        for key, value in kwargs.items():
            if value is not None:
                message["data"][key] = value

        return message


class VideoData(BaseModel):
    channelId:  Optional[str] = None
    enSrt:  Optional[str] = None
    enVtt:  Optional[str] = None
    id: str
    imgUrl:  Optional[str] = None
    mediaUrl:  Optional[str] = None
    remark:  Optional[str] = None
    status: str
    title:  Optional[str] = None
    videoId: str
    videoUrl: str
    zhSrt:  Optional[str] = None
    zhVtt:  Optional[str] = None


class OrderData(BaseModel):
    cosBucket: Optional[str] = None
    cosKey: Optional[str] = None
    cosLocation: Optional[str] = None
    channelId: Optional[str] = None
    videoUrl: Optional[str] = None
    videoId: Optional[str] = None
    id: Optional[str] = None
    userId: Optional[str] = None
    title: Optional[str] = None
    status: Optional[str] = None
    orderType: Optional[str] = None
    duration: int = Field(default=0)  # 或者设置一个合理的默认值

class MessageData(BaseModel):
    clientId: str
    data: Optional[Any] = None  # 将data设为可选字段    messageId: str
    title: Optional[str] = None  # 将 title 设置为可选
    topicName: str
    
    class Config:
        # 添加配置，允许创建包含额外字段的模型实例
        extra = "allow"


