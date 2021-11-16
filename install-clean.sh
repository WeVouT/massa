echo # RUSTING
cd /root/massa/massa-client/
cargo build --release
echo #node
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