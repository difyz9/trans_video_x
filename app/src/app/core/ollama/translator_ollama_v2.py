"""
参考代码 translator.py
ollama大模型增加system_message
按行独立翻译字幕，确保翻译结果完整正确
"""

import json
from ollama import Client
import re
import pysrt
import asyncio
from pathlib import Path

trans_model = 'lauchacarro/qwen2.5-translator'
ollama_host = 'http://127.0.0.1:11434'


def is_chinese_text(text, threshold=0.3):
    """
    检查文本是否包含足够比例的中文字符
    threshold: 中文字符占比的阈值
    """
    if not text or len(text) == 0:
        return False

    chinese_chars = sum(1 for char in text if '\u4e00' <= char <= '\u9fff')
    chinese_ratio = chinese_chars / len(text)

    return chinese_ratio >= threshold


async def translateText(text, max_retries=5):
    """
    使用 Ollama 模型将英文文本翻译为中文
    不使用上下文，只翻译当前字幕
    增加重试机制和格式检查
    """
    if not text or text.strip() == '':
        return ''

    client = Client(host=ollama_host)

    # 系统提示词（定义翻译规则）
    system_message = """你是一名专业的视频字幕翻译专家，请根据以下规则翻译：
1. 保持口语化、简洁自然，符合中文表达习惯
2. 严格保留专业术语和名称
3. 不要添加原文没有的内容
4. 不要在翻译结果中包含任何参考标记或解释性文字
5. 只返回纯翻译结果，不含任何注释或说明
6. 确保将全部内容翻译成中文
7. 输出格式：{"result": "翻译结果"}"""

    # 构建用户提示词
    user_content = f"请将以下英文字幕翻译成中文：\n{text}\n\n只返回JSON格式的翻译结果，不要包含其他内容。"

    attempts = 0
    while attempts < max_retries:
        try:
            messages = [
                {"role": "system", "content": system_message},
                {"role": "user", "content": user_content}
            ]

            response = client.chat(model=trans_model, messages=messages, keep_alive='10m')
            content = response.message.content
            content = re.sub(r'```json|```', '', content).strip()

            # 尝试解析JSON
            try:
                data = json.loads(content)
                translated_text = data.get('result', '')
            except json.JSONDecodeError:
                # 如果无法解析JSON，尝试直接提取可能的翻译结果
                match = re.search(r'"result"\s*:\s*"(.*?)"(?:,|\})', content, re.DOTALL)
                if match:
                    translated_text = match.group(1).replace('\\n', ' ').replace('\\"', '"')
                else:
                    # 如果没有找到result字段，使用整个内容
                    translated_text = content
                    if attempts < max_retries - 1:  # 如果不是最后一次尝试，继续重试
                        attempts += 1
                        await asyncio.sleep(1)
                        continue


            print(translated_text)

            return translated_text

        except Exception as e:
            print(f"翻译失败: {e}，尝试重试 ({attempts + 1}/{max_retries})")
            attempts += 1
            await asyncio.sleep(2)

    # 如果所有重试都失败，返回原文
    print(f"翻译尝试{max_retries}次后仍未成功，返回原文")
    return text


async def process_srt_file(input_file: str, output_file: str):
    """
    处理SRT文件，逐行翻译字幕
    """
    # 确保输入文件存在
    input_path = Path(input_file)
    if not input_path.exists():
        print(f"错误：输入文件 {input_file} 不存在")
        return

    try:
        subs = pysrt.open(input_file, encoding='utf-8')
    except UnicodeDecodeError:
        try:
            subs = pysrt.open(input_file, encoding='utf-8-sig')
        except UnicodeDecodeError:
            subs = pysrt.open(input_file, encoding='latin-1')

    translated_subs = []
    output_path = Path(output_file)
    temp_output = str(output_path.with_suffix('.temp.srt'))

    # 统计进度
    total_items = len(subs)
    print(f"开始翻译，共{total_items}条字幕")

    # 恢复翻译进度（如果有临时文件）
    start_index = 0
    if Path(temp_output).exists():
        try:
            temp_subs = pysrt.open(temp_output, encoding='utf-8')
            if len(temp_subs) > 0:
                translated_subs = list(temp_subs)
                start_index = len(translated_subs)
                print(f"从断点恢复翻译，已完成{start_index}条，剩余{total_items - start_index}条")
        except Exception as e:
            print(f"恢复进度失败: {e}，将从头开始翻译")

    for i in range(start_index, len(subs)):
        # 当前字幕
        current_sub = subs[i]

        # 跳过空白字幕
        if not current_sub.text.strip():
            translated_subs.append(current_sub)
            continue

        # 翻译当前字幕（不使用上下文）
        translated_text = await translateText(text=current_sub.text)

        # 显示翻译进度和结果
        progress_percent = (i + 1) / total_items * 100
        print(f"进度: {i + 1}/{total_items} [{progress_percent:.1f}%]")
        print(f"原文: {current_sub.text}")
        print(f"译文: {translated_text}")
        print("-" * 40)

        # 创建新字幕
        new_sub = pysrt.SubRipItem(
            index=current_sub.index,
            start=current_sub.start,
            end=current_sub.end,
            text=translated_text
        )
        translated_subs.append(new_sub)

        # 每5个字幕保存一次临时结果，避免意外中断丢失进度
        if (i + 1) % 5 == 0:
            pysrt.SubRipFile(items=translated_subs).save(temp_output, encoding='utf-8')

    # 保存最终结果
    pysrt.SubRipFile(items=translated_subs).save(output_file, encoding='utf-8')

    # 翻译完成后删除临时文件
    if Path(temp_output).exists():
        Path(temp_output).unlink()

    print(f"翻译完成！结果已保存到 {output_file}")


# # 示例调用
# async def main():
#     input_srt = "en.srt"  # 输��的英文字幕文件
#     output_srt = "output_zh2.srt"  # 输出的中文字幕文件
#
#     await process_srt_file(input_srt, output_srt)
#
#
# if __name__ == "__main__":
#     asyncio.run(main())