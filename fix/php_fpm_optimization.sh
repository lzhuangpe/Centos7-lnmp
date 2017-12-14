#!/bin/bash

Mem=`free -m | awk '/Mem/ {print $2}'`
PHP_install_dir=/usr/local/php

sed -i "s@^;rlimit_files.*@rlimit_files = 51200@" $PHP_install_dir/etc/php-fpm.conf
sed -i "s@^pm =.*@pm = dynamic@" $PHP_install_dir/etc/php-fpm.conf
sed -i "s@^pm.max_children.*@pm.max_children = $[$Mem/2/20]@" $PHP_install_dir/etc/php-fpm.conf
sed -i "s@^pm.start_servers.*@pm.start_servers = $[$Mem/2/30]@" $PHP_install_dir/etc/php-fpm.conf
sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = $[$Mem/2/40]@" $PHP_install_dir/etc/php-fpm.conf
sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = $[$Mem/2/20]@" $PHP_install_dir/etc/php-fpm.conf

grep -e "^rlimit_files" $PHP_install_dir/etc/php-fpm.conf
grep -e "^pm =" $PHP_install_dir/etc/php-fpm.conf
grep -e "^pm.max_children" $PHP_install_dir/etc/php-fpm.conf
grep -e "^pm.start_servers" $PHP_install_dir/etc/php-fpm.conf
grep -e "^pm.min_spare_servers" $PHP_install_dir/etc/php-fpm.conf
grep -e "^pm.max_spare_servers" $PHP_install_dir/etc/php-fpm.conf
