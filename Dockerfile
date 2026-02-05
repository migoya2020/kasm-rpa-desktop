FROM kasmweb/ubuntu-jammy-dind-rootless:1.18.0

ADD ./ /data

WORKDIR /data

# Set environment variables
ENV VNC_PW=123456

# Install Python dependencies as non-root user
RUN pip3 install --user -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple
