
import datetime


def getTime():
    """
    获取当前时间
    :return: 当前时间字符串，格式为 YYYY-MM-DD HH:MM:SS
    """
    now = datetime.datetime.now()
    return now.strftime("%Y-%m-%d %H:%M:%S")


def getTimeStamp():
    """
    获取当前时间戳
    :return: 当前时间戳
    """
    return str(datetime.datetime.now().timestamp())


def getYYYYMMDD():
    """
    获取当前日期，格式为 YYYY-MM-DD
    :return: 当前日期字符串
    """
    now = datetime.datetime.now()
    return now.strftime("%Y-%m-%d")


def getYMDHMS():
    """
    获取当前日期和时间，格式为 YYYYMMDD_HHMMSS
    :return: 当前日期和时间字符串
    """
    now = datetime.datetime.now()
    return now.strftime("%Y%m%d_%H%M%S")

def getYMDHMSM():
    from datetime import datetime

    # 获取当前日期和时间
    now = datetime.now()

    # 格式化年、月、日、时、分、秒
    formatted_datetime = now.strftime("%Y%m%d%H%M%S")

    # 获取毫秒数
    millisecond = int(now.microsecond / 1000)

    # 组合成完整的字符串，包含年、月、日、时、分、秒、毫秒
    result = f"{formatted_datetime}.{millisecond:03}"

    return result