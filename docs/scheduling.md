# Scheduling

Time to setup scheduling so the monitor can start sending in metrics on a regular interval.

**Without docker**

Since this is a bash script you can schedule the scripts to run at any preferred interval. Generally no more than once a minute so you are not hitting the HNT API too often with queries. I recommend running on a 5 minute interval.

```bash
$> crontab -e

*/5**** /opt/hnt_monitor/bin/hnt_monitor
```

**Docker**

If you're using docker to manage the collections, you can change the collection interval by supplying the `INTERVAL` variable during startup. By default this is set to 60 seconds (1 minute)

Standalone service run every 5 minutes.

```bash
$> docker run -d -e INTERVAL=300 hnt_monitor
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
      INTERVAL: "300"
      HOTSPOT_MONITOR: "true"
      MINER_ADDRESSES: "<myminersaddress> "
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
