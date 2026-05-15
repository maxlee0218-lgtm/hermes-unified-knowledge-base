# GitHub 仓库迁移指南

## 📋 迁移概览
本指南帮助您将分散的GitHub仓库内容迁移到统一的Obsidian知识库中。

## 🎯 迁映射表

| GitHub 仓库 | 目标目录 | 优先级 | 状态 |
|------------|---------|--------|------|
| `llm-wiki` | `01-ai-ml-research/` | 高 | ✅ 已整合 |
| `obnote` | `02-infrastructure/` | 高 | 🔄 待迁移 |
| `certificate-system` | `03-certificate-system/` | 中 | 🔄 待迁移 |
| `warehouse-engineering-playbook` | `04-warehouse-projects/engineering-playbook/` | 中 | 🔄 待迁移 |
| `warehouse-rebuild` | `04-warehouse-projects/rebuild-audit/` | 中 | 🔄 待迁移 |
| `openclaw-v2-infra` | `05-openclaw-infra/` | 中 | 🔄 待迁移 |
| `obsidian-vault` | `06-obsidian-vault/` | 高 | 🔄 待迁移 |

## 🚀 迁移步骤

### 方法一：手动迁移（推荐）

#### 1. 安装GitHub CLI
```bash
# 如果还未安装gh命令
brew install gh
gh auth login
```

#### 2. 逐个迁移仓库
```bash
# 示例：迁移obnote仓库
cd ~/Downloads
gh repo clone maxlee0218-lgtm/obnote
cd obnote
# 复制所有内容到知识库对应目录
cp -r * "/Users/lijun/Library/Mobile Documents/iCloud~md~obsidian/Documents/LEE/02-infrastructure/"

# 对其他仓库重复此过程
```

### 方法二：使用GitHub网页界面

1. 访问对应的GitHub仓库
2. 下载ZIP文件
3. 解压到临时目录
4. 手动复制到对应的Obsidian知识库目录

### 方法三：使用自动化脚本（需网络恢复后）

当GitHub网络连接恢复后，可以使用以下脚本：

```bash
#!/bin/bash
# 迁移脚本

REPOS=(
  "obnote:02-infrastructure"
  "certificate-system:03-certificate-system"
  "warehouse-engineering-playbook:04-warehouse-projects/engineering-playbook"
  "warehouse-rebuild:04-warehouse-projects/rebuild-audit"
  "openclaw-v2-infra:05-openclaw-infra"
  "obsidian-vault:06-obsidian-vault"
)

BASE_DIR="/Users/lijun/Library/Mobile Documents/iCloud~md~obsidian/Documents/LEE"
TEMP_DIR="/tmp/github-migration"

mkdir -p "$TEMP_DIR"

for repo_mapping in "${REPOS[@]}"; do
  IFS=':' read -r repo target_dir <<< "$repo_mapping"
  echo "迁移 $repo 到 $target_dir"
  
  gh repo clone "maxlee0218-lgtm/$repo" "$TEMP_DIR/$repo"
  mkdir -p "$BASE_DIR/$target_dir"
  cp -r "$TEMP_DIR/$repo"/* "$BASE_DIR/$target_dir/"
done

echo "迁移完成！"
```

## 📝 迁移后处理

### 1. 文档整理
- 转换Markdown文件格式以适配Obsidian
- 更新内部链接
- 添加适当的标签和元数据

### 2. 内容验证
- 检查所有文件是否正确迁移
- 验证图片和附件链接
- 确认代码格式正确

### 3. 链接更新
- 更新仓库间的相互引用
- 修复相对路径链接
- 建立Obsidian双链网络

### 4. 清理工作
- 删除临时文件
- 归档或删除原有GitHub仓库
- 更新相关文档中的链接

## 🔧 特殊处理

### 代码文件处理
- 代码仓库可以保留在GitHub上
- 在知识库中添加相应的说明和链接
- 重点迁移文档和配置说明

### 大文件处理
- 大文件可以保留在云存储中
- 在知识库中添加引用链接
- 考虑使用Git LFS

### 历史保留
- 重要的Git历史需要保留
- 可以在迁移后归档原仓库
- 在知识库中记录重要节点

## ⚠️ 注意事项

1. **备份优先**: 迁移前务必备份重要数据
2. **网络问题**: 当前GitHub连接不稳定，建议使用手动方法
3. **权限确认**: 确保有所有仓库的访问权限
4. **依赖关系**: 注意仓库间的依赖关系
5. **链接更新**: 迁移后需要更新相关链接

## 📞 技术支持

- 迁移过程中遇到问题，可以参考各目录的README文件
- Obsidian使用问题请查看官方文档
- GitHub相关问题请查看GitHub帮助文档

---

*创建时间: 2026-05-14*
*最后更新: 2026-05-14*