vNext

# 3.2.0

- **TechTask** - fix entrypoint variable replacement
- **TechTask** - fix readme variable syntax
- **TechTask** - fix initial collection for multiple miners on a single collector
- **TechTask** - fix race condition on initial boot to allow collections to complete before the data is processed
- **TechTask** - improved modular scripting
- **TechTask** - improved logger
- **TechTask** - updates to README
- **TechTask** - add cleanup job data

# 3.1.0

- **TechTask** - witness collection default moved to 1 hour
- **TechTask** - fixed addition message output in logs
- **TechTask** - add support for sensecap miner
- **TechTask** - add block height collections

# 3.0.0

- **TechTask** - fixed reward collection
- **TechTask** - fixed multi address collections
- **TechTask** - fixed 15 minute reward data etl
- **TechTask** - fixed kulti address etl
- **TechTask** - add jenkins build 
- **TechTask** - backfill 30 days data on initial boot

# 2.0.0

- **TechTask** - move all ETL to their own microscript
- **TechTask** - separate collectors from the ETL scripts
- **TechTask** - move all collectors to their own microscript
- **TechTask** - only query the api for reward data 15 minutes ago
- **TechTask** - store data locally for ETL

# 1.6.0

- **TechTask** - adding grafana, prometheus, prometheus pushgateway, and collector as a full docker stack
- **TechTask** - updates to README

# 1.5.1

- **HotFix** - bobcat miner instance name was hardcoded
- **HotFix** - bobcat miner project name was hardcoded

# 1.5.0

- **TechTask** - adding codeowners file to .github
- **TechTask** - adding support for docker
- **TechTask** - update readme with docker instructions

# 1.4.0

- **TechTask** - update readme and grafana png

# 1.3.0

- **TechTask** - update bobcat miner log output
- **TechTask** - 1m data moved to 15m data
- **TechTask** - improved debug logging for rewards

# 1.2.0

- **TechTask** - improved log output
- **TechTask** - api_monitor moved to hotspot_monitor
- **TechTask** - moving bobcat monitor configs to hnt_monitor.conf file

# 1.1.0

- **TechTask** - updating READEME
- **TechTask** - moving prometheus pgateway address to config
- **TechTask** - moving api url to config
- **TechTask** - moving project name to config

# 1.0.0

- **TechTask** - adding bobcat_miner script
- **TechTask** - adding api_monitor script
- **TechTask** - adding *test* gitignore
- **TechTask** - moving addresses to their own list
- **TechTask** - adding path awareness to api_monitor script
- **TechTask** - reorganizing the structure. adding bin, conf, and lib directories
- **TechTask** - increasing 7day and 30day accuracy by verifying the initial data object
- **TechTask** - adding debug output
- **TechTask** - adding server conf file
- **TechTask** - solved missed data for 1 minute values when metric is sent on the 59th minute
