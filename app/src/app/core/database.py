from flask_sqlalchemy import SQLAlchemy
from flask import current_app
from contextlib import contextmanager

# 这里我们不需要创建新的SQLAlchemy实例，而是导入已有的db
from app.models import db

def get_db():
    """获取数据库会话，与Flask应用上下文集成"""
    try:
        # 使用Flask-SQLAlchemy提供的session
        yield db.session
    except Exception as e:
        db.session.rollback()  # 出现异常时回滚事务
        raise e
    finally:
        try:
            db.session.close()
        except Exception as e:
            print(f"Error closing database session: {e}")

# 如果有需要，可以添加一个上下文管理器
@contextmanager
def db_session():
    """提供上下文管理器形式的数据库会话"""
    session = db.session
    try:
        yield session
        session.commit()
    except Exception as e:
        session.rollback()
        raise e
    finally:
        session.close()