# from functools import lru_cache
# import os
# from pathlib import Path
# from typing import Optional
#
#
# class Settings:
#     """Application settings with environment variable support"""
#
#     # API Configuration
#     api_title: str = "Video Translation API"
#     api_description: str = "API for translating video/audio content"
#     api_version: str = "1.0.0"
#     base_url: str = "http://localhost:8000"
#
#     # Volcengine Configuration
#     volc_access_key: str
#     volc_secret_key: str
#
#     volc_app_id: str
#     volc_access_token: str
#     volc_cluster: str
#     volc_region: str
#     # VOLC_SPACE_NAME
#     volc_space_name: str
#
#     # File Upload Configuration
#     upload_dir: str = str(Path("template/uploads").absolute())
#     max_upload_size: int = 100 * 1024 * 1024  # 100MB
#
#     # Database Configuration
#     database_url: str = "sqlite:///./video_tools.db"
#
#     # JWT Configuration
#     secret_key: str
#     algorithm: str = "HS256"
#     access_token_expire_minutes: int = 30
#     youtube_api_key: str
#     out_put_dir: str
#
# @lru_cache()
# def get_settings() -> Settings:
#     """Get cached settings instance"""
#     return Settings()
#
#
# # Create a settings instance
# settings = get_settings()
