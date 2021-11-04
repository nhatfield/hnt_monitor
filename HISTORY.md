vNext

- **Enhancement** - add option to send hnt logs to elasticsearch

# 7.4.2

- **BugFix** - block height missing prometheus gateway

# 7.4.1

- **BugFix** - jobs break when supplying multiple prometheus endpoints

# 7.4.0

- **Enhancement** - improve warning message output to include hotspot address
- **Enhancement** - update READEME to include hosted pricing and support
- **Enhancement** - addresses only update on collector startup
- **Enhancement** - get collector configs from account index
- **Enhancement** - get addresses at the master scheduler

# 7.3.0

- **Enhancement** - increase collector frequency on rewards and activity
- **Enhancement** - add account balance to users backend
- **Enhancement** - move billing index to its own
- **Enhancement** - limit billing balance minimum to 0 instead of negative

# 7.2.0

- **Enhancement** - silence warnings for beacon witness counts
- **Enhancement** - allow mulitple payment wallets for billing analysis
- **BugFix** - billing wallet is not properly applying based on cost
- **BugFix** - miner collectors could die and leave locks forcing container restart

# 7.1.0

- **Enhancement** - give inidividual control to activity etl types

# 7.0.0

- **Enhancement** - witnesses and witnessed directly from activity

# 6.3.0

- **Enhancement** - add miner response time
- **Enhancement** - allow user controlled account share in production

# 6.2.0

- **Enhancement** - update backfill days from 30 to 5
- **Enhancement** - update elasticsearch queries to be more efficient
- **Enhancement** - update min threshold on bytes received 

# 6.1.0 

- **Enhancement** - update increased wait time interval for master schedule
- **Enhancement** - update master schedule is now configurable via env variables

# 6.0.0

- **Enhancement** - update bobcat blue dashboard json
- **Enhancement** - add nginx for api authentication option
- **Enhancement** - add support for api authentication on metric payload 
- **Enhancement** - add support for elasticsearch data storage
- **Enhancement** - add support for multiple relayed port verification
- **Enhancement** - add miner type as a tag for group filtering
- **Enhancement** - add billing etl job
- **Enhancement** - add advanced setup readme

# 5.3.0

- **Enhancement** - updating test for version output
- **BugFix** - metrics were broken in multiple vendor miner setup

# 5.2.0

- **Enhancement** - update bobcat default dashboard json
- **Enhancement** - update bobcat blue dashboard json
- **Enhancement** - update README with latest changes
- **Enhancement** - add version to initialize line of log output
- **Enhancement** - add data transfer metrics to activity count
- **BugFix** - relayed and online status was not properly displayed

# 5.1.0

- **Enhancement** - add online status for all miners
- **Enhancement** - add relayed status for all miners
- **Enhancement** - add user controls for etl jobs
- **Enhancement** - support multiple prometheus endpoints to send data
- **Enhancement** - update dashboads with the shared miner metric names
- **Enhancement** - consolidate jq queries where possible

# 5.0.1

- **BugFix** - activity and reward collections were failing to update failure thresholds

# 5.0.0

- **Enhancement** - update metric names to no longer be unique
- **Enhancement** - add timeout threshold to cursor traversing

# 4.3.0

- **Enhancement** - add bobcat blue dashboard json to extras
- **Enhancement** - add default sensecap dashboard json
- **Enhancement** - sync status threshold updated to 20 from 50
- **Enhancement** - update `hnt_monitor.sh` update command to pull stable release versions
- **Enhancement** - update README
- **Enhancement** - update gauge help message for relayed status
- **Enhancement** - report rewards earned 15m, 1h, 1d, 7d, 30d metrics
- **Enhancement** - collect and report activity metrics

# 4.2.0

- **Enhancement** - update hnt_monitor.sh to not allow blank values
- **Enhancement** - update hnt_monitor.sh to catch existing values and prompt for action
- **Enhancement** - update hnt_monitor.sh with better wording during setup
- **Enhancement** - update hnt_monitor.sh with the `deploy` command
- **BugFix** - sensecap serial numbers variable was incorrect in hnt_monitor.sh

# 4.1.0

- **Enhancement** - update the hnt_monitor.sh script user experience for sensecap
- **Enhancement** - update the reademe, fixed typos
- **Enhancement** - setup.sh script moved to hnt_monitor.sh
- **BugFix** - setup.sh sensecap api key was not properly added

# 4.0.2
- **BugFix** - setup.sh was upgrade command was not working

# 4.0.1
- **BugFix** - setup.sh was not setting hotspot_monitor to true

# 4.0.0

- **Enhancement** - add default dashboard json
- **Enhancement** - add setup.sh to automate install and upgrades
- **Enhancement** - add calculated sync status for all miners
- **Enhancement** - add calculated height gap for all miners
- **Enhancement** - add build test cases
- **Enhancement** - add support for nebra miner
- **Enhancement** - add support for longap miner
- **Enhancement** - add [docker hub](https://hub.docker.com/repository/docker/nhatfield/hnt_monitor) image
- **Enhancement** - sensecap collection updated to collector and etl separation
- **BugFix** - witness etl data not pushed to grafana

# 3.3.1

- **BugFix** - sensecap serial numbers were not updated from entrypoint

# 3.3.0

- **Enhancement** - expand bobcat collection

# 3.2.0

- **Enhancement** - fix entrypoint variable replacement
- **Enhancement** - fix readme variable syntax
- **Enhancement** - fix initial collection for multiple miners on a single collector
- **Enhancement** - fix race condition on initial boot to allow collections to complete before the data is processed
- **Enhancement** - improved modular scripting
- **Enhancement** - improved logger
- **Enhancement** - updates to README
- **Enhancement** - add cleanup job data

# 3.1.0

- **Enhancement** - witness collection default moved to 1 hour
- **Enhancement** - fixed addition message output in logs
- **Enhancement** - add support for sensecap miner
- **Enhancement** - add block height collections

# 3.0.0

- **Enhancement** - fixed reward collection
- **Enhancement** - fixed multi address collections
- **Enhancement** - fixed 15 minute reward data etl
- **Enhancement** - fixed kulti address etl
- **Enhancement** - add jenkins build 
- **Enhancement** - backfill 30 days data on initial boot

# 2.0.0

- **Enhancement** - move all ETL to their own microscript
- **Enhancement** - separate collectors from the ETL scripts
- **Enhancement** - move all collectors to their own microscript
- **Enhancement** - only query the api for reward data 15 minutes ago
- **Enhancement** - store data locally for ETL

# 1.6.0

- **Enhancement** - adding grafana, prometheus, prometheus pushgateway, and collector as a full docker stack
- **Enhancement** - updates to README

# 1.5.1

- **HotFix** - bobcat miner instance name was hardcoded
- **HotFix** - bobcat miner project name was hardcoded

# 1.5.0

- **Enhancement** - adding codeowners file to .github
- **Enhancement** - adding support for docker
- **Enhancement** - update readme with docker instructions

# 1.4.0

- **Enhancement** - update readme and grafana png

# 1.3.0

- **Enhancement** - update bobcat miner log output
- **Enhancement** - 1m data moved to 15m data
- **Enhancement** - improved debug logging for rewards

# 1.2.0

- **Enhancement** - improved log output
- **Enhancement** - api_monitor moved to hotspot_monitor
- **Enhancement** - moving bobcat monitor configs to hnt_monitor.conf file

# 1.1.0

- **Enhancement** - updating READEME
- **Enhancement** - moving prometheus pgateway address to config
- **Enhancement** - moving api url to config
- **Enhancement** - moving project name to config

# 1.0.0

- **Enhancement** - adding bobcat_miner script
- **Enhancement** - adding api_monitor script
- **Enhancement** - adding *test* gitignore
- **Enhancement** - moving addresses to their own list
- **Enhancement** - adding path awareness to api_monitor script
- **Enhancement** - reorganizing the structure. adding bin, conf, and lib directories
- **Enhancement** - increasing 7day and 30day accuracy by verifying the initial data object
- **Enhancement** - adding debug output
- **Enhancement** - adding server conf file
- **Enhancement** - solved missed data for 1 minute values when metric is sent on the 59th minute
