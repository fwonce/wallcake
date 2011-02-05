#!/bin/sh
#wallcake 1.0: download random picture online and set it as wallpaper
#fwonce <fwonce@gmail.com>
#last modified: 2011-02-01

tmp_dir=/tmp/wallcake/
tmp_pic=/tmp/wallcake/cake.jpg
wp_repo=/media/DOC/pictures/wallpapers/
query_url='http://wallbase.net/random/21/eqeq/1366x768/0/100/20'
url_base='http://wallbase.net/wallpaper/'

#handle argument
if [ $# -gt 0 ]
then
    if [ "$1" = "-s" -o "$1" = "--save-current" ]
    then
        if [ -f $tmp_pic ]
        then
            if [ $2 ]
            then
                cp $tmp_pic $wp_repo$2
                echo "save to $wp_repo$2"
            else
                echo "usage: $0 $1 filename"
            fi
        else
            echo 'no cake found'
        fi
        exit
    else
        echo "unrecognized argument: $1"
        exit
    fi
fi

#take the first random shot
find $wp_repo -type f -iregex '.*\(jpg\|png\)' -print0 |
    shuf -n1 -z |
    xargs -0 feh --bg-scale

if [ ! -d $tmp_dir ]
then
    mkdir $tmp_dir
fi

while true; do
    #idle interval
    sleep 15m

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
    curl -s -e $url_base$url_ref -L $url_pic > $tmp_pic
    feh --bg-scale $tmp_pic
done
