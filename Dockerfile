FROM ubuntu:latest

ARG USERNAME="devuser"
ARG GIT_USERNAME="adevuser"
ARG GIT_EMAIL="adev@email.ro"
ARG SHARED_FOLDER="/tmp/dev"
ENV TOKEN="myGitToken"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates git \
    openssh-server iputils-ping coreutils sudo curl wget python3 python3-pip python3-dev build-essential && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install sshtunnel --break-system-packages

RUN useradd -m -s /bin/bash "${USERNAME}"
RUN echo "${USERNAME}:password" | chpasswd

RUN echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/coder

USER ${USERNAME}

RUN mkdir -p /home/${USERNAME}/.ssh && mkdir -p /home/${USERNAME}/projects && sudo mkdir -p /etc/hosts.d

COPY id_rsa /home/${USERNAME}/.ssh/id_rsa
COPY id_rsa.pub /home/${USERNAME}/.ssh/id_rsa.pub
COPY ./hosts /etc/hosts.d/

RUN sudo chmod 700 /home/${USERNAME}/.ssh
RUN sudo chmod 600 /home/${USERNAME}/.ssh/id_rsa
RUN sudo chmod 644 /home/${USERNAME}/.ssh/id_rsa.pub

RUN git config --global user.name "${GIT_USERNAME}"
RUN git config --global user.email "${GIT_EMAIL}"

RUN mkdir -p /home/${USERNAME}/.local/share/code-server/extensions

RUN curl -fsSL https://code-server.dev/install.sh | sh && \
    code-server --install-extension ms-python.python && \
    code-server --install-extension 4ops.terraform && \
    code-server --install-extension ms-vscode.PowerShell && \
    code-server --install-extension ms-kubernetes-tools.vscode-kubernetes-tools && \
    code-server --install-extension ms-vscode.azurecli

# Expose ports for SSH and code-server
EXPOSE 8080 22

# Start SSH service and code-server on container startup
CMD sudo service ssh start && code-server --auth none --bind-addr 0.0.0.0:8080
