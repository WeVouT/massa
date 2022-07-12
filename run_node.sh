cd $HOME/massa/massa-node
cat >config/config.toml <<EOL
[network]
        routable_ip = "${node_ip}"
EOL

source $HOME/.cargo/env && cargo run --release -- -p 123