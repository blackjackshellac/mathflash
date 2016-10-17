#!/bin/bash

ME=$(basename $0)
MD=$(dirname $0)
cd $MD
MD=$(pwd)
cd -

info() {
	echo -e "$*"
}

err() {
	info "Error: $*"
}

die() {
	err $*
	exit 1
}

TMP="/var/tmp/dataserver"
NOW=$(date +%Y%m%d)
LOG="$TMP/dataserver.${NOW}.log"
DS="${MD}/dataserver.rb"
[ ! -x "$DS" ] && die "Cannot execute ${DS}"
echo "Running $DS"
echo "  Logging to $LOG"
nohup $DS >> $LOG 2>&1 &
