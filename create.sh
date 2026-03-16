#!/bin/bash
set -e

# 1. 获取项目名
PROJECT_NAME="$1"
if [ -z "$PROJECT_NAME" ]; then
  echo "用法: $0 <项目名>"
  exit 1
fi

# 2. 获取 Gitee 凭证
read -p "请输入 Gitee 用户名: " GITEE_USER
read -s -p "请输入 Gitee 个人访问令牌 (PAT): " GITEE_TOKEN
echo

# 3. 创建项目目录
echo "正在创建项目: $PROJECT_NAME..."
mkdir -p "$PROJECT_NAME/lib" "$PROJECT_NAME/web"
cd "$PROJECT_NAME"

# 4. 生成基本的 Flutter 项目文件
cat > pubspec.yaml <<EOL
name: $PROJECT_NAME
description: A new Flutter project.
version: 1.0.0+1
environment:
  sdk: ">=3.0.0 <4.0.0"
dependencies:
  flutter:
    sdk: flutter
EOL

cat > lib/main.dart <<EOL
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        appBar: AppBar(title: Text('Hello from Termux')),
        body: Center(child: Text('Deployed via Vercel')),
      ),
    );
  }
}
EOL

# 5. 初始化 Git 并推送到 Gitee
echo "正在初始化 Git 并推送到 Gitee..."
git init
git remote add origin "https://$GITEE_USER:$GITEE_TOKEN@gitee.com/$GITEE_USER/$PROJECT_NAME.git"
git add .
git commit -m "Initial commit from Termux script"
git push -u origin master

# 6. 调用 Vercel CLI 部署
echo "正在部署到 Vercel..."
vercel --prod

echo "🎉 项目 $PROJECT_NAME 已创建、推送并部署完成！"