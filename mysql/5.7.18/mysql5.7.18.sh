mysql_ver=mysql-5.7.18-linux-glibc2.5-x86_64
mysql_location=/usr/local/mysql
user_name=mysql

# 删除系统自带的数据库
yum remove -y mariadb-libs

# 安装epel
yum install -y epel-release && \
sed -e 's!^mirrorlist=!#mirrorlist=!g' \
    -e 's!^#baseurl=!baseurl=!g' \
    -e 's!//download\.fedoraproject\.org/pub!//mirrors.ustc.edu.cn!g' \
    -e 's!http://mirrors\.ustc!https://mirrors.ustc!g' \
    -i /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel-testing.repo

# 安装依赖
yum install -y aria2 libaio autoconf
#autoconf

# 创建用户
groupadd $user_name
useradd -s /sbin/nologin -g $user_name $user_name


# 下载安装包
aria2c -x 16 http://mirrors.sohu.com/mysql/MySQL-5.7/$mysql_ver.tar.gz
tar -zxf $mysql_ver.tar.gz
mv $mysql_ver $mysql_location
mkdir -p $mysql_location/{data,log,binglog,etc,run}
chown -R mysql:mysql $mysql_location/{data,log,binglog,etc,run}

# 初始化数据库
$mysql_location/bin/mysqld --initialize-insecure \
    --user=mysql \
    --basedir=$mysql_location \
    --datadir=$mysql_location/data \

# 设置开机启动
\cp -f $mysql_location/support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
chkconfig mysqld on
/etc/init.d/mysqld start


# 设置环境变量
cat >> /etc/profile <<EOF
export PATH=$PATH:/usr/local/mysql/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/mysql/lib
EOF
source /etc/profile



