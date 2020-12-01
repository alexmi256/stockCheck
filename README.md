# Info
A collection of bash scripts to scrape websites for in stock items and notify a user when an item is in stock.

Supported Websites:
- Costco Canada
- AMD Direct Buy
- TODO: MemoryExpress
- TODO: Canada Computers

Users are notified via [https://pushover.net/](https://pushover.net/)

# Setup
## Requirements
Requires following utils:
- pcregrep
## Config
Copy example config file to .env
```
cp .env.example .env
```
Fill out the .emv file with your details
```
USER_KEY=<pushover user key>
APP_TOKEN=<pushover app token key>
DEVICE=<pushover device name>
CHECK_INTERVAL=30
```
Then run one of the scripts under `scrapers/`