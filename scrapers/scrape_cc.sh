function scrape_cc() {
  URL=$1
  SHOP_NAME='Canada Computers'
  PRODUCT_NAME=$2

  while :; do
    TIME=$(date +%Y-%m-%d_%H-%M-%S)
    RESPONSE=$(curl -s "$URL" \
      -H 'Connection: keep-alive' \
      -H 'Cache-Control: max-age=0' \
      -H 'Upgrade-Insecure-Requests: 1' \
      -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.66 Safari/537.36' \
      -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
      -H 'Sec-Fetch-Site: none' \
      -H 'Sec-Fetch-Mode: navigate' \
      -H 'Sec-Fetch-User: ?1' \
      -H 'Sec-Fetch-Dest: document' \
      -H 'Accept-Language: en-US,en;q=0.9' \
      -H 'Cookie: geolocation=52.233.38.251%7COttawa%7COntario%7CON%7CCanada%7CCA%7CNorth+America%7CNA%7CK2C%7C5%7C45.3679%7C-75.7381%7CAmerica%2FToronto; popupadded=yes;' \
      --compressed)

    DESCRIPTION="$TIME: $PRODUCT_NAME at $SHOP_NAME"
    STOCK_DATA=$(echo "$RESPONSE" | xidel -s --data=- --css '.stocklevel-pop .row:not(.col-border-bottom) .col-9,.stocklevel-pop .row:not(.col-border-bottom) .stocknumber' | sed -r '/^\s*$/d' | paste -d " " - -)
    STOCK_STATUS=$(echo "$STOCK_DATA" | grep -i -E "($CC_LOCATIONS).+[0-9]+")
    printf "%s has stock at:\n%s" "$DESCRIPTION" "$STOCK_STATUS"

    case $STOCK_STATUS in
    "")
      MESSAGE="$DESCRIPTION Item is Out of Stock"
      SEND_NOTIFICATION=false
      WAIT_TIME=$CHECK_INTERVAL
      ;;
    *)
      MESSAGE="$DESCRIPTION has stock"
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


