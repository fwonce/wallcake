#!/bin/sh
#wallcake 1.2: download random picture online and set it as wallpaper
#fwonce <fwonce@gmail.com>
#last modified: 2011-02-01

idle_time=15m
tmp_dir=/tmp/wallcake
tmp_pic=$tmp_dir/cake.jpg
tmp_lck=$tmp_dir/.lock
wp_repo=/media/DOC/pictures/wallpapers
query_url='http://wallbase.net/random/21/eqeq/1366x768/0/100/20'
url_base='http://wallbase.net/wallpaper/'

#handle argument
while getopts s:i:r:h option; do
    case "$option" in
    s)
        if [ -f $tmp_lck ]; then
            echo "new wallpaper being applied, can't save previous one."
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
    r)
        if [ ! -d $OPTARG ]; then
            echo "Not a directory: $OPTARG"
            exit 1
        else
            wp_repo=$OPTARG
        fi
        ;;
    h)
        echo "Wallcake v1.0 retrives wallpapers from wallbase.net automatically"
        echo ""
        echo "-s new_name"
        echo "   save current wallpaper"
        echo "-i idle_time"
        echo "   idle time after wallpaper changed"
        echo "-r directory"
        echo "   directory in which the selected wallpaper will be saved (when -s is applied)"
        exit 0
        ;;
    esac
done

#take the first random shot
find $wp_repo -type f -iregex '.*\(jpg\|png\)' -print0 |
    shuf -n1 -z |
    xargs -0 feh --bg-scale

if [ ! -d $tmp_dir ]; then
    mkdir $tmp_dir
fi

while true; do
    #idle time
    sleep $idle_time
    ping_result=`ping -c 1 wallbase.net |
            grep 'from' |
            wc -l`
    if [ $ping_result -eq 0 ]; then
        echo "Network unavailable, will try $idle_time later."
        continue
    fi

    #wallbase.net random SFW wallpapers
    seed=`rand -M 20`
    url_ref=`curl -s -L $query_url |
            grep -m$seed 'div class="thumb"' |
            tail -n 1 |
            sed "s/[^0-9]*\([0-9]\+\).*/\1/"`
    url_pic=`curl -s -L $url_base$url_ref |
            grep -m1 'rozne' |
            sed "s/[^']\+'\(http[^']*\)'.*/\1/"`

    #finally start to download the picture
    touch $tmp_lck
    curl -s -e $url_base$url_ref -L $url_pic > $tmp_pic
    rm $tmp_lck
    feh --bg-scale $tmp_pic
done
