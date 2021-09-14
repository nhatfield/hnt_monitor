# Scheduling

**Without Docker**

Update the frequency of the data collection in the conf file `hnt_monitor.conf`. The intervals are in (seconds).

```
# info_interval: How many seconds to wait before running the info collector
info_interval=86400

# reward_interval: How many seconds to wait before running the reward collector
rewards_interval=300

# witness_interval: How many seconds to wait before running the witness collectors
witness_interval=86400
```

**Docker**

If you're using docker to manage the collections, you can change the collection intervals by supplying the correct variable during startup. 


```bash
$> docker run -d -e REWARDS_INTERVAL=300 hnt_monitor
```

Full stack run every 5 minutes. Update the `hnt_monitor.yml` at the `hnt_monitor` service section

```bash
  hnt_monitor:
    container_name: hnt_monitor
    image: hnt_monitor:latest
    build:
      dockerfile: ./build/docker/Dockerfile
      context: .
    environment:
      REWARDS_INTERVAL: "300"
      HOTSPOT_MONITOR: "true"
      HOTSPOT_ADDRESSES: "<myminersaddress> "
      PROMETHEUS_PG_HOST: "prometheus_pushgateway"
      DEBUG: "true"
    networks:
      hnt_monitor:
        ipv4_address: 10.30.0.05
    depends_on:
      - prometheus_pushgateway
```

Then stand up the stack

```bash
$> docker-compose -f hnt_monitor.yml up -d
```
![composeup](images/compose-up.png)

## Collector Intervals

Each collector has an interval to set. Go with the defaults or change to your own frequency.

| Variable | Description | Default |
|:--------:|-------------|---------|
| `INFO_INTERVAL` | Frequency in seconds to collect miner information | `86400` |
| `REWARD_INTERVAL` | Frequency in seconds to collect miner rewards | `300` |
| `WITNESS_INTERVAL` | Frequency in seconds to collect miner wintess data | `86400` |
