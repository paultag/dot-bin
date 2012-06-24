#!/bin/bash

CUR=~/.mutt.login.curptr

if [ "x$1" == "x" ]; then
    echo "Need a mailbox."
    exit 2
fi

if [ -e $CUR ]; then
    rm $CUR
fi

if [ ! -e ~/Dropbox/mutt/$1 ]; then
    echo "Not a vaild account."
    exit 1
fi

ln -s ~/Dropbox/mutt/$1 $CUR
mutt
