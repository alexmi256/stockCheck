URL='https://www.amd.com/en/direct-buy/5450881500/ca'
SHOP_NAME='AMD Direct Buy'
PRODUCT_NAME='RYZEN 5900X'
source .env
while :
do
  TIME=$(date +%Y-%m-%d_%H-%M-%S)
  RESPONSE=$(curl -s $URL \
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

  STOCK_STATUS=$(echo "$RESPONSE" | grep -o 'product-out-of-stock')
  echo "$TIME: $PRODUCT_NAME stock is: $STOCK_STATUS"

  case $STOCK_STATUS in
  "product-out-of-stock")
    MESSAGE="$TIME: $PRODUCT_NAME Item is Out of Stock"
    SEND_NOTIFICATION=false
    WAIT_TIME=$CHECK_INTERVAL
    ;;
  *)
    MESSAGE="$TIME: $PRODUCT_NAME is not out of stock, check details"
    SEND_NOTIFICATION=true
    NOTIFICATION_PRIORITY=2
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
         --form-string "url=$URL" \
         --form-string "priority=$NOTIFICATION_PRIORITY" \
         --form-string "retry=30" \
         --form-string "expire=300" \
         https://api.pushover.net/1/messages.json
  fi
  sleep $WAIT_TIME
done