from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.config import Settings
from app.core.database import get_db
from app.models.video_model import YTBVideo
from app.models.video_schemas import VideoCreate, VideoResponse
import re
import logging

# 自定义 InvalidURL 异常类
class InvalidURL(Exception):
    pass

# 配置日志记录
logging.basicConfig(level=logging.ERROR)

router = APIRouter()

settings = Settings()

# 提取视频 ID 的函数
def extract_video_id(url):
    """
    从视频 URL 中提取视频 ID。

    :param url: 视频 URL
    :return: 视频 ID
    :raises InvalidURL: 如果 URL 无效
    """
    pattern = r"(?:v=|\/)([0-9A-Za-z_-]{11}).*"
    match = re.search(pattern, url)
    if match:
        return match.group(1)
    else:
        raise InvalidURL("Invalid video URL")

# 首页路由
@router.get("/")
def read_root():
    """
    首页路由，返回欢迎信息。

    :return: 包含欢迎信息的字典
    """
    return {"message": "Welcome to FastAPI with video_api"}

## 🧩 增（创建视频）
@router.post("/add", response_model=VideoResponse)
def create_user(video: VideoCreate, db: Session = Depends(get_db)):
    """
    创建一个新的视频记录。

    :param video: 包含视频信息的请求体
    :param db: 数据库会话
    :return: 创建的视频记录
    """
    try:
        video_id = extract_video_id(video.video_url)
    except InvalidURL:
        logging.error("Invalid video URL provided")
        raise HTTPException(status_code=400, detail="Invalid video URL")
    except Exception as e:
        logging.error(f"An error occurred: {str(e)}")
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")

    db_video = YTBVideo(video_url=video.video_url, status=0, video_id=video_id)
    db.add(db_video)
    db.commit()
    db.refresh(db_video)
    return db_video

## 🧩 查（获取所有视频）
@router.get("/list", response_model=list[VideoResponse])
def get_users(db: Session = Depends(get_db)):
    """
    获取所有视频记录。

    :param db: 数据库会话
    :return: 包含所有视频记录的列表
    """
    return db.query(YTBVideo).order_by(YTBVideo.id.desc()).all()
## 🧩 查（通过 ID 获取视频）
@router.get("/{user_id}", response_model=VideoResponse)
def get_user(video_id: int, db: Session = Depends(get_db)):
    item = db.query(YTBVideo).filter(YTBVideo.id == video_id).first()
    if item is None:
        raise HTTPException(status_code=404, detail="User not found")
    return item

# # 🧩 改（更新用户）
@router.put("/update", response_model=VideoResponse)
def update_user(upvideo: VideoCreate, db: Session = Depends(get_db)):
    print("---- update --- ")
    print(upvideo)
    item = db.query(YTBVideo).filter(YTBVideo.id == upvideo.id).first()
    if not item:
        raise HTTPException(status_code=404, detail="User not found")
    item.enable = upvideo.enable
    item.status = upvideo.status
    item.video_url = upvideo.video_url
    db.commit()
    db.refresh(item)
    return item

## 🧩 删（删除视频）
@router.delete("/{id}")
def delete_user(id: int, db: Session = Depends(get_db)):
    print("delete_user --{}".format(id))
    print()
    video = db.query(YTBVideo).filter(YTBVideo.id == id).first()
    if not video:
        raise HTTPException(status_code=404, detail="Video not found")
    db.delete(video)
    db.commit()
    return {"message": f"User with id {id} has been deleted"}


def extract_video_id(url: str) -> str:
    """从 YouTube URL 提取视频 ID"""
    pattern = r"(?:v=|\/)([0-9A-Za-z_-]{11})"
    match = re.search(pattern, url)
    if match:
        return match.group(1)
    raise ValueError("Invalid YouTube URL")

# from flask import Flask, Blueprint
# from app.models import db

# #  创建蓝图对象
# video_bp = Blueprint('video', __name__, url_prefix='/video')


# @video_bp.route('/')
# def index():
#     return 'hello video'



# @video_bp.route('/add',methods=['POST'])
# def add():
#     return 'hello video'



# @video_bp.route('/list',methods=['GET'])
# def list():
#     return 'hello from list'


# @video_bp.route('/edit',methods=['PUT'])
# def edit():
#     return 'hello video'


# @video_bp.route('/<id>',methods=['DELETE'])
# def delete(id):
#     return f'delete {id} video'
