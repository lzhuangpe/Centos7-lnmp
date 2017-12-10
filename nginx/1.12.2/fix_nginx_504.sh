#!/bin/bash

sed -n 's/max_execution_time = 30/max_execution_time = 300/gp' /usr/local/php/etc/php.ini
sed -n 's/;request_terminate_timeout = 0/request_terminate_timeout = 300/gp' /usr/local/php/etc/php-fpm.conf
find /usr/local/nginx/etc/conf.d/ -name "*.conf" | xargs -i sed -n '/^.*fastcgi_param.*SCRIPT_FILENAME.*$/a\\tfastcgi_read_timeout 300;' {}

