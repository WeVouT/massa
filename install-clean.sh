apt-get update
apt-get -y install pkg-config
apt-get -y install curl
apt-get -y install git 
apt-get -y install build-essential 
apt-get -y install  libssl-dev
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
rustup toolchain install nightly
rustup default nightly
git clone --branch testnet https://gitlab.com/massalabs/massa.git

