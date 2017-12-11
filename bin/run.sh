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

    if [ -n "$DOWN_AFTER_MILLISECONDS" ]; then
        sed -i "s/30000/$DOWN_AFTER_MILLISECONDS/g" $CONF
    fi
    if [ -n "$FAILOVER_TIMEOUT" ]; then
        sed -i "s/180000/$FAILOVER_TIMEOUT/g" $CONF
    fi
    if [ -n "$ANNOUNCE_PORT" ]; then
        echo "sentinel announce-port $ANNOUNCE_PORT" >> $CONF
    fi
    if [ -n "$REDIS_AUTH_PASSWORD" ]; then
        echo "sentinel auth-pass mymaster $REDIS_AUTH_PASSWORD" >> $CONF
    fi

    redis-sentinel $CONF

else
    cp /redis/config/redis.conf $CONF

    Template port "$REDIS_PORT" 6379 $CONF

	if [[ -n ${MAXMEMORY} ]]; then
	        echo "maxmemory ${MAXMEMORY}mb" >> $CONF
	fi
	if [ -n "$REDIS_AUTH_PASSWORD" ]; then
	    echo "masterauth  $REDIS_AUTH_PASSWORD" >> $CONF
	    echo "requirepass  $REDIS_AUTH_PASSWORD" >> $CONF
	fi


    if [ -n "$ANNOUNCE_IP" ]; then
        echo "slave-announce-ip $ANNOUNCE_IP" >> $CONF
    fi
    if [ -n "$ANNOUNCE_PORT" ]; then
        echo "slave-announce-port $ANNOUNCE_PORT" >> $CONF
    fi
    
    if [ -z "$MASTER" ]; then
        [[ -z "$MASTER_ADDRESS" ]] && MASTER_ADDRESS="127.0.0.1"
        [[ -z "$MASTER_PORT" ]] && MASTER_PORT=6379
        echo "slaveof $MASTER_ADDRESS $MASTER_PORT" >> $CONF
    fi

    redis-server $CONF
fi
