from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from app.core.config import Settings
from contextlib import contextmanager

config = Settings()
# SQLALCHEMY_DATABASE_URL = config.database_url  # 根据配置文件选择数据库连接

Base = declarative_base()

engine = create_engine(
    config.database_url,
    pool_size=20,
    max_overflow=10,
    pool_timeout=30,
    pool_recycle=1800,
    echo=False
)
Base.metadata.create_all(engine)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    except Exception as e:
        db.rollback()  # 出现异常时回滚事务
        raise e
    finally:
        try:
            db.close()
        except Exception as e:
            print(f"Error closing database session: {e}")