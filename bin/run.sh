#!/usr/bin/env bash

set -e

#$1 - parameter; $2 - value; $3 - default value; $4 - file;
Template() {
    [[ -z "$2" ]] &&  sed -i "s/{{ $1 }}/$3/g" $4 || sed -i "s/{{ $1 }}/$2/g" $4
}

CONF="/redis/config/config.conf"
if [ -n "$SENTINEL" ]; then
    cp /redis/config/sentinel.conf $CONF

    dockerize -wait tcp://$MASTER_IP:6379

    Template master_name "$MASTER_NAME" mymaster $CONF
    Template master_ip "$MASTER_IP" 127.0.0.1 $CONF
    Template master_port "$MASTER_PORT" 6379 $CONF
    Template quorum "$QUORUM" 2 $CONF
    Template port "$SENTINEL_PORT" 26379 $CONF

    if [ -n "$ANNOUNCE_IP" ]; then
        echo "sentinel announce-ip $ANNOUNCE_IP" >> $CONF
    fi
    if [ -n "$ANNOUNCE_PORT" ]; then
        echo "sentinel announce-port $ANNOUNCE_PORT" >> $CONF
    fi

    redis-sentinel $CONF
else
    cp /redis/config/redis.conf $CONF

    Template port "$REDIS_PORT" 6379 $CONF

    if [ -z "$MASTER" ]; then
        if [ -n "$ANNOUNCE_IP" ]; then
            echo "slave-announce-ip $ANNOUNCE_IP" >> $CONF
        fi
        if [ -n "$ANNOUNCE_PORT" ]; then
            echo "slave-announce-port $ANNOUNCE_PORT" >> $CONF
        fi
        [[ -z "$MASTER_ADDRESS" ]] && MASTER_ADDRESS="127.0.0.1"
        [[ -z "$MASTER_PORT" ]] && MASTER_PORT=6379
        echo "slaveof $MASTER_ADDRESS $MASTER_PORT" >> $CONF
    fi

    redis-server $CONF
fi