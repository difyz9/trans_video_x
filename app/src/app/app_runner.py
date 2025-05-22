
from app.core.config import Settings
from app.core.database import Base, engine
from app.api import video_api

# Create database tables
Base.metadata.create_all(bind=engine)


def create_application() -> FastAPI:
    settings = Settings()

    app = FastAPI(
        title=settings.api_title,
        description=settings.api_description,
        version=settings.api_version
    )

    # Enable CORS
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Mount template files
    app.mount("/uploads", StaticFiles(directory=settings.upload_dir), name="uploads")

    # Include routers
    # app.include_router(user_api.app, prefix="/api/v1", tags=["user_api"])
    # app.include_router(auth.router, prefix="/api/auth", tags=["authentication"])
    # app.include_router(edge_api.router, prefix="/api/edge", tags=["edge"])
    # app.include_router(schedule_api.router, prefix="/api/schedule", tags=["schedule"])
    app.include_router(video_api.router, prefix="/api/video", tags=["video"])
    # app.include_router(wechat_api.router, prefix="/api/pay", tags=["wechat-pay"])

    # app.include_router(setting_api.router, prefix="/api/setting", tags=["settings"])
    # app.include_router(translation.router, prefix="/api", tags=["translation"])

    return app


app = create_application()

