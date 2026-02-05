FROM kasmweb/core-ubuntu-jammy:1.15.0
USER root

ADD ./ /data

WORKDIR /data

RUN apt -y update && mkdir -p /home/kasm-user/Desktop

# Tools needed to fetch Chrome key/repo
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget gnupg ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Google Chrome
RUN mkdir -p /etc/apt/keyrings \
 && wget -qO- https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/keyrings/google-linux-signing-keyring.gpg \
 && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-linux-signing-keyring.gpg] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends google-chrome-stable \
 && ln -sf /usr/bin/google-chrome /usr/bin/chrome \
 && rm -rf /var/lib/apt/lists/*

# # Install VS Code from local .deb file
# RUN dpkg -i code_1.84.2-1699528352_amd64.deb \
#     && sed -i 's/Exec=\/usr\/share\/code\/code/Exec=\/usr\/share\/code\/code --no-sandbox/g' /usr/share/applications/code.desktop \
#     && sed -i 's/Icon=com.visualstudio.code/Icon=\/usr\/share\/code\/resources\/app\/resources\/linux\/code.png/g' /usr/share/applications/code.desktop \
#     && ln -s /usr/share/applications/code.desktop /home/kasm-user/Desktop/code.desktop \
#     && rm -f code_1.84.2-1699528352_amd64.deb

# Install system dependencies and Python packages
RUN apt-get install -y sudo python3 python3-pip python3-tk python3-dev telnet vim git tmux cron curl gnome-screenshot unzip \
    && pip3 install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple \
    && apt autoremove -y \
    && apt clean

# 创建chrome策略文件目录
RUN mkdir -p /etc/opt/chrome/policies/managed/

# 添加chrome策略文件
RUN echo '{"CommandLineFlagSecurityWarningsEnabled": false}' > /etc/opt/chrome/policies/managed/default_managed_policy.json

# 配置系统时间和本地时间同步
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 环境变量配置
ENV TZ=Africa/Nairobi \
   LANG=en_GB.UTF-8 \
    LANGUAGE=en_GB:en \
    DISPLAY=:0 \
    VNC_PW=123456
