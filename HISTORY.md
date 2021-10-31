vNext

- **Enchancement** - increase collector frequency on rewards and activity

# 7.2.0

- **Enchancement** - silence warnings for beacon witness counts
- **Enchancement** - allow mulitple payment wallets for billing analysis
- **BugFix** - billing wallet is not properly applying based on cost
- **BugFix** - miner collectors could die and leave locks forcing container restart

# 7.1.0

- **Enchancement** - give inidividual control to activity etl types

# 7.0.0

- **Enchancement** - witnesses and witnessed directly from activity

# 6.3.0

- **Enchancement** - add miner response time
- **Enchancement** - allow user controlled account share in production

# 6.2.0

- **Enchancement** - update backfill days from 30 to 5
- **Enchancement** - update elasticsearch queries to be more efficient
- **Enchancement** - update min threshold on bytes received 

# 6.1.0 

- **Enchancement** - update increased wait time interval for master schedule
- **Enchancement** - update master schedule is now configurable via env variables

# 6.0.0

- **Enchancement** - update bobcat blue dashboard json
- **Enchancement** - add nginx for api authentication option
- **Enchancement** - add support for api authentication on metric payload 
- **Enchancement** - add support for elasticsearch data storage
- **Enchancement** - add support for multiple relayed port verification
- **Enchancement** - add miner type as a tag for group filtering
- **Enchancement** - add billing etl job
- **Enchancement** - add advanced setup readme

# 5.3.0

- **Enchancement** - updating test for version output
- **BugFix** - metrics were broken in multiple vendor miner setup

# 5.2.0

- **Enchancement** - update bobcat default dashboard json
- **Enchancement** - update bobcat blue dashboard json
- **Enchancement** - update README with latest changes
- **Enchancement** - add version to initialize line of log output
- **Enchancement** - add data transfer metrics to activity count
- **BugFix** - relayed and online status was not properly displayed

# 5.1.0

- **Enchancement** - add online status for all miners
- **Enchancement** - add relayed status for all miners
- **Enchancement** - add user controls for etl jobs
- **Enchancement** - support multiple prometheus endpoints to send data
- **Enchancement** - update dashboads with the shared miner metric names
- **Enchancement** - consolidate jq queries where possible

# 5.0.1

- **BugFix** - activity and reward collections were failing to update failure thresholds

# 5.0.0

- **Enchancement** - update metric names to no longer be unique
- **Enchancement** - add timeout threshold to cursor traversing

# 4.3.0

- **Enchancement** - add bobcat blue dashboard json to extras
- **Enchancement** - add default sensecap dashboard json
- **Enchancement** - sync status threshold updated to 20 from 50
- **Enchancement** - update `hnt_monitor.sh` update command to pull stable release versions
- **Enchancement** - update README
- **Enchancement** - update gauge help message for relayed status
- **Enchancement** - report rewards earned 15m, 1h, 1d, 7d, 30d metrics
- **Enchancement** - collect and report activity metrics

# 4.2.0

- **Enchancement** - update hnt_monitor.sh to not allow blank values
- **Enchancement** - update hnt_monitor.sh to catch existing values and prompt for action
- **Enchancement** - update hnt_monitor.sh with better wording during setup
- **Enchancement** - update hnt_monitor.sh with the `deploy` command
- **BugFix** - sensecap serial numbers variable was incorrect in hnt_monitor.sh

# 4.1.0

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
