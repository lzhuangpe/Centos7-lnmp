#!/bin/bash

php_ini=`find /usr/local/php -type f -name "php.ini"`
php_fpm_conf=`find /usr/local/php -type f -name "php-fpm.conf"`
nginx_conf=`find /usr/local/nginx/etc/conf.d -type f -name "*.conf"`

\cp -r $php_ini $php_fpm_conf $nginx_conf .

sed -i 's/max_execution_time = 30/max_execution_time = 300/g' $php_ini
sed -i 's/;request_terminate_timeout = 0/request_terminate_timeout = 300/g' $php_fpm_conf
sed -i '/^.*fastcgi_param.*SCRIPT_FILENAME.*$/a\\tfastcgi_read_timeout 300;' $nginx_conf

grep "max_execution_time" $php_ini
grep "request_terminate_timeout" $php_fpm_conf
grep "fastcgi_read_timeout" $nginx_conf
