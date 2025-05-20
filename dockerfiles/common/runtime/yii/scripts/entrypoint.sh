#!/bin/bash

sed -i -e "s/worker_processes auto/worker_processes ${NGINX_WORKER_PROCESSES:-2}/g"  \
       -e "s/\${APP}/${APP:-undefined}/g" \
       -e "s/\${APP_ENV}/${APP_ENV:-test}/g" \
       /etc/nginx/nginx.conf

sed -i -e "s/pm = static/pm = ${FPM_PM:-static}/g"  \
       -e "s/pm.max_children = 50/pm.max_children = ${FPM_MAX_CHILDREN:-20}/g"  \
       -e "s/pm.start_servers = 20/pm.start_servers = ${FPM_START_SERVERS:-10}/g" \
       /etc/php/8.4/fpm/pool.d/www.conf
       
#chown -R www-data.www-data /app

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
