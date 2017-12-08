#!/bin/bash

yum install libmcrypt libmcrypt-devel mcrypt mhash -y
cd php-5.6.31/ext/mcrypt/
phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
echo extension="mcrypt.so" >/usr/local/php/etc/conf.d/mcrypt.ini
/etc/init.d/php-fpm restart
/etc/init.d/nginx restart

