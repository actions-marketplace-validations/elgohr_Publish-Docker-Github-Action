FROM ubuntu:22.04@sha256:20fa2d7bb4de7723f542be5923b06c4d704370f0390e4ae9e1c833c8785644c1 as runtime
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get install -y ca-certificates curl gnupg lsb-release jq \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
  && apt-get update \
  && apt-get install -y docker-ce docker-ce-cli containerd.io
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

FROM runtime as testEnv
RUN apt-get install -y coreutils bats
ADD test.bats /test.bats
ADD mock.sh /usr/local/mock/docker
ADD mock.sh /usr/local/mock/date
RUN /test.bats

FROM runtime
