<h1>Sui testnet fullnode docker setup</h1>

Simple script to setup sui fullnode. You can choose between start only fullnode and fullnode + monitoring

Just clone repo and execute ./start.sh
```
git clone https://github.com/LexPrime/sui-docker-testnet && cd sui-docker-testnet && ./start.sh
```


![sui-docker-testnet-2](https://user-images.githubusercontent.com/17300737/229599878-f9c4ca84-5813-4bb3-ba61-f79391f8c7c5.png)


After setup fullnode with monitoring go to browser and open Sui node dashboard


![sui-docker-testnet](https://user-images.githubusercontent.com/17300737/229599038-420c5823-1fc0-4778-b380-a141cbd0c1d7.png) ![sui-docker-testnet-1](https://user-images.githubusercontent.com/17300737/229599103-d7c9edee-4ee5-4787-aa21-a850d0686281.png)


Dashboards used:
- https://grafana.com/grafana/dashboards/15798-docker-monitoring-with-service-selection
- https://grafana.com/grafana/dashboards/18297-sui-validator-dashboard-1-0/ by https://www.scale3labs.com/
