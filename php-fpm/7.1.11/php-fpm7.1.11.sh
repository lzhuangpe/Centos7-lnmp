#!/bin/bash

user_name=www-php
php_location=/usr/local/php
php_ver=php-7.1.11
bin_path=/usr/bin

echo "安装扩展"
yum install -y gcc gcc-c++ autoconf \
    libxml2-devel openssl-devel pcre-devel libcurl-devel libedit-devel \
    libpng-devel libjpeg-devel freetype-devel \
    gettext-devel openldap-devel \

# 解决 error: Cannot find ldap libraries in /usr/lib
#cp -frp /usr/lib64/libldap* /usr/lib/
ln -sf /usr/lib64/liblber.so /usr/lib/liblber.so
ln -sf /usr/lib64/libldap.so /usr/lib/libldap.so
ln -sf /usr/lib64/libldap_r.so /usr/lib/libldap_r.so
ln -sf /usr/lib64/libslapi.so /usr/lib/libslapi.so

echo "创建用户"
groupadd $user_name
useradd -s /sbin/nologin -g $user_name $user_name

echo "创建PHP目录"
mkdir -p $php_location/etc/conf.d

echo "准备安装PHP"
wget -c http://cn2.php.net/distributions/$php_ver.tar.gz
tar -zxf $php_ver.tar.gz
cd $php_ver

echo "编译参数"
./configure --prefix=$php_location \
    --with-config-file-path=$php_location/etc --with-config-file-scan-dir=$php_location/etc/conf.d \
    --enable-fpm --with-fpm-user=$user_name --with-fpm-group=$user_name \
    --disable-cgi \
    --enable-ftp --enable-mbstring --with-curl --with-libedit --with-openssl --with-zlib \
    --enable-mysqlnd --with-mysql --with-mysqli --with-pdo-mysql \
    --with-pcre-regex \
    --enable-opcache \
    --with-gd --with-png-dir --with-jpeg-dir --with-freetype-dir \
    --enable-bcmath --enable-ctype --enable-sockets --with-gettext --with-ldap

echo "编译安装"
make -j `grep processor /proc/cpuinfo |wc -l` zend_extra_libs='-liconv'
make install

echo "链接php_bin"
ln -sf $php_location/bin/php $bin_path/php
ln -sf $php_location/bin/phpize $bin_path/phpize
ln -sf $php_location/bin/pear $bin_path/pear
ln -sf $php_location/bin/pecl $bin_path/pecl

echo "复制新的php配置文件"
\cp php.ini-production $php_location/etc/php.ini
\cp $php_location/etc/php-fpm.conf.default $php_location/etc/php-fpm.conf
\cp $php_location/etc/php-fpm.d/www.conf.default $php_location/etc/php-fpm.d/www.conf

echo "修改配置文件"
sed -i 's/;date.timezone =.*/date.timezone = PRC/g' $php_location/etc/php.ini
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' $php_location/etc/php.ini

cat >$php_location/etc/conf.d/opcache.ini<<EOF
[Zend Opcache]
zend_extension="opcache.so"
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=1
opcache.enable=1
EOF

echo "配置pear pecl"
pear config-set php_ini /usr/local/php/etc/php.ini
pecl config-set php_ini /usr/local/php/etc/php.ini

echo "复制php-fpm init.d 文件"
\cp ./sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm

echo "设置开机启动"
chkconfig php-fpm on
/etc/init.d/php-fpm start

