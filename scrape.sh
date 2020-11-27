source .env
while :
do
  TIME=$(date +%Y-%m-%d_%H-%M-%S)
  RESPONSE=$(curl -s 'https://www.costco.ca/lg-65-in.-smart-4k-oled-tv-oled65cx.product.100661682.html' \
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

  STOCK_STATUS=$(echo "$RESPONSE" | tidy -q --show-errors 0 | pcregrep -o1 'input.*value="(Out of Stock|Add to Cart)"')
  echo "$TIME: Stock is: $STOCK_STATUS"
  # In stock test
  #
  # No response test
  #

  case $STOCK_STATUS in
  "Out of Stock")
    MESSAGE="$TIME: Item is Out of Stock"
    SEND_NOTIFICATION=false
    WAIT_TIME=30
    ;;
  "Add to Cart")
    MESSAGE="$TIME: Item is IN STOCK"
    SEND_NOTIFICATION=true
    NOTIFICATION_PRIORITY=2
    WAIT_TIME=300
    ;;
  *)
    MESSAGE="$TIME: No response, cURL must have failed. Check if reauth is needed"
    SEND_NOTIFICATION=true
    NOTIFICATION_PRIORITY=1
    WAIT_TIME=300
    ;;
  esac

  echo "$MESSAGE"
  if [ "$SEND_NOTIFICATION" = true ] ; then
      echo "Sending notification with priority $NOTIFICATION_PRIORITY"
      curl -s \
         --form-string "token=$APP_TOKEN" \
         --form-string "user=$USER_KEY" \
         --form-string "message=$MESSAGE" \
         --form-string "device=$DEVICE" \
         --form-string "url=https://www.costco.ca/lg-65-in.-smart-4k-oled-tv-oled65cx.product.100661682.html" \
         --form-string "priority=$NOTIFICATION_PRIORITY" \
         --form-string "retry=30" \
         --form-string "expire=300" \
         https://api.pushover.net/1/messages.json

      if [ "$NOTIFICATION_PRIORITY" = 2 ] ; then
        break
      fi
  fi
  sleep $WAIT_TIME
done