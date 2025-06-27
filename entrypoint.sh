#!/bin/sh
set -e

# --- 1. 设置时区 ---
echo "Setting timezone to ${TZ}..."
echo "${TZ}" > /etc/timezone
ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

# --- 2. 动态生成并加载 Cron 任务 ---
echo "Generating cron configuration..."
# 使用 envsubst 将模板中的环境变量替换为实际值
envsubst < /etc/cron.d/microsoft-rewards-cron.template > /etc/cron.d/microsoft-rewards-cron
# 设置正确的权限
chmod 0644 /etc/cron.d/microsoft-rewards-cron
# 让 cron 加载新的配置（在某些系统中需要）
crontab /etc/cron.d/microsoft-rewards-cron

# --- 3. 启动 Cron 服务 ---
echo "Starting cron daemon in the background..."
# -f 表示在前台运行，& 表示让它在 shell 的后台运行
cron -f &

# --- 4. 可选：在启动时立即运行一次任务 ---
if [ "$RUN_ON_START" = "true" ]; then
  echo "RUN_ON_START is true, executing 'npm start' now..."
  # 直接执行 npm start，日志会输出到标准输出
  npm start
fi

# --- 5. 保持容器运行并输出日志 ---
# 这是脚本的主进程，它会保持在前台运行
echo "Tailing cron log file to keep container alive and show logs..."
tail -f /var/log/cron.log
