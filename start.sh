#!/bin/bash

DOCKER_COMPOSE_VERSION="v2.17.0"

# Install gum
if [[ ! -x "$(command -v gum)" ]]; then
  sudo apt update && sudo apt install -y curl jq git > /dev/null
  sudo mkdir -p /etc/apt/keyrings > /dev/null
  curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
  echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
  sudo apt update && sudo apt install -y gum  > /dev/null
fi

# Title
gum style --foreground 4 --border-foreground 4 --border double --bold --align center --width 50 --margin "2 20" --padding "1 1" 'SUI NODE INSTALLER' 'by Darksiders Staking'

# Choose option
USER_PICK=$(gum choose --cursor.foreground=4 "Install fullnode" "Install fullnode + monitoring")


# Install docker
if [[ ! -x "$(command -v docker)" ]]; then
  sudo apt-get update > /dev/null
  gum style --foreground 4 --align left --margin "1 1" "Docker not installed. Installing..."
  sudo apt-get remove docker docker-engine docker.io containerd runc > /dev/null
  sudo apt-get install -y curl > /dev/null
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update > /dev/null
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io > /dev/null
  gum style --foreground 4 --align left --margin "1 1" "Done! $(docker --version)"
else
  gum style --foreground 4 --align left --margin "1 1" "Docker installed. $(docker --version)"
fi


# Install docker-compose
if [[ ! -x "$(command -v docker-compose)" ]]; then
  gum style --foreground 4 --align left --margin "2 2" "Installing docker-compose..."
  curl -sL https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-linux-x86_64 -o docker-compose
  chmod +x docker-compose
  sudo mv docker-compose /usr/local/bin
  gum style --foreground 4 --align left --margin "1 1" "Done! Docker-compose version: $(docker-compose --version | cut -d ' ' -f 4)"
else
  gum style --foreground 4 --align left --margin "1 1" "Docker-compose installed. Docker-compose version: $(docker-compose --version | cut -d ' ' -f 4)"
fi


# Create main folder
if [[ -d $HOME/.sui ]]; then
  cd $HOME/.sui
  docker-compose down
else
  mkdir $HOME/.sui
fi


# Clone repo
if [[ ! -d $HOME/sui-docker-testnet ]]; then
  cd $HOME && git clone https://github.com/LexPrime/sui-docker-testnet
  cd $HOME/.sui
fi

# Get docker-compose file
cp $HOME/sui-docker-testnet/docker-compose.yaml $HOME/.sui


# Create fullnode config file
tee $HOME/.sui/fullnode-template.yaml > /dev/null <<EOF
# Update this value to the location you want Sui to store its database
db-path: "/sui/db"
network-address: "/dns/localhost/tcp/8084/http"
metrics-address: "0.0.0.0:9184"
# this address is also used for web socket connections
json-rpc-address: "0.0.0.0:9000"
enable-event-processing: true

genesis:
  # Update this to the location of where the genesis file is stored
  genesis-file-location: "/sui/genesis.blob"

authority-store-pruning-config:
  num-latest-epoch-dbs-to-retain: 3
  epoch-db-pruning-period-secs: 3600
  num-epochs-to-retain: 1
  max-checkpoints-in-batch: 200
  max-transactions-in-batch: 1000
  use-range-deletion: true

p2p-config:
  listen-address: "0.0.0.0:8084"
  external-address: "/ip4/$(curl -s ifconfig.me)/udp/8084"
  seed-peers:
   - address: "/dns/sui-rpc-pt.testnet-pride.com/udp/8084"
   - address: "/dns/sui-rpc-testnet.bartestnet.com/udp/8084"
   - address: "/dns/wave-3.testnet.n1stake.com/udp/8084"
   - address: "/ip4/162.55.84.47/udp/8084"
   - address: "/ip4/38.242.197.20/udp/8080"
   - address: "/ip4/178.18.250.62/udp/8080"
EOF


# Get genesis
gum style --foreground 4 --align left --margin "1 1" "Downloading genesis..."
curl -Ls https://github.com/MystenLabs/sui-genesis/raw/main/testnet/genesis.blob > $HOME/.sui/genesis.blob
gum style --foreground 4 --align left --margin "1 1" "Done! Genesis shasum $(sha256sum $HOME/.sui/genesis.blob | cut -d ' ' -f 1)"


# Create containers and start
gum style --foreground 4 --align left --margin "1 1" "Creating services..."
if [[ $USER_PICK == "Install fullnode" ]]; then
  docker-compose up -d fullnode
else
  if [[ ! -d $HOME/.sui/prometheus ]] || [[ ! -d $HOME/.sui/grafana ]]; then
    cp -R $HOME/sui-docker-testnet/prometheus $HOME/.sui
    cp -R $HOME/sui-docker-testnet/grafana $HOME/.sui
  fi
  docker-compose up -d
fi

# Complete
gum style --foreground 4 --align left --margin "1 1" "Setup complete! What's next?"
gum style --foreground 4 --align left --margin "1 1" "Check logs with docker logs -f sui-node"
gum style --foreground 4 --align left --margin "1 1" "Go to your sui node dashboard in your browser http://$(curl -s ifconfig.me):3555 Login: admin Password: admin"


# Credits
gum style --foreground 4 --border-foreground 4 --border double --bold --align center --width 50 --margin "2 20" --padding "1 1" 'Created by Lex_Prime from Darksiders Staking' 'Follow me:' 'Github: https://github.com/LexPrime' 'Twitter: https://twitter.com/Lex__Prime' 'Medium: https://medium.com/@lexprime' 'Telegram: https://t.me/darksiders_staking'
