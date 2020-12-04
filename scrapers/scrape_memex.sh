function scrape_memex() {
  PRODUCT_ID=$1
  PRODUCT_NAME=$2
  URL="https://www.memoryexpress.com/Products/$PRODUCT_ID"
  SHOP_NAME='MemoryExpress'

  while :; do
    TIME=$(date +%Y-%m-%d_%H-%M-%S)
    RESPONSE=$(curl -s 'https://www.memoryexpress.com/Checkout/AddItemAsync' \
      -H 'Connection: keep-alive' \
      -H 'Accept: application/json, text/javascript, */*; q=0.01' \
      -H 'X-Requested-With: XMLHttpRequest' \
      -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.66 Safari/537.36' \
      -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
      -H 'Origin: https://www.memoryexpress.com' \
      -H 'Sec-Fetch-Site: same-origin' \
      -H 'Sec-Fetch-Mode: cors' \
      -H 'Sec-Fetch-Dest: empty' \
      -H "Referer: https://www.memoryexpress.com/Products/$PRODUCT_ID" \
      -H 'Accept-Language: en-US,en;q=0.9' \
      --data-raw "id=$PRODUCT_ID&qty=1&warranty=" \
      --compressed)

    DESCRIPTION="$TIME: $PRODUCT_NAME at $SHOP_NAME"
    STOCK_STATUS=$(echo "$RESPONSE" | grep -o -E '("added"|Not Found)')
    printf "%s stock is: %s\n" "$DESCRIPTION" "$STOCK_STATUS"

    case $STOCK_STATUS in
    "Not Found")
      MESSAGE="$DESCRIPTION Item is Out of Stock"
      SEND_NOTIFICATION=false
      WAIT_TIME=$CHECK_INTERVAL
      ;;
    '"added"')
      MESSAGE="$DESCRIPTION Item is In Stock"
      SEND_NOTIFICATION=true
      NOTIFICATION_PRIORITY=2
      WAIT_TIME=300
      ;;
    *)
      MESSAGE="$DESCRIPTION failed to scrape"
      SEND_NOTIFICATION=true
      NOTIFICATION_PRIORITY=-1
      WAIT_TIME=30
      ;;
    esac

    echo "$MESSAGE"
    if [ "$SEND_NOTIFICATION" = true ]; then
      send_pushover_notification "$MESSAGE" "$URL" $NOTIFICATION_PRIORITY
    fi
    sleep $WAIT_TIME
  done
}
