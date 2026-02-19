FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash
ENV TERM=xterm-256color
ENV NODE_OPTIONS="--no-deprecation"

# 1. 基礎ツール
RUN apt update && apt install -y curl git sudo gnupg lsb-release

# 2. システムパッケージ (apt-packages.txt)
COPY apt-packages.txt /tmp/
RUN apt update && xargs -a /tmp/apt-packages.txt apt install -y && \
    rm -rf /var/lib/apt/lists/*

# 3. Docker CLI
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt update && apt install -y docker-ce-cli

# 4. ユーザー & ディレクトリ設定
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN mkdir -p /opt/volta /opt/bun /opt/uv && chown -R ubuntu:ubuntu /opt/

USER ubuntu
WORKDIR /home/ubuntu

# 5. 各種ツールの自動インストール (install/*.sh を全実行)
COPY --chown=ubuntu:ubuntu install/ /tmp/install/
RUN for f in /tmp/install/*.sh; do bash "$f"; done && \
    rm -rf /tmp/install

# 環境変数の設定 (コンテナ内での永続化用)
ENV VOLTA_HOME=/opt/volta
ENV BUN_INSTALL=/opt/bun
ENV UV_INSTALL_DIR=/opt/uv
ENV PATH=${VOLTA_HOME}/bin:${BUN_INSTALL}/bin:${UV_INSTALL_DIR}:/opt/nvim-linux-x86_64/bin:${PATH}

# 6. エントリポイント
COPY --chown=ubuntu:ubuntu entrypoint.sh /usr/local/bin/entrypoint.sh
RUN sudo chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
