class VideoTaskStatus:
    """视频任务状态常量"""

    # 未处理的状态
    PENDING = '003'  # 待处理
    DOWNLOAD_FAILE = '102'  # 正在下载
    DOWNLOAD_COMPLETE = '103'  # 下载完成

    USERUPLOAD= '104'  # 用户提交的视频链接
    USERUPLOADVIDEO='105' # 用户上传的视频

    # 音频处理相关状态
    EXTRACTING_AUDIO = '121'  # 分离音频中
    AUDIO_READY = '122'  # 音频就绪
    AUDIO_ONLY = '123'  # 仅音频处理

    # 字幕处理相关状态
    EXTRACTING_SUBTITLES = '131'  # 分离字幕中
    SUBTITLES_READY = '132'  # 字幕就绪

    # 上传相关状态
    UPLOADING_AUDIO = '141'  # 上传音频
    UPLOADING_VIDEO = '142'  # 上传视频
    UPLOADING_COVER = '143'  # 上传封面
    UPLOADING_SUBTITLES = '145'  # 上传字幕

    # 转码相关状态
    TRANSCODING = '151'  # 转码中
    TRANSCODING_COMPLETE = '152'  # 转码完成

    # 最终状态
    COMPLETED = '200'  # 处理完成
    ERROR = '500'  # 处理出错
    FAILED = '500'  # 处理失败 (与ERROR相同，添加为兼容)

    @staticmethod
    def get_description(status):
        """获取状态描述"""
        descriptions = {
            VideoTaskStatus.PENDING: '待处理',
            VideoTaskStatus.DOWNLOAD_FAILE: '下载失败',
            VideoTaskStatus.DOWNLOAD_COMPLETE: '下载完成',
            VideoTaskStatus.EXTRACTING_AUDIO: '分离音频中',
            VideoTaskStatus.AUDIO_READY: '音频就绪',
            VideoTaskStatus.EXTRACTING_SUBTITLES: '分离字幕中',
            VideoTaskStatus.SUBTITLES_READY: '字幕就绪',
            VideoTaskStatus.UPLOADING_AUDIO: '上传音频',
            VideoTaskStatus.UPLOADING_VIDEO: '上传视频',
            VideoTaskStatus.UPLOADING_COVER: '上传封面',
            VideoTaskStatus.UPLOADING_SUBTITLES: '上传字幕',
            VideoTaskStatus.TRANSCODING: '转码中',
            VideoTaskStatus.TRANSCODING_COMPLETE: '转码完成',
            VideoTaskStatus.COMPLETED: '处理完成',
            VideoTaskStatus.ERROR: '处理出错',
            VideoTaskStatus.FAILED: '处理失败',
            VideoTaskStatus.AUDIO_ONLY: '仅音频处理',
        }
        return descriptions.get(status, f'未知状态({status})')
