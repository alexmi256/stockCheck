function scrape_amd() {
  URL=$1
  SHOP_NAME='AMD Direct Buy'
  PRODUCT_NAME=$2

  while :; do
    TIME=$(date +%Y-%m-%d_%H-%M-%S)
    RESPONSE=$(curl -s "$URL" \
      -H 'authority: www.amd.com' \
      -H 'cache-control: max-age=0' \
      -H 'upgrade-insecure-requests: 1' \
      -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.66 Safari/537.36' \
      -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
      -H 'sec-fetch-site: none' \
      -H 'sec-fetch-mode: navigate' \
      -H 'sec-fetch-user: ?1' \
      -H 'sec-fetch-dest: document' \
      -H 'accept-language: en-US,en;q=0.9,fr;q=0.8,ro;q=0.7' \
      -H 'cookie: pmuser_country=ca;' \
      --compressed)

    DESCRIPTION="$TIME: $PRODUCT_NAME at $SHOP_NAME"
    STOCK_STATUS=$(echo "$RESPONSE" | grep -o 'product-out-of-stock')
    echo "$DESCRIPTION stock is: $STOCK_STATUS"

    case $STOCK_STATUS in
    "product-out-of-stock")
      MESSAGE="$DESCRIPTION Item is Out of Stock"
      SEND_NOTIFICATION=false
      WAIT_TIME=$CHECK_INTERVAL
      ;;
    *)
      MESSAGE="$DESCRIPTION is not out of stock, check details"
      SEND_NOTIFICATION=true
      NOTIFICATION_PRIORITY=2
      WAIT_TIME=300
      ;;
    esac

    echo "$MESSAGE"
    if [ "$SEND_NOTIFICATION" = true ]; then
      send_pushover_notification "$MESSAGE" "$URL" $NOTIFICATION_PRIORITY
    fi
    sleep $WAIT_TIME
  done
}
