#!/bin/bash
set -e

PROJECT_NAME="$1"
if [ -z "$PROJECT_NAME" ]; then
  echo "用法: $0 <项目名>（仅支持字母、数字、中划线）"
  exit 1
fi

# 输入凭证（安全！不写死）
read -p "Gitee 用户名: " GITEE_USER
read -s -p "Gitee Token: " GITEE_TOKEN
echo

# === 创建本地项目结构 ===
echo "🚀 创建项目: $PROJECT_NAME"
mkdir -p "$PROJECT_NAME/lib" "$PROJECT_NAME/web"
cd "$PROJECT_NAME"

# pubspec.yaml
cat > pubspec.yaml <<EOL
name: $PROJECT_NAME
description: A new Flutter project.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

flutter:
  uses-material-design: true
  web:
    app_name: "$PROJECT_NAME"
EOL

# main.dart
cat > lib/main.dart <<EOL
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('$PROJECT_NAME')),
        body: Center(child: Text('✅ 部署成功！来自 Termux + Vercel')),
      ),
    );
  }
}
EOL

# web/index.html（Flutter Web 必需）
cat > web/index.html <<EOL
<!DOCTYPE html>
<html lang="zh">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>$PROJECT_NAME</title>
  <base href="/">
</head>
<body>
  <div id="flutter_app"></div>
  <script src="main.dart.js" type="application/javascript"></script>
</body>
</html>
EOL

# === 推送到 Gitee ===
echo "📤 推送代码到 Gitee..."
git init -q
git add .
git config user.name "$GITEE_USER"
git config user.email "user@example.com"
git commit -m "init from visionadapt-v2" -q

# 创建远程仓库（避免 404）
curl -s -X POST \
  -H "Authorization: token $GITEE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"'"$PROJECT_NAME"'","auto_init":false,"private":false}' \
  "https://gitee.com/api/v5/user/repos" >/dev/null

git remote add origin "https://$GITEE_USER:$GITEE_TOKEN@gitee.com/$GITEE_USER/$PROJECT_NAME.git"
git push -u origin master -q

echo "✅ 代码已推送到: https://gitee.com/$GITEE_USER/$PROJECT_NAME"

# === 部署到 Vercel ===
if command -v vercel &> /dev/null; then
  echo "☁️ 使用已安装的 Vercel CLI 部署..."
else
  echo "📥 安装 Vercel CLI（首次运行需要）..."
  pkg install nodejs -y
  npm install -g vercel --silent
fi

# 关键：指定 --output-directory=web，否则 Vercel 不知道这是 Flutter Web
vercel --prod --yes --public --output-directory=web

echo "🎉 项目 '$PROJECT_NAME' 已成功部署！"
