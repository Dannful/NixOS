#!{BASH_BIN}

IMAGE_DIR="$HOME/.config/eww/modules/music/images"
LAST_SONG=""
LAST_IMAGE=""
EWW="{EWW_BIN} -c $HOME/.config/eww/modules/music"
SCRIPT_NAME="media_info"
LOG_SCRIPT="$HOME/.config/eww/modules/scripts/log.sh"

select_player() {
  playing_player=""
  cover_player=""
  total_player=""
  playerctl -l 2> /dev/null | while read -r player;
  do
    art=`playerctl --player="$player" metadata mpris:artUrl 2> /dev/null`
    status=`playerctl --player="$player" status 2> /dev/null`
    [[ "$status" == "Playing" ]] && playing_player="$player"
    [[ ! -z $art ]] && cover_player="$player"
    [[ "$playing_player" == "$cover_player" ]] && total_player="$player"
    [[ ! -z $cover_player ]] && player="$cover_player"
    [[ ! -z $playing_player ]] && player="$playing_player"
    [[ ! -z $total_player ]] && player="$total_player"
    echo "$player"
  done
}

update_cover() {
  if [[ `echo $image | grep -c "file://"` -gt 0 ]]; then
    cp "`echo $image | sed 's/file:\/\///g'`" "$IMAGE_DIR/current_full.png"
    ffmpeg -y -i "$IMAGE_DIR/current_full.png" -vf "scale='if(gt(iw,120),iw,120)':'if(gt(ih,120),ih,120)',crop=120:120" "$IMAGE_DIR/current.png"
  else
    wget "$image" -o "/tmp/current.png"
    if [[ $? -eq 0 ]]; then
      cp "/tmp/current.png" "$IMAGE_DIR/current_full.png"
      ffmpeg -y -i "$IMAGE_DIR/current_full.png" -vf "scale='if(gt(iw,120),iw,120)':'if(gt(ih,120),ih,120)',crop=120:120" "$IMAGE_DIR/current.png"
    else
      cp "$image" "$IMAGE_DIR/current.png"
      rm -f "$IMAGE_DIR/current_full.png"
    fi
  fi
  $EWW update media_cover="$IMAGE_DIR/current.png"
}

while true; do
  if [[ ! -z `playerctl status 2> /dev/null` ]]; then
    player=`select_player 2> /dev/null | tail -1`
    status=`playerctl --player="$player" status 2> /dev/null`

    if [[ "$status" == "Playing" ]]; then
      $EWW update media_status="󰏥"

      position=`playerctl --player="$player" position | awk '{ printf("%f", $1 * 1000000) }'`
      length=`playerctl --player="$player" metadata mpris:length`
      progress=`echo -n "$position $length" | awk '{ printf("%.2f", $1 / $2 * 100); }'`
      $EWW update media_progress=$progress
    else
      $EWW update media_status="󰐌"
    fi

    title=`playerctl --player="$player" metadata xesam:title 2> /dev/null`

    if [[ ! -z "$title" ]] && [[ "$title" != "$LAST_SONG" ]]; then
      artist=`playerctl --player="$player" metadata xesam:artist 2> /dev/null`
      $EWW update media_title="$title"
      $EWW update media_artist="$artist"
    fi
    LAST_SONG="$title"

    image=`playerctl metadata mpris:artUrl 2> /dev/null`
    if [[ "$image" != "$LAST_IMAGE" ]]; then
      update_cover &
    fi
    LAST_IMAGE="$image"
  else
    $EWW update media_cover="$IMAGE_DIR/default.png"
    $EWW update media_title="No title"
  fi
  sleep 0.3
done
