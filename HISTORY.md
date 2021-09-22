vNext

- **Enchancement** - update the hnt_monitor.sh script user experience for sensecap
- **Enchancement** - update the reademe, fixed typos
- **Enchancement** - setup.sh script moved to hnt_monitor.sh
- **BugFix** - setup.sh sensecap api key was not properly added

# 4.0.2
- **BugFix** - setup.sh was upgrade command was not working

# 4.0.1
- **BugFix** - setup.sh was not setting hotspot_monitor to true

# 4.0.0

- **Enchancement** - add default dashboard json
- **Enchancement** - add setup.sh to automate install and upgrades
- **Enchancement** - add calculated sync status for all miners
- **Enchancement** - add calculated height gap for all miners
- **Enchancement** - add build test cases
- **Enchancement** - add support for nebra miner
- **Enchancement** - add support for longap miner
- **Enchancement** - add [docker hub](https://hub.docker.com/repository/docker/nhatfield/hnt_monitor) image
- **Enchancement** - sensecap collection updated to collector and etl separation
- **BugFix** - witness etl data not pushed to grafana

# 3.3.1

- **BugFix** - sensecap serial numbers were not updated from entrypoint

# 3.3.0

- **Enchancement** - expand bobcat collection

# 3.2.0

- **Enchancement** - fix entrypoint variable replacement
- **Enchancement** - fix readme variable syntax
- **Enchancement** - fix initial collection for multiple miners on a single collector
- **Enchancement** - fix race condition on initial boot to allow collections to complete before the data is processed
- **Enchancement** - improved modular scripting
- **Enchancement** - improved logger
- **Enchancement** - updates to README
- **Enchancement** - add cleanup job data

# 3.1.0

- **Enchancement** - witness collection default moved to 1 hour
- **Enchancement** - fixed addition message output in logs
- **Enchancement** - add support for sensecap miner
- **Enchancement** - add block height collections

# 3.0.0

- **Enchancement** - fixed reward collection
- **Enchancement** - fixed multi address collections
- **Enchancement** - fixed 15 minute reward data etl
- **Enchancement** - fixed kulti address etl
- **Enchancement** - add jenkins build 
- **Enchancement** - backfill 30 days data on initial boot

# 2.0.0

- **Enchancement** - move all ETL to their own microscript
- **Enchancement** - separate collectors from the ETL scripts
- **Enchancement** - move all collectors to their own microscript
- **Enchancement** - only query the api for reward data 15 minutes ago
- **Enchancement** - store data locally for ETL

# 1.6.0

- **Enchancement** - adding grafana, prometheus, prometheus pushgateway, and collector as a full docker stack
- **Enchancement** - updates to README

# 1.5.1

- **HotFix** - bobcat miner instance name was hardcoded
- **HotFix** - bobcat miner project name was hardcoded

# 1.5.0

- **Enchancement** - adding codeowners file to .github
- **Enchancement** - adding support for docker
- **Enchancement** - update readme with docker instructions

# 1.4.0

- **Enchancement** - update readme and grafana png

# 1.3.0

- **Enchancement** - update bobcat miner log output
- **Enchancement** - 1m data moved to 15m data
- **Enchancement** - improved debug logging for rewards

# 1.2.0

- **Enchancement** - improved log output
- **Enchancement** - api_monitor moved to hotspot_monitor
- **Enchancement** - moving bobcat monitor configs to hnt_monitor.conf file

# 1.1.0

- **Enchancement** - updating READEME
- **Enchancement** - moving prometheus pgateway address to config
- **Enchancement** - moving api url to config
- **Enchancement** - moving project name to config

# 1.0.0

- **Enchancement** - adding bobcat_miner script
- **Enchancement** - adding api_monitor script
- **Enchancement** - adding *test* gitignore
- **Enchancement** - moving addresses to their own list
- **Enchancement** - adding path awareness to api_monitor script
- **Enchancement** - reorganizing the structure. adding bin, conf, and lib directories
- **Enchancement** - increasing 7day and 30day accuracy by verifying the initial data object
- **Enchancement** - adding debug output
- **Enchancement** - adding server conf file
- **Enchancement** - solved missed data for 1 minute values when metric is sent on the 59th minute
