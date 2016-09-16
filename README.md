REDIS KUBERNETES CLUSTER
========================

## How to choose redis or sentinel
**$SENTINEL** set to 1. Run application as sentinel. If SENTINEL doesn't set, application will be run as Redis server.
**$MASTER** set to 1. Run application as redis master.

## Sentinel ENV Variables

**$MASTER_NAME** master name (default: mymaster)  
**$MASTER_IP** master ip (default: 127.0.0.1)  
**$MASTER_PORT** master port (default: 6379)  
**$QUORUM** how many sentinels cluster needed to get dision (default: mymaster)  
**$SENTINEL** sentinel port (default: 26379)  
**$ANNOUNCE_IP** sentinel announce ip (option variable)  
**$ANNOUNCE_PORT** sentinel announce port (option variable)  

## Redis ENV Variables

**$REDIS_PORT** redis port (default: 6379)  

### Redis as slave variables

**$MASTER_ADDRESS** master ip address (default: 127.0.0.1)  
**$MASTER_PORT** master port (default: 6379)  
**$ANNOUNCE_IP** redis slave announce ip (option variable)  
**$ANNOUNCE_PORT** redis slave announce port (option variable)  
