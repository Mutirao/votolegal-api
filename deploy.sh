#!/bin/bash

VOTOLEGAL_API_PORT="8105"
VOTOLEGAL_API_WORKERS="4"

STARMAN_BIN="$(which starman)"
DAEMON="$(which start_server)"

line (){
    perl -e "print '-' x 40, $/";
}

mkdir -p log/

up_server (){
    PSGI_APP_NAME="$1"
    PORT="$2"
    WORKERS="$3"

    ERROR_LOG="log/votolegal.error.log"
    STATUS="log/votolegal.start_server.status"
    PIDFILE="log/votolegal.start_server.pid"

    touch $ERROR_LOG
    touch $PIDFILE
    touch $STATUS

    STARMAN="$STARMAN_BIN -Ilib --preload-app --workers $WORKERS $PSGI_APP_NAME"

    DAEMON_ARGS=" --pid-file=$PIDFILE --signal-on-hup=QUIT --status-file=$STATUS --port 0.0.0.0:$PORT -- $STARMAN"

    echo "Restarting...  $DAEMON --restart $DAEMON_ARGS"
    $DAEMON --restart $DAEMON_ARGS

    if [ $? -gt 0 ]; then
        echo "Restart failed, application likely not running. Starting..."

        echo "/sbin/start-stop-daemon -b --start --pidfile $PIDFILE --chuid $USER -u $USER --exec $DAEMON --$DAEMON_ARGS"
        /sbin/start-stop-daemon -b --start --pidfile $PIDFILE --chuid $USER -u $USER --exec $DAEMON --$DAEMON_ARGS
    fi
}

sqitch deploy -t local

echo "Restaring server...";
up_server "votolegal.psgi" $VOTOLEGAL_API_PORT $VOTOLEGAL_API_WORKERS

line

# Daemons.
./script/daemon/Emailsd restart

export DBIC_TRACE=0
