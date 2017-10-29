#!/bin/bash

nginx_location=/usr/local/nginx
nginx_ver=nginx-1.12.2
user_name=www-nginx

#创建用户
groupadd $user_name
useradd -s /sbin/nologin -g $user_name $user_name

#创建目录
mkdir -p $nginx_location/etc/conf.d
mkdir -p $nginx_location/sbin
mkdir -p $nginx_location/modules
mkdir -p $nginx_location/log
mkdir -p $nginx_location/html/default
mkdir -p /var/cache/nginx


#安装依赖
yum install -y gcc gcc-c++ autoconf \
    pcre-devel openssl-devel libxml2-devel libxslt-devel gd-devel \
    perl-devel perl-ExtUtils-Embed GeoIP-devel

#下载安装包
wget -c http://nginx.org/download/$nginx_ver.tar.gz
tar -zxf $nginx_ver.tar.gz
cd $nginx_ver

#配置编译参数
./configure --prefix=$nginx_location \
    --sbin-path=$nginx_location/sbin --modules-path=$nginx_location/modules \
    --conf-path=$nginx_location/etc/nginx.conf \
    --user=$user_name --group=$user_name \
    --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock \
    --error-log-path=$nginx_location/log/error.log --http-log-path=$nginx_location/log/access.log \
    --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module \
    --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module \
    --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module \
    --with-http_auth_request_module --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic --with-http_geoip_module=dynamic \
    --with-http_perl_module=dynamic --with-threads --with-stream --with-stream_ssl_module \
    --with-stream_ssl_preread_module --with-stream_realip_module --with-stream_geoip_module=dynamic --with-http_slice_module \
    --with-mail --with-mail_ssl_module --with-compat --with-file-aio --with-http_v2_module

#编译安装
make -j `grep processor /proc/cpuinfo` |wc -l
make install

#拷贝配置文件
\cp -f ../conf/nginx.conf /$nginx_location/etc/nginx.conf
\cp -f ../conf/default.conf /$nginx_location/etc/conf.d/default.conf

#配置开机启动
\cp ../init.d/init.d.nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx
chkconfig nginx on
/etc/init.d/nginx start

