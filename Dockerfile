FROM kasmweb/ubuntu-jammy-dind-rootless:1.18.0

ADD ./ /data

WORKDIR /data

# Set environment variables
ENV VNC_PW=123456

# Install Python dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-venv python3-pip curl \
    && pip3 install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple \
    && apt autoremove -y \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*
