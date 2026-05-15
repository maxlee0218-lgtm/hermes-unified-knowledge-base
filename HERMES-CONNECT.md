# 🚀 Hermes连接知识库 - 一条命令搞定

## 连接指令

```bash
# 替换 YOUR_USERNAME 为你的GitHub用户名，然后执行：
cd "/Users/lijun/Library/Mobile Documents/iCloud~md~obsidian/Documents/LEE" && git init && git add . && git commit -m "知识库初始化" && git remote add origin https://github.com/YOUR_USERNAME/hermes-knowledge-base.git && git push -u origin main
```

## Hermes端使用

```python
# Hermes克隆并访问知识库
import os
os.system("git clone https://github.com/YOUR_USERNAME/hermes-knowledge-base.git /tmp/kb")
knowledge_base = "/tmp/kb"
```

## 完成！✅

现在Hermes可以读取、分析、持续沉淀你的733个知识文档了。
