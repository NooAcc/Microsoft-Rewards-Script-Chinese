# Use an official Node.js runtime as a base image
FROM node:22

#自动填入环境变量
ENV CRON_SCHEDULE="30 8 * * *" \
    RUN_ON_START="false" \
    TZ="Asia/Shanghai"

# Set the working directory in the container
WORKDIR /usr/src/microsoft-rewards-script

# Install necessary dependencies for Playwright and cron
RUN apt-get update && apt-get install -y \
    jq \
    cron \
    gettext-base \
    xvfb \
    libgbm-dev \
    libnss3 \
    libasound2 \
    libxss1 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    tzdata \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Copy all files to the working directory
COPY . .

# Install dependencies, set permissions, and build the script
RUN npm install && \
    chmod -R 755 /usr/src/microsoft-rewards-script/node_modules && \
    npm run pre-build && \
    npm run build

# Copy cron file to cron directory
COPY src/crontab.template /etc/cron.d/microsoft-rewards-cron.template

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Copy the entrypoint script into the image
COPY entrypoint.sh /usr/local/bin/

# Make the entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT [""]

# Set the entrypoint script as the container's main command
CMD ["entrypoint.sh"]
