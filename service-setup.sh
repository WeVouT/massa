echo setup service
cd /etc/systemd/system
wget https://raw.githubusercontent.com/wevout/massa/main/massa.service

systemctl daemon-reload
systemctl start massa.service

echo start client
cd /root/massa/massa-client/
cargo run --release