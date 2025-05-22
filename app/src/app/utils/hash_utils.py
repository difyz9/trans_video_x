
import hashlib

def calculate_sha256(file_path):
    """
    计算文件的 SHA-256 哈希值
    :param file_path: 文件的路径
    :return: 文件的 SHA-256 哈希值
    """
    hash_sha256 = hashlib.sha256()
    try:
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_sha256.update(chunk)
        return hash_sha256.hexdigest()
    except FileNotFoundError:
        print(f"文件 {file_path} 未找到。")
    except Exception as e:
        print(f"计算哈希值时出现错误: {e}")
    return None


# 示例使用
# video_file = "/Users/apple/Desktop/003.mp4"
# # 1cc480602c7a2064308c2f8af4085de98009209244144b766d08ef7146bd9a35
# # 1cc480602c7a2064308c2f8af4085de98009209244144b766d08ef7146bd9a35
# sha256_hash = calculate_sha256(video_file)
# if sha256_hash:
#     print(f"视频文件的 SHA-256 哈希值为: {sha256_hash}")
