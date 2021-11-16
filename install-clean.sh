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
git clone --branch testnet https://gitlab.com/massalabs/massa.git

echo # RUSTING
cd /root/massa/massa-client/
cargo build --release
echo # RUSTING
cd /root/massa/massa-node/
RUST_BACKTRACE=full cargo build --release 

echo ############################################################
echo ############################################################
echo ########               MASSA  SETUP                  #######
echo ############################################################
echo ############################################################
cd /etc/systemd/system
wget https://raw.githubusercontent.com/wevout/massa/main/massa.service

systemctl daemon-reload
systemctl start massa.service