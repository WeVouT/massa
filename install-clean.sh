apt-get update
sudo apt install pkg-config curl git build-essential libssl-dev
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
rustup toolchain install nightly
rustup default nightly
git clone --branch testnet https://gitlab.com/massalabs/massa.git

cd /etc/systemd/system
curl https://raw.githubusercontent.com/wevout/massa/main/massa.service