#!/bin/sh -x
# vim:set sts=2 sw=2 et:
#wallcake 1.2: download random picture online and set it as wallpaper
#fwonce <fwonce@gmail.com>
#last modified: 20 Feb 2017

source ./config.sh

# temp folders
tmp_dir=/tmp/wallcake
tmp_pic=$tmp_dir/cake.jpg
tmp_lck=$tmp_dir/.lock

#handle argument
while getopts s:i:r:h option; do
  case "$option" in
  h)
    echo "Wallcake refreshes your wallpaper randomly using wallhaven.cc"
    echo ""
    echo "-s new_name"
    echo "   save current wallpaper"
    echo "-i idle_time"
    echo "   idle time after wallpaper changed"
    exit 0
    ;;
  s)
    if [ -f $tmp_lck ]; then
      echo "new wallpaper downloading, can't save the current one."
      exit 1
    else
      cp -iv $tmp_pic $wp_repo/$OPTARG.jpg
      exit 0
    fi
    ;;
  i)
    #TODO verify NUMBER, see info coreutils 'sleep invocation'
    idle_time=$OPTARG
    ;;
  esac
done

#take the first random shot
#find $wp_repo -type f -iregex '.*\(jpg\|png\)' -print0 | \
  #shuf -n1 -z | \
  #xargs -0 feh --bg-scale;

if [ ! -d $tmp_dir ]; then
  mkdir $tmp_dir
fi
if [ ! -d $wp_repo ]; then
  mkdir $wp_repo
fi

while true; do
  ping_result=`ping -c 1 wallhaven.cc | grep -c 'from'`
  if [ $ping_result -eq 0 ]; then
    echo "Network unavailable, will try $idle_time later."
    continue
  fi

  #random SFW wallpapers
  seed=`echo $(($RANDOM % $page_size + 1))`
  detail_url=`curl --silent --location $query_url | \
    egrep -o 'https://alpha.wallhaven.cc/wallpaper/\d+' | \
    uniq | sed -n '15 p'
  pic_url="https:"`curl --silent --location '$detail_url' | \
    egrep -o '//wallpapers.wallhaven.cc/wallpapers/full/wallhaven-\d+.jpg' | \
    uniq | head -1

  #finally start to download the picture
  touch $tmp_lck
  curl -s -L $pic_url > $tmp_pic
  rm $tmp_lck
  #feh --bg-scale $tmp_pic
  #idle time
  sleep $idle_time
done

