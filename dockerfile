FROM ubuntu:20.04

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND="noninteractive" TZ="Europe/Paris"
RUN apt-get update \
&& apt-get upgrade -y \
&& apt install -y pkg-config curl git build-essential libssl-dev screen procps python3-pip wget \
&& apt autoclean -y

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

RUN source $HOME/.cargo/env \
&& rustup toolchain install nightly \
&& rustup default nightly

RUN wget https://raw.githubusercontent.com/WeVouT/massa/main/client.sh
RUN chmod +x client.sh
RUN wget https://raw.githubusercontent.com/WeVouT/massa/main/run_node.sh
RUN chmod +x run_node.sh

WORKDIR /root
RUN git clone --branch testnet https://github.com/massalabs/massa.git

WORKDIR /root/massa/massa-client
RUN source /root/.cargo/env \
&& cargo build --release

WORKDIR /root/massa/massa-node
RUN source /root/.cargo/env \
&& cargo build --release

EXPOSE 31244
EXPOSE 31245

WORKDIR /
CMD ./run_node.sh