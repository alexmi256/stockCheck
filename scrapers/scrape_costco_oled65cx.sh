URL='https://www.costco.ca/lg-65-in.-smart-4k-oled-tv-oled65cx.product.100661682.html'
SHOP_NAME='Costco Canada'
PRODUCT_NAME='LG OLED65CX'
source .env
source scrapers/helpers/notifiers.sh

while :; do
  TIME=$(date +%Y-%m-%d_%H-%M-%S)
  RESPONSE=$(curl -s $URL \
    -H 'authority: www.costco.ca' \
    -H 'cache-control: max-age=0' \
    -H 'upgrade-insecure-requests: 1' \
    -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.66 Safari/537.36' \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
    -H 'sec-fetch-site: none' \
    -H 'sec-fetch-mode: navigate' \
    -H 'sec-fetch-user: ?1' \
    -H 'sec-fetch-dest: document' \
    -H 'accept-language: en-US,en;q=0.9' \
    --compressed)
  DESCRIPTION="$TIME: $PRODUCT_NAME at $SHOP_NAME"

  STOCK_STATUS=$(echo "$RESPONSE" | tidy -q --show-errors 0 | pcregrep -o1 'input.*value="(Out of Stock|Add to Cart)"')
  echo "$DESCRIPTION Stock is: $STOCK_STATUS"

  case $STOCK_STATUS in
  "Out of Stock")
    MESSAGE="$DESCRIPTION Item is Out of Stock"
    SEND_NOTIFICATION=false
    WAIT_TIME=$CHECK_INTERVAL
    ;;
  "Add to Cart")
    MESSAGE="$DESCRIPTION Item is IN STOCK"
    SEND_NOTIFICATION=true
    NOTIFICATION_PRIORITY=2
    WAIT_TIME=300
    ;;
  *)
    MESSAGE="$DESCRIPTION No response, cURL must have failed. Check if reauth is needed"
    SEND_NOTIFICATION=true
    NOTIFICATION_PRIORITY=1
    WAIT_TIME=300
    ;;
  esac

  echo "$MESSAGE"
  if [ "$SEND_NOTIFICATION" = true ]; then
    send_pushover_notification "$MESSAGE" $URL $NOTIFICATION_PRIORITY
  fi
  sleep $WAIT_TIME
done
