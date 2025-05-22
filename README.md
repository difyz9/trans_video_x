
# TransVideo 项目简介

## 📹 项目概述

TransVideo 是一个集视频翻译与播放功能于一体的跨平台应用，使用 Flutter 框架开发。该项目旨在帮助用户轻松翻译视频内容（包括字幕生成和语音翻译），并提供流畅的视频播放体验。

## ✨ 核心功能

- **视频翻译**
  - 自动生成视频字幕（支持多语言）
  - 语音翻译（将原视频语音转换为目标语言）
  - 字幕翻译（实时翻译现有字幕内容）

- **视频播放**
  - 支持多种视频格式播放
  - 字幕同步显示（原文字幕+翻译字幕）
  - 播放速度调节
  - 画中画模式（PiP）

- **多语言支持**
  - 界面本地化（支持10+种语言）
  - 翻译引擎集成（Google Translate, DeepL等API）

## 🛠️ 技术栈

- **前端**: Flutter (跨平台支持iOS/Android/Web/Desktop)
- **后端**: Firebase (可选自托管Node.js服务器)
- **翻译API**: Google Cloud Translation / Microsoft Translator
- **语音识别**: Google Speech-to-Text / Mozilla DeepSpeech
- **视频处理**: FFmpeg (视频转码和字幕嵌入)

## 🌍 应用场景

1. **语言学习** - 通过翻译外语视频辅助学习
2. **无障碍访问** - 为听障人士提供字幕支持
3. **国际内容消费** - 打破语言障碍观看全球视频
4. **教育领域** - 多语言教学视频制作

## 📂 项目结构

```
trans_video/
├── assets/               # 静态资源
├── lib/
│   ├── core/             # 核心功能(翻译引擎,播放器等)
│   ├── features/         # 功能模块
│   ├── localization/     # 多语言支持
│   ├── models/           # 数据模型
│   ├── services/         # 服务层
│   └── main.dart         # 应用入口
├── test/                 # 测试代码
└── web/                  # Web特定配置
```

## 🚀 快速开始

1. 克隆仓库：
```bash
git clone https://github.com/yourusername/trans_video.git
```

2. 安装依赖：
```bash
flutter pub get
```

3. 配置API密钥：
复制`.env.example`为`.env`并填写您的API密钥

4. 运行应用：
```bash
flutter run
```

## 🤝 贡献指南

欢迎提交Pull Request！请确保：
- 遵循现有代码风格
- 提交前运行`flutter analyze`和`flutter test`
- 更新相关文档

## 📞 联系我
[![QQ](https://img.shields.io/badge/QQ-1163196003-12b7f5?style=for-the-badge&logo=tencent-qq)](http://wpa.qq.com/msgrd?v=3&uin=1163196003&site=qq&menu=yes)  


### 微信交流群
| 微信 |
|  :---:  | 
| <img width="200" src="./img/31747879078_.pic.jpg"> 


## 📄 许可证

本项目采用 [MIT License](LICENSE)


