FROM kasmweb/core-ubuntu-jammy:1.15.0
USER root

ADD ./ /data

WORKDIR /data

# 解压缩 .deb 文件
# RUN gzip -d google-chrome-stable_current_amd64.deb.gz \
#    && gzip -d vscode_1.84.2-1699528352_amd64.deb.gz

RUN apt -y update && mkdir -p /home/kasm-user/Desktop \
    # Chrome \
    && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y -f ./google-chrome-stable_current_amd64.deb \
    && sed -e '/chrome/ s/^#*/#/' -i /opt/google/chrome/google-chrome \
    && echo 'exec -a "$0" "$HERE/chrome" "$@" --user-data-dir="$HOME/.config/chrome" --no-sandbox --disable-dev-shm-usage --no-first-run --disable-infobars --no-default-browser-check' >> /opt/google/chrome/google-chrome \
    && rm -f google-chrome-stable_current_amd64.deb \
    # Visual Studio Code \
    && wget https://az764295.vo.msecnd.net/stable/1a5daa3a0231a0fbba4f14db7ec463cf99d7768e/code_1.84.2-1699528352_amd64.deb \
    && dpkg -i vscode_1.84.2-1699528352_amd64.deb \
    && sed -i 's/Exec=\/usr\/share\/code\/code/Exec=\/usr\/share\/code\/code --no-sandbox/g' /usr/share/applications/code.desktop \
    && sed -i 's/Icon=com.visualstudio.code/Icon=\/usr\/share\/code\/resources\/app\/resources\/linux\/code.png/g' /usr/share/applications/code.desktop \
    && ln -s /usr/share/applications/code.desktop /home/kasm-user/Desktop/code.desktop \
    # 使用阿里云的PyPI镜像源安装requirements.txt中列出的所有Python依赖
    && apt-get install -y sudo python3 python3-pip python3-tk python3-dev telnet vim git tmux cron curl gnome-screenshot unzip \
    && pip3 install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple \
    && apt autoremove -y \
    && apt clean \
    && rm -rf *.deb

# 创建chrome策略文件目录
RUN mkdir -p /etc/opt/chrome/policies/managed/

# 添加chrome策略文件
RUN echo '{"CommandLineFlagSecurityWarningsEnabled": false}' > /etc/opt/chrome/policies/managed/default_managed_policy.json

# 配置系统时间和本地时间同步
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 环境变量配置
ENV TZ=Asia/Shanghai \
   LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    DISPLAY=:0 \
    VNC_PW=123456
