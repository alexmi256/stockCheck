function send_pushover_notification() {
  echo "Notification for $1, priority: $3"
  curl -s \
    --form-string "token=$APP_TOKEN" \
    --form-string "user=$USER_KEY" \
    --form-string "device=$DEVICE" \
    --form-string "retry=30" \
    --form-string "expire=300" \
    --form-string "message=$1" \
    --form-string "url=$2" \
    --form-string "priority=$3" \
    https://api.pushover.net/1/messages.json
}
