function scrape_newegg() {
  URL=$1
  SHOP_NAME='Newegg CA'
  PRODUCT_NAME=$2

  while :; do
    TIME=$(date +%Y-%m-%d_%H-%M-%S)
    RESPONSE=$(curl -s "$URL" \
      -H 'Upgrade-Insecure-Requests: 1' \
      -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.66 Safari/537.36' \
      -H 'Referer: https://secure.newegg.ca/shop/cart' \
      --compressed)

    DESCRIPTION="$TIME: $PRODUCT_NAME at $SHOP_NAME"
    STOCK_STATUS=$(echo "$RESPONSE" | xidel -s --data=- --css '#ProductBuy .btn')
    printf "%s stock is: %s\n" "$DESCRIPTION" "$STOCK_STATUS"

    case $STOCK_STATUS in
    "Sold Out")
      MESSAGE="$DESCRIPTION Item is $STOCK_STATUS (OOS)"
      SEND_NOTIFICATION=false
      WAIT_TIME=$CHECK_INTERVAL
      ;;
    'Add to cart')
      MESSAGE="$DESCRIPTION Item is $STOCK_STATUS (IS)"
      SEND_NOTIFICATION=true
      NOTIFICATION_PRIORITY=2
      WAIT_TIME=300
      ;;
    *)
      MESSAGE="$DESCRIPTION failed to scrape $STOCK_STATUS (Unknown)"
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
