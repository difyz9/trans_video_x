import shutil
import os


from pathlib import Path

def get_relative_path(file_path,media_dir):
    # root = os.getcwd()
    file = Path(file_path)
    root_dir = get_file_path(media_dir)
    try:
        # 计算相对路径
        relative_path = file.relative_to(root_dir)
        return str(relative_path)
    except ValueError:
        # 如果文件路径不在项目根路径内，返回原路径
        return str(file)





# 获取文件路径
def get_file_path(file_path):
    return os.path.dirname(file_path)

 # 获取文件名（包含后缀）
def get_file_name(file_path):
 return os.path.basename(file_path)

# 获取文件扩展名
def get_file_extension(file_path):
    return os.path.splitext(file_path)[1]

# 获取文件名（不包含后缀）
def get_file_name_without_extension(file_path):
    return os.path.splitext(file_path)[0]



def delete_folder(folder_path):
    if os.path.exists(folder_path):
        try:
            shutil.rmtree(folder_path)
            print(f"文件夹 {folder_path} 及其内容已成功删除。")
        except Exception as e:
            print(f"删除文件夹 {folder_path} 时出现错误: {e}")
    else:
        print(f"文件夹 {folder_path} 不存在。")


from pathlib import Path


def create_and_write_file_pathlib(directory, filename, content):
    """
    使用pathlib在指定目录下创建文件并写入内容

    :param directory: 目标目录路径
    :param filename: 要创建的文件名
    :param content: 要写入的内容
    """
    dir_path = Path(directory)
    # 创建目录（如果不存在）
    dir_path.mkdir(parents=True, exist_ok=True)

    file_path = dir_path / filename

    try:
        file_path.write_text(content, encoding='utf-8')
        print(f"文件已成功创建并写入: {file_path}")
        return True
    except Exception as e:
        print(f"文件操作失败: {e}")
        return False