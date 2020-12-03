# Info
A collection of bash scripts to scrape websites for in stock items and notify a user when an item is in stock.

Supported Websites:
- Costco Canada
- AMD Direct Buy
- Canada Computers
- MemoryExpress
- TODO: Newegg
- TODO: Amazon

Users are notified via [https://pushover.net/](https://pushover.net/)

This project does not require a whole browser instance to be set up and should theoretically be faster than using Selenium/Puppeteer

# Setup
## Requirements
Requires following utils:
- pcregrep
- xidel
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
CC_LOCATIONS='online|warehouse'
```
Then run one of the scripts under `scrapers/`
```
./scrapers/scrape_cc_5900x.sh
```