#!/bin/bash
#title :jboss-install.sh
#description :The script to install JBOSS-6.4
#JDK-1.7.0_60
#usage :/bin/bash jboss-install.sh
clear
echo "JBOSS INSTALLATION BEGINS ..."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
 
JDK_NAME=jdk-7u60-linux-x64.rpm
JDK_VERSION=jdk1.7.0_60
HOST_IP=`/sbin/ifconfig eth0 | grep "inet" | awk '{print $2}' | awk 'NR==1' | cut -d':' -f2`
JBOSS_HOME=/usr/share/jboss-eap
JBOSS_PACK=jboss-eap
JBOSS_VERSION=$JBOSS_PACK-6.4.0
JBOSS_EXE=/etc/init.d/jboss
JBOSS_SERVICE_CONF=/etc/jboss-as/jboss-as.conf

JBOSS_PATH=/usr/share
JBOSS_USER=jboss
JBOSS_STARTUP_WAIT=240
JBOSS_SHUTDOWN_WAIT=30
 
if [ -f "rpm -qa | grep glibc" ]; then
yum install glibc.i686 -y
fi
if [ -f "rpm -qa | grep libgcc" ]; then
yum install libgcc-* -y
fi
 
if [ -f "/usr/java/jdk" ]; then
echo "JAVA already installed"
else
 
#prerequisites packages - JDK INSTALLATION
 
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "https://download.oracle.com/otn/java/jdk/7u60-b19/jdk-7u60-linux-x64.rpm" -O /root/$JDK_NAME
        rpm -ivh /root/$JDK_NAME
        export JAVA_HOME=/usr/java/$JDK_VERSION
        export JAVA_HOME  
        PATH=$JAVA_HOME/bin:$PATH
        export PATH  
        echo "JAVA_HOME=/usr/java/$JDK_VERSION" >> /root/.bash_profile
        echo "export JAVA_HOME" >> /root/.bash_profile
        echo 'PATH=$JAVA_HOME/bin:$PATH' >> /root/.bash_profile
        echo "export PATH" >> /root/.bash_profile
fi
### JBOSS INSTALLATION ###
#Create User
groupadd $JBOSS_USER
useradd -s /bin/bash -g $JBOSS_USER $JBOSS_USER
chown -Rf $JBOSS_USER.$JBOSS_USER $JBOSS_USER
 
#       #JAVA PATH
        export JAVA_HOME=/usr/java/$JDK_VERSION
        export JAVA_HOME  
        PATH=$JAVA_HOME/bin:$PATH
        export PATH  
        echo "JAVA_HOME=/usr/java/$JDK_VERSION" >> /home/$JBOSS_USER/.bash_profile
        echo "export JAVA_HOME" >> /home/$JBOSS_USER/.bash_profile
        echo 'PATH=$JAVA_HOME/bin:$PATH' >> /home/$JBOSS_USER/.bash_profile
        echo "export PATH" >> /home/$JBOSS_USER/.bash_profile
 
#DOWNLOAD AND EXTRACT
 
#wget http://download.jboss.org/jbossas/7.1/$JBOSS_VERSION/$JBOSS_VERSION.zip -P $JBOSS_PATH
#https://developers.redhat.com/download-manager/file/jboss-eap-6.4.0.GA.zip
wget https://developers.redhat.com/download-manager/file/$JBOSS_VERSION.GA.zip -P $JBOSS_PATH
unzip  $JBOSS_PATH/$JBOSS_VERSION.GA.zip -d $JBOSS_PATH/
mv $JBOSS_VERSION.0 $JBOSS_PACK
chown -R $JBOSS_USER:$JBOSS_USER $JBOSS_HOME
cp $JBOSS_HOME/bin/init.d/jboss-as-standalone.sh $JBOSS_EXE
chmod +x $JBOSS_EXE
mkdir /etc/jboss-as && touch $JBOSS_SERVICE_CONF
if [ ! -z "$JBOSS_SERVICE_CONF" ]; then
echo "Configuring service..."
echo "JBOSS_HOME=$JBOSS_HOME"  >> $JBOSS_SERVICE_CONF
echo "JBOSS_USER=$JBOSS_USER" >> $JBOSS_SERVICE_CONF
echo "STARTUP_WAIT=$JBOSS_STARTUP_WAIT" >> $JBOSS_SERVICE_CONF
echo "SHUTDOWN_WAIT=$JBOSS_SHUTDOWN_WAIT" >> $JBOSS_SERVICE_CONF
fi
 
#CONFIGURE JBOSS STARTUP SCRIPT
sed -i "/\export JAVA_HOME/a JBOSS_USER=jboss" $JBOSS_EXE
sed -i "/\JBOSS_USER=jboss/a export JBOSS_USER" $JBOSS_EXE
sed -i "s/# chkconfig: - 80 20/# chkconfig: 234 80 20/g" $JBOSS_EXE
sed -i "s/jboss.bind.address:127.0.0.1/jboss.bind.address:$HOST_IP/g" $JBOSS_HOME/standalone/configuration/standalone.xml
 
#Start Service
$JBOSS_EXE start
 
#JBOSS SERVICE CHECK
netstat -anp | grep 8080
 
HOST_IP=`/sbin/ifconfig eth0 | grep "inet" | awk '{print $2}' | awk 'NR==1'`
HOST_IP=`/sbin/ifconfig eth0 | grep "inet" | awk '{print $2}' | awk 'NR==1' | cut -d':' -f2`
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "#JBOSS SERVER INSTALLED SUCCESSFULLY    #"                           
echo "# JBOSS Access at http://$HOST_IP:8080  #"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Note:"
echo "Do you want to Running JBoss on Port 80, run the below commands"
echo "iptables -t nat -A PREROUTING -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 8080"
echo "iptables -t nat -A PREROUTING -p udp -m udp --dport 80 -j REDIRECT --to-ports 8080"
echo "done..."
