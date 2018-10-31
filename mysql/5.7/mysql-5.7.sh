mysql_ver=mysql-5.7.24-linux-glibc2.12-x86_64
mysql_location=/usr/local/mysql
user_name=mysql

# 删除系统自带的数据库
yum remove -y mariadb-libs

# 创建用户
groupadd ${user_name}
useradd -s /sbin/nologin -g ${user_name} ${user_name}


# 下载安装包
wget https://mirror.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-5.7/${mysql_ver}.tar.gz
tar -zxf ${mysql_ver}.tar.gz
mv ${mysql_ver} ${mysql_location}
mkdir -p ${mysql_location}/{log,binglog,run}
chown -R mysql:mysql ${mysql_location}/{log,binglog,run}
\cp -f ./conf/my.cnf /etc/my.cnf

# 初始化数据库
${mysql_location}/bin/mysqld --initialize-insecure \
    --user=mysql \
    --basedir=${mysql_location} \
    --datadir=${mysql_location}/data \

# 设置开机启动
\cp -f ${mysql_location}/support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
chkconfig mysqld on
/etc/init.d/mysqld start


# 设置环境变量
cat >> /etc/profile <<EOF
export PATH=$PATH:${mysql_location}/bin
EOF
source /etc/profile



