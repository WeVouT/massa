echo ------------------------------------------------------------
echo ------------------------------------------------------------
echo --------               MASSA  SETUP                 --------
echo ------------------------------------------------------------
echo ------------------------------------------------------------

apt-get update
apt-get -y install pkg-config
apt-get -y install curl
apt-get -y install git 
apt-get -y install build-essential 
apt-get -y install libssl-dev
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
rustup toolchain install nightly
rustup default nightly

echo clone git repo
git clone --branch testnet https://gitlab.com/massalabs/massa.git

echo rust build client
cd /root/massa/massa-client/
cargo build --release

echo rust build node
cd /root/massa/massa-node/
RUST_BACKTRACE=full cargo build --release 

echo setup service
cd /etc/systemd/system
wget https://raw.githubusercontent.com/wevout/massa/main/massa.service

systemctl daemon-reload
systemctl start massa.service

echo start client
cd /root/massa/massa-client/
cargo run --release