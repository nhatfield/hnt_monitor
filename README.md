# HNT Miner Monitor

## Overview

This repo is used to produce metrics from the various api endpoints on the hnt blockchain and push them to prometheus push gateway service. Currently we extract the following metrics:

**Hotspot API**

- rewards (15 minute, 1 hour, 1 day, 7 days, 30 days)
- witnessed
- witnesses
- reward scale
- block height

**Bobcat API**

- temperature

**Sensecap API**

- cpu temperature
- cpu used
- memory total
- memory used
- sd total
- sd used
- antenna gain
- relayed
- is healthy
- helium block_height
- block height
- connected
- dialable
- nat type

## Prerequisite

**Without Docker**

- [prometheus push gateway](https://github.com/prometheus/pushgateway)
- [prometheus](https://prometheus.io/docs/prometheus/latest/installation)
- [grafana](https://grafana.com/docs/grafana/latest/installation/docker)

You should have your monitoring platform setup by using prometheus and grafana. The pushgateway, from prometheus, will allow us to push metrics to prometheus instead of trying to host the metrics ourselves on an http endpoint.

**Docker**

- [docker](https://docker.io)
- [docker-compose](https://docs.docker.com/compose/install/)
- Disable SELinux (unless you want to deal with adding ports and services manually)

With docker we can create the entire monitoring stack

## Quick Start

**Without Docker**

Navitage to the `src/conf/` directory and add your miner address to the `address.list` file. Then update the `hnt_monitor.conf` file with your prometheus push gateway host and port. Then run the hnt monitor script manually. You can visit the `host:port` of the machine running prometheus pushgaeway and see the new metrics

```bash
$> ./src/bin/hnt_monitor
```

Run in the background if you want to make it a service

```bash
$> ./src/bin/hnt_monitor &
```

**Docker**

Run the hnt monitor script standalone

```bash
$> docker build -t hnt_monitor -f build/docker/Dockerfile .
$> docker run --rm -it hnt_monitor help     # help menu
$> docker run -d -e HOTSPOT_MONITOR=true -e HOTSPOT_ADDRESSES="12345..." -e PROMETHEUS_PG_HOST=my.prometheus-pushgateway.host hnt_monitor  # Enable hotspot monitoring from helium api
```

## Docker

The entire monitoring stack is available in docker containers. Update the configs and deploy the services.

**Configs**

Edit the `hnt_monitor.yml` file and add your miner information to the `hnt_monitor` service environment variables.

```bash
  hnt_monitor:
    container_name: hnt_monitor
    image: hnt_monitor:latest
    build:
      dockerfile: ./build/docker/Dockerfile
      context: .
    environment:
      HOTSPOT_MONITOR: "true"
      HOTSPOT_ADDRESSES: "<myminersaddress> "   # Update your miner address on this line before launching the stack
      PROMETHEUS_PG_HOST: "prometheus_pushgateway"
      DEBUG: "true"
    networks:
      hnt_monitor:
        ipv4_address: 10.30.0.05
    depends_on:
      - prometheus_pushgateway
```

Check the variables table below for more options that the hnt_monitor supports


**Run**

```
$> docker-compose -f hnt_monitor.yml up -d
```

Once the docker-compose completes, you can verify the endpoints in your browser. Open your favorite web browser and check the following endpoints

| Application | Endpoint |
|:-----------:|----------|
| grafana | my.host.com:3000 |
| prometheus | my.host.com:9090 |
| prometheus pushgateway | my.host.com:9091 |

**Prometheus Push Gateway**

Check the prometheus push gateway to see metrics have been pushed from the hnt_monitor.

![prometheuspg](docs/images/prometheus-pg.png)



**Help Menu**

```bash
$> docker run -it --rm hnt_monitor help
```

**Logs**

```bash
$> docker logs -f hnt_monitor
```

**Variables**

| Name | Default | Description | Required |
|:----:|---------|-------------|----------|
| `BLOCKS_URL` | `api.helium.io/v1/blocks` | The helium blocks api url. | `no` |
| `BOBCAT_IPS` | | If bobcat monitoring enabled, list of ips. Ex: '192.x.x.2 192.x.x.3 192.x.x.etc' | `no` |
| `BOBCAT_MONITOR` | `false` | Enable or disable bobcat monitoring. Boolean: `(true or false)` | `no` |
| `DEBUG` | `false` | Turn on debug logging. Boolean: `(true or false)` | `no` |
| `HELIUM_MONITOR` | `true` | Enable or disable helium monitoring. Boolean: `(true or false)` | `no` |
| `HOTSPOT_ADDRESSES` | | Hotspot miner addresses to get metrics from. Ex: 'address1 address2 address3 etc' | `no` |
| `HOTSPOT_MONITOR` | `false` | Enable hotspot monitoring from helium api. Boolean: `(true or false)` | `no` |
| `HOTSPOT_URL` | `api.helium.io/v1/hotspots` | The helium hotspot api url. | `no` |
| `LOGFILE` | `stdout` | Send logs to this file | `no` |
| `LOGPATH` | `/dev/` | Send logs to this path | `no` |
| `PROJECT` | `hnt_monitor` | The name of the metric prefix when sending to prometheus. | `no` |
| `PROMETHEUS_PG_HOST` | `localhost` | The prometheus push gateway hostname. | `yes` |
| `PROMETHEUS_PG_PORT` | `9091` | The prometheus push gateway port. | `no` |
| `SENSECAP_API_KEY` | | Api key for sensecap | `no` |
| `SENSECAP_MONITOR` | `false` | Enable or disable sensecap monitoring. Boolean: `(true or false)` | `no` |
| `SENSECAP_SERIAL_NUMBERS` | | If sensecap monitoring enabled, list of Serial numbers of the sensecap miners | `no` |
| `TRACE` | `false` | Turn on trace logging. Produces more logs than debug. Boolean: `(true or false)` | `no` |


## What's next

- [Scheduling](docs/scheduling.md)
- [Setup Grafana](docs/setup.md)
- [Create Dashboards](docs/dashboards.md)
- [Create Alerts](docs/alerts.md)

## Tips & Donations

Always welcomed, never required =) 

HNT: 13Vazr2mTQSbu2wBGAkqpaLvJQEdSv5aMd3qpdXFJSw2pfNpqC4
