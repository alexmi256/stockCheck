source .env
source scrapers/scrape_amd.sh
source scrapers/scrape_cc.sh
source scrapers/scrape_memex.sh
source scrapers/scrape_newegg.sh
source scrapers/helpers/notifiers.sh

(
  trap 'kill 0' SIGINT
  scrape_amd 'https://www.amd.com/en/direct-buy/5450881500/ca' 'RYZEN 5900X' &
  scrape_amd 'https://www.amd.com/en/direct-buy/5450881400/ca' 'RYZEN 5950X' &
  scrape_cc 'https://www.canadacomputers.com/product_info.php?cPath=4_64_1969&item_id=183430' 'RYZEN 5900X' &
  scrape_cc 'https://www.canadacomputers.com/product_info.php?cPath=4_64_1969&item_id=183427' 'RYZEN 5950X' &
  scrape_memex 'MX00114451' 'RYZEN 5900X' &
  scrape_memex 'MX00114450' 'RYZEN 5950X' &
  scrape_newegg 'https://www.newegg.ca/amd-ryzen-9-5900x/p/N82E16819113664' 'RYZEN 5900X' &
  scrape_newegg 'https://www.newegg.ca/amd-ryzen-9-5950x/p/N82E16819113663' 'RYZEN 5950X'
)
