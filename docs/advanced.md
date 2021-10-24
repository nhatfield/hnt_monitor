# Advanced Setup

By default the hnt_monitor caches data locally from the helium blockchain api. This has limitations with grafana and widget features that require a backend database. HNT Monitor now supports caching to an elasticsearch backend service which has been added to `hnt_monitor.yml` file. If you choose to use the elasticsearch backend, you will want to update your yaml file with the proper settings. 

<br />

---
**NOTE:**

For pre-existing users that are launching the full stack by using the `hnt_monitor.sh` script you must edit the hidden yaml file `.hnt_monitor.yml` instead. Copy the elasticsearch and kibana sections from the `hnt_monitor.ynl` file into your private `.hnt_monitor.yml` to enable support


Uncomment, or add the folling lines to your `(.)hnt_monitor.yml`

```
  elasticsearch:
    restart: always
    container_name: elasticsearch
    image: docker.elastic.co/elasticsearch/elasticsearch:6.8.19
    command: "elasticsearch -Enetwork.host=0.0.0.0 -Enode.name='logging' -Etransport.host=0.0.0.0 -Ediscovery.zen.minimum_master_nodes=1 -Egateway.recover_after_time=5s -Expack.security.enabled='false'"
    ports:
      - 9200:9200
    networks:
      hnt_monitor:
        ipv4_address: 10.30.0.06

  kibana:
    restart: always
    container_name: kibana
    image: docker.elastic.co/kibana/kibana:6.8.19
    environment:
      ELASTICSEARCH_URL: "http://elasticsearch:9200"
      XPACK_MONITORING_ENABLED: "true"
      XPACK_SECURITY_ENABLED: "false"
    ports:
      - 5602:5601
    depends_on:
      - elasticsearch
    networks:
      hnt_monitor:
        ipv4_address: 10.30.0.07
```

Additionally, you will need to add the VAR to your settings to start using it.

```
  hnt_monitor:
    container_name: hnt_monitor
    image: hnt_monitor:latest
    restart: always
    build:
      dockerfile: ./build/docker/hnt_monitor/Dockerfile
      context: .
    environment:
+     HNT_COLLECTOR_STORAGE_PROFILE: "elasticsearch"
+     HNT_ELASTICSEARCH_URL: "http://elasticsearch:9200"
```

