#!/bin/sh
# V2Ray generate configuration
# Download and install V2Ray
# export PROTOCOL=vmess
# export UUID=da311aae-045f-4bf8-b73a-2227d336021a
# export WS_PATH=112233
# export PORT=1234
config_path=$PROTOCOL"_ws_tls.json"
envsubst '\$UUID,\$WS_PATH' < /$config_path > /usr/local/etc/v2ray/config.json

cat >/usr/local/etc/alist/config.json <<EOF
{
  "assets": "/",
  "database": {
    "type": "$ADATABASE",
    "user": "$BSQLUSER",
    "password": "$CSQLPASSWORD",
    "host": "$DSQLHOST",
    "port": $ESQLPORT,
    "name": "$FSQLNAME",
    "table_prefix": "x_",
    "db_file": "/alist/config/data.db"
  },
  "scheme": {
    "https": false,
    "cert_file": "",
    "key_file": ""
  },
  "cache": {
    "expiration": $GEXPIRATION,
    "cleanup_interval": $HCLEANUP_INTERVAL
  },
  "temp_dir": "/alist/config/temp"
}
EOF


# MK TEST FILES
mkdir /opt/test
cd /opt/test
dd if=/dev/zero of=10mb.bin bs=10M count=1

# Run alist
/usr/local/bin/alist -conf /usr/local/etc/alist/config.json &
# Run V2Ray
/usr/local/bin/v2ray -config /usr/local/etc/v2ray/config.json &
# Run nginx
/bin/ash -c "envsubst '\$PORT,\$WS_PATH' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon off;'
