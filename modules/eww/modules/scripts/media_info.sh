#!{BASH_BIN}

IMAGE_DIR="$HOME/.config/eww/modules/music/images"
EWW="{EWW_BIN} -c $HOME/.config/eww/modules/music"
SCRIPT_NAME="media_info"
LOG_SCRIPT="$HOME/.config/eww/modules/scripts/log.sh"

LAST_POSITION=0
LAST_LENGTH=0

update_cover() {
  if [[ `echo $image | grep -c "file://"` -gt 0 ]]; then
    cp "`echo $image | sed 's/file:\/\///g'`" "$IMAGE_DIR/current_full.png"
    ffmpeg -y -i "$IMAGE_DIR/current_full.png" -vf "scale='if(gt(iw,ih),120,-1)':'if(gt(ih,iw),120,-1)',scale='if(lt(iw,120),120,-1)':'if(lt(ih,120),120,-1)',crop=120:120" "$IMAGE_DIR/current.png"
  else
    wget "$image" -o "/tmp/current.png"
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

playerctl --follow metadata mpris:artUrl | while IFS= read -r image; do
  update_cover
done &

playerctl --follow metadata xesam:artist | while IFS= read -r artist; do
  $EWW update media_artist="$artist"
done &

playerctl --follow metadata xesam:title | while IFS= read -r title; do
  $EWW update media_title="$title"
done &

while true; do
  if [[ ! -z `playerctl status 2> /dev/null` ]]; then
    status=`playerctl status 2> /dev/null`

    if [[ "$status" == "Playing" ]]; then
      $EWW update media_status="󰏥"

      position=`playerctl --player="$player" position | awk '{ printf("%f", $1 * 1000000) }'`
      length=`playerctl --player="$player" metadata mpris:length`
      if (( $position > $LAST_POSITION )); then
        position=$(( $position - $LAST_POSITION ))
        length=$(( $length - $LAST_LENGTH ))
      fi
      LAST_POSITION=$position
      LAST_LENGTH=$length
      progress=`echo -n "$position $length" | awk '{ printf("%.2f", $1 / $2 * 100); }'`
      $EWW update media_progress=$progress
    else
      $EWW update media_status="󰐌"
    fi
  else
    $EWW update media_cover="$IMAGE_DIR/default.png"
    $EWW update media_title="No title"
    $EWW update media_artist="No artist"
    $EWW update media_progress=0
  fi
  sleep 0.3
done
