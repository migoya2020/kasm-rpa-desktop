FROM kasmweb/core-ubuntu-jammy:1.15.0
USER root

ADD ./ /data

WORKDIR /data

# 解压缩 .deb 文件
RUN gzip -d google-chrome-stable_current_amd64.deb.gz \
   && gzip -d vscode_1.84.2-1699528352_amd64.deb.gz

RUN apt -y update && mkdir -p /home/kasm-user/Desktop

# Install Chrome from local .deb file
RUN apt-get install -y -f ./google-chrome-stable_current_amd64.deb \
    && sed -e '/chrome/ s/^#*/#/' -i /opt/google/chrome/google-chrome \
    && echo 'exec -a "$0" "$HERE/chrome" "$@" --user-data-dir="$HOME/.config/chrome" --no-sandbox --disable-dev-shm-usage --no-first-run --disable-infobars --no-default-browser-check' >> /opt/google/chrome/google-chrome \
    && rm -f google-chrome-stable_current_amd64.deb

# Install VS Code from local .deb file
RUN dpkg -i code_1.84.2-1699528352_amd64.deb \
    && sed -i 's/Exec=\/usr\/share\/code\/code/Exec=\/usr\/share\/code\/code --no-sandbox/g' /usr/share/applications/code.desktop \
    && sed -i 's/Icon=com.visualstudio.code/Icon=\/usr\/share\/code\/resources\/app\/resources\/linux\/code.png/g' /usr/share/applications/code.desktop \
    && ln -s /usr/share/applications/code.desktop /home/kasm-user/Desktop/code.desktop \
    && rm -f code_1.84.2-1699528352_amd64.deb

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
