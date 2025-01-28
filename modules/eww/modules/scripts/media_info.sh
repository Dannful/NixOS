#!{BASH_BIN}

IMAGE_DIR="$HOME/.config/eww/modules/music/images"
EWW="{EWW_BIN} -c $HOME/.config/eww/modules/music"

LAST_POSITION=0

update_cover() {
  if [[ -z "$image" ]]; then
    image="$IMAGE_DIR/default.png"
    cp "$image" "$IMAGE_DIR/current.png"
    rm -f "$IMAGE_DIR/current_full.png"
  elif [[ `echo $image | grep -c "file://"` -gt 0 ]]; then
    cp "`echo $image | sed 's/file:\/\///g'`" "$IMAGE_DIR/current_full.png"
    ffmpeg -y -i "$IMAGE_DIR/current_full.png" -vf "scale='if(gt(iw,ih),120,-1)':'if(gt(ih,iw),120,-1)',scale='if(lt(iw,120),120,-1)':'if(lt(ih,120),120,-1)',crop=120:120" "$IMAGE_DIR/current.png"
  else
    curl "$image" -o "/tmp/current.png"
    if [[ $? -eq 0 ]]; then
      cp "/tmp/current.png" "$IMAGE_DIR/current_full.png"
      ffmpeg -y -i "$IMAGE_DIR/current_full.png" -vf "scale='if(gt(iw,ih),120,-1)':'if(gt(ih,iw),120,-1)',scale='if(lt(iw,120),120,-1)':'if(lt(ih,120),120,-1)',crop=120:120" "$IMAGE_DIR/current.png"
    else
      cp "$image" "$IMAGE_DIR/current.png"
      rm -f "$IMAGE_DIR/current_full.png"
    fi
  fi
  $EWW update media_cover="$IMAGE_DIR/current.png"
}

playerctl --follow metadata mpris:artUrl 2> /dev/null | while IFS= read -r image; do
  update_cover
done &

playerctl --follow metadata xesam:artist 2> /dev/null | while IFS= read -r artist; do
  $EWW update media_artist="$artist"
done &

playerctl --follow metadata xesam:title 2> /dev/null | while IFS= read -r title; do
  $EWW update media_title="$title"
done &

playerctl --follow metadata mpris:length 2> /dev/null | while IFS= read -r length; do
  position=`playerctl position 2> /dev/null`
  if (( $position < $LAST_POSITION )); then
    LAST_POSITION=0
  else
    LAST_POSITION=$position
  fi
  $EWW update last_position=$LAST_POSITION
done &

while true; do
  if [[ ! -z `playerctl status 2> /dev/null` ]]; then
    status=`playerctl status 2> /dev/null`

    if [[ "$status" == "Playing" ]]; then
      $EWW update media_status="󰏤"

      position=`echo -n "$(playerctl position 2> /dev/null) $LAST_POSITION" | awk '{ printf("%f", ($1 - $2) * 1000000) }'`
      length=`echo -n "$(playerctl metadata mpris:length 2> /dev/null) $LAST_POSITION" | awk '{ printf("%f", $1 - $2) }'`

      progress=`echo -n "$position $length" | awk '{ printf("%.2f", $1 / $2 * 100); }'`
      $EWW update media_progress=$progress
    else
      $EWW update media_status="󰐊"
    fi
  else
    $EWW update media_cover="$IMAGE_DIR/default.png"
    $EWW update media_title="No title"
    $EWW update media_artist="No artist"
    $EWW update media_progress=0
  fi
  sleep 0.3
done
