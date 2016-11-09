#!/bin/sh

# Settings, change these values to match your developmnt needs.
# Name of the database, typically justhost-username_dbuser
DATABASE_USR='jhuser_html'
# Name of the database, typically justhost-username_dbname
DATABASE_DB='jhuser_html' 
# Users Password
DATABASE_USR_PWD='lamepassword'  # Seriously change this!
# DB ROOT Password
DATABASE_ROOT_PWD="abadpassword"  #  Seriously change this as well!!

# System settings, don't change these unless you know what you are doing!
YUM="sudo yum -y"
SYSD="sudo service"
NULL="/dev/null"
HTTPD_CONF="/opt/rh/httpd24/root/etc/httpd/conf/httpd.conf"
DOC_ROOT="/opt/rh/httpd24/root/var/www"
PHP_CONF="/etc/opt/rh/rh-php56/php.ini"
LOG_DIR="/var/log/vagrant_provision/"


echo "Making Log Folder in $LOG_DIR"
sudo mkdir -p $LOG_DIR

echo "Disabling SELINUX"
sudo sed -i 's/SELINUX=en.*/SELINUX=disabled/' /etc/selinux/config

echo "Installing Packages (This will take a while....)"
echo "Installing extra repos"
$YUM install epel-release centos-release-scl | sudo tee $LOG_DIR/extra_repos.log
echo "Installing extra packages"
$YUM install httpd24-httpd nano rh-php56-php rh-php56-php-gd \
rh-php56-php-xml rh-php56-php-opcache rh-php56-php-pdo rh-php56-php-mysql \
   wget npm | sudo tee $LOG_DIR/packages.log
sudo ln -s /opt/rh/rh-php56/enable /etc/profile.d/php.sh
sudo npm install bower

echo "Installing Percona Server 5.5.42.37.1"
sudo wget -q https://www.percona.com/downloads/Percona-Server-5.5/Percona-Server-5.5.42-37.1/binary/redhat/6/x86_64/Percona-Server-shared-55-5.5.42-rel37.1.el6.x86_64.rpm
sudo wget -q https://www.percona.com/downloads/Percona-Server-5.5/Percona-Server-5.5.42-37.1/binary/redhat/6/x86_64/Percona-Server-server-55-5.5.42-rel37.1.el6.x86_64.rpm
sudo wget -q https://www.percona.com/downloads/Percona-Server-5.5/Percona-Server-5.5.42-37.1/binary/redhat/6/x86_64/Percona-Server-client-55-5.5.42-rel37.1.el6.x86_64.rpm
$YUM install Percona-Server-shared-55-5.5.42-rel37.1.el6.x86_64.rpm \
  Percona-Server-server-55-5.5.42-rel37.1.el6.x86_64.rpm \
  Percona-Server-client-55-5.5.42-rel37.1.el6.x86_64.rpm | sudo \
    tee $LOG_DIR/sql.log
sudo rm Percona-Server-shared-55-5.5.42-rel37.1.el6.x86_64.rpm \
  Percona-Server-server-55-5.5.42-rel37.1.el6.x86_64.rpm \
  Percona-Server-client-55-5.5.42-rel37.1.el6.x86_64.rpm

echo "Installing Drush"
sudo wget https://ftp.drupal.org/files/projects/drush-8.x-6.0-rc4.tar.gz
sudo tar xf drush-8.x-6.0-rc4.tar.gz -C /usr/local/share
sudo ln -s /usr/local/share/drush/drush /bin/drush
sudo -i drush

echo "Change httpd User and setup PHP/HTTPD"
sudo sed -i 's/User apache/User vagrant/' $HTTPD_CONF
sudo sed -i 's/Group apache/Group vagrant/' $HTTPD_CONF
sudo sed -i '151s/Allow.*/AllowOverride All/' $HTTPD_CONF
sudo sed -i 's/\;date.timezone.*/date.timezone=\"UTC\"/' $PHP_CONF

echo "Link vagrant to Document Root"
sudo rm -rf $DOC_ROOT
sudo ln -s /vagrant $DOC_ROOT

echo "Configuring SQL Server"
sudo service mysql start
sudo mysql -e \
 "UPDATE mysql.user SET Password = PASSWORD('$basic') WHERE User = 'root'"
sudo mysql -e "DROP USER ''@'localhost'"
sudo mysql -e "DROP DATABASE test"
sudo mysql -e "CREATE DATABASE $DATABASE_DB"
sudo mysql -e "CREATE USER '$DATABASE_USR'@'localhost' IDENTIFIED BY '$DATABASE_USR_PWD'"
sudo mysql -e "GRANT ALL PRIVILEGES ON $DATABASE_DB.* TO '$DATABASE_USR'@'localhost'"
sudo mysql -e "FLUSH PRIVILEGES"
sudo service mysql stop

echo "Enabling Services"
sudo chkconfig httpd24-httpd on 67
sudo chkconfig mysql on 67
