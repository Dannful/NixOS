#!{BASH_BIN}

EWW="{EWW_BIN}"

battery_devices=`ls /sys/class/power_supply | grep -i "bat" | head -1`

LAST_ICON=0

while true; do
  if [[ -z "$battery_devices" ]]; then
    $EWW update battery=""
  else
    battery=`cat /sys/class/power_supply/$battery_devices/capacity`
    status=`cat /sys/class/power_supply/$battery_devices/status`
    if [[ "$status" == "Charging" ]]; then
      if (( $LAST_ICON == 0 )); then
        $EWW update battery="$battery% "
      elif (( $LAST_ICON == 1 )); then
        $EWW update battery="$battery% "
      elif (( $LAST_ICON == 2 )); then
        $EWW update battery="$battery% "
      elif (( $LAST_ICON == 3 )); then
        $EWW update battery="$battery% "
      elif (( $LAST_ICON == 4 )); then
        $EWW update battery="$battery% "
      fi
      LAST_ICON=$(( ($LAST_ICON + 1) % 5 ))
    elif (( $battery > 75 )); then
      $EWW update battery="$battery% "
    elif (( $battery > 50 )); then
      $EWW update battery="$battery% "
    elif (( $battery > 25 )); then
      $EWW update battery="$battery% "
    else
      $EWW update battery="$battery% "
    fi
    $EWW update battery="$battery% "
  fi
  sleep 1
done
