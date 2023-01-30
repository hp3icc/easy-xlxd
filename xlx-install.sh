#!/bin/bash
clear
read -p "press N for new XLXD installation, or R to refresh and modify current installation  :" INSTA
echo ""
echo "--------------------------------------"
echo ""
echo "XLX uses 3 digit numbers for its reflectors. For example: 032, 999, 099."
read -p "What 3 digit XRF number will you be using?  " XRFDIGIT
XRFNUM=XLX$XRFDIGIT
echo ""
echo "--------------------------------------"
read -p "What is the FQDN of the XLX Reflector dashboard? Example: xlx.domain.com.  " XLXDOMAIN
echo ""
echo "--------------------------------------"
read -p "select dashboard style 1 or 2   :" DASH
echo ""
echo "--------------------------------------"
read -p "What contrie your server?  " CONTRIE
echo ""
echo "--------------------------------------"
read -p "description your server?  " DESCRIPTION
echo ""
echo "--------------------------------------"
read -p "# modules sample 10  :" NMODU
echo ""
echo "--------------------------------------"
read -p "# defauld YSF module sample B  :" YSFMODU
echo ""
echo "--------------------------------------"
read -p "ysf port sample defauld 42000  :" YSFPOR
echo ""
echo "--------------------------------------"
read -p "ambe server addres sample defauld 127.0.0.1  :" AMBIP
echo ""
echo "--------------------------------------"
read -p "ambe server port sample defauld 10100  :" AMBPOR
echo ""
echo "--------------------------------------"
read -p "What E-Mail address can your users send questions to?  " EMAIL
echo ""
echo "--------------------------------------"
read -p "What is the admins callsign?  " CALLSIGN
echo ""
echo "--------------------------------------"
read -p "Activate XLXD Reflector? select Y or N  : " ACTIXLX
echo ""
echo "--------------------------------------"
echo ""
echo ""
echo "------------------------------------------------------------------------------"
echo "Making install directories and installing dependicies...."
echo "------------------------------------------------------------------------------"
###########################################################
if [ -z "$INSTA" ]
then INSTA=0
fi
if [ $INSTA = R ]
then
    cp /xlxd/xlxd.blacklist /tmp/xlxd.blacklist
    cp /xlxd/xlxd.terminal /tmp/xlxd.terminal
    cp /xlxd/callinghome.php /tmp/callinghome.php
    cp /xlxd/xlxd.interlink  /tmp/xlxd.interlink
    cp /xlxd/xlxd.whitelist /tmp/xlxd.whitelist
    service xlxd stop
elif [ $INSTA = r ]
then
    cp /xlxd/xlxd.blacklist /tmp/xlxd.blacklist
    cp /xlxd/xlxd.terminal /tmp/xlxd.terminal
    cp /xlxd/callinghome.php /tmp/callinghome.php
    cp /xlxd/xlxd.interlink  /tmp/xlxd.interlink
    cp /xlxd/xlxd.whitelist /tmp/xlxd.whitelist
    service xlxd stop
fi
#
if [ -f "/etc/init.d/xlxd" ]
then
   service xlxd stop
 #echo "found file"

fi
if [ -f "/etc/init.d/xlxd" ]
then
   rm /etc/init.d/xlxd
 #echo "found file"

fi
if [ -d "/root/reflector-install-files" ]
then
   rm -r /root/reflector-install-files/
 #echo "found file"

fi
if [ -d "/root/xlxd" ]
then
   rm -r /root/xlxd/
 #echo "found file"

fi
if [ -d "/xlxd" ]
then
   rm -r /xlxd/
 #echo "found file"

fi
if [ -d "/opt/xlxd" ]
then
   rm -r /opt/xlxd/
 #echo "found file"

fi
if [ -d "/var/www/xlxd" ]
then
   rm -r /var/www/xlxd/
 #echo "found file"

fi
apt update
#
WHO=$(whoami)
if [ "$WHO" != "root" ]
then
  echo ""
  echo "You Must be root to run this script!!"
  exit 0
fi
if [ ! -e "/etc/debian_version" ]
then
  echo ""
  echo "This script is only tested in Debian 9 and x64 cpu Arch. "
  exit 0
fi

DEP="git build-essential apache2 php libapache2-mod-php php7.0-mbstring"
DEP2="git build-essential apache2 php libapache2-mod-php php7.3-mbstring"
DEP3="git build-essential apache2 php libapache2-mod-php php7.4-mbstring"
VERSION=$(sed 's/\..*//' /etc/debian_version)

if [ $VERSION = 9 ]
then
    apt-get -y install $DEP
    a2enmod php7.0
elif [ $VERSION = 10 ]
then
    apt-get -y install $DEP2
elif [ $VERSION = 11 ]
then
    apt-get -y install $DEP3
fi
###################################################
if [ -z "$XRFDIGIT" ] 
then XRFDIGIT=000

fi
XRFNUM=XLX$XRFDIGIT
if [ -z "$XLXDOMAIN" ]
then XLXDOMAIN=localhost

fi
if [ -z "$CONTRIE" ]
then CONTRIE=Test

fi
if [ -z "$DESCRIPTION" ]
then DESCRIPTION=XLXD_Reflector_Test

fi
if [ -z "$NMODU" ]
then NMODU=10

fi
if [ -z "$YSFMODU" ]
then YSFMODU=B

fi
if [ -z "$YSFPOR" ]
then YSFPOR=42000

fi
if [ -z "$AMBIP" ]
then AMBIP=127.0.0.1

fi
if [ -z "$AMBPOR" ]
then AMBPOR=10100

fi
if [ -z "$EMAIL" ]
then EMAIL=Put_you_email

fi
if [ -z "$CALLSIGN" ]
then CALLSIGN=LX1IQ

fi
###################################################
echo "------------------------------------------------------------------------------"
cd /opt
git clone https://github.com/LX3JL/xlxd.git
cd xlxd/src/

   echo "------------------------------------------------------------------------------"
  
#
sudo sed -i "s/define NB_OF_MODULES                   10/define NB_OF_MODULES                   $NMODU/g"  /opt/xlxd/src/main.h
sudo sed -i "s/define YSF_PORT                        42000/define YSF_PORT                        $YSFPOR/g"  /opt/xlxd/src/main.h
sudo sed -i "s/define YSF_AUTOLINK_ENABLE             0/define YSF_AUTOLINK_ENABLE             1/g"  /opt/xlxd/src/main.h
sudo sed -i "s/MODULE             'B'/MODULE             '$YSFMODU'/g"  /opt/xlxd/src/main.h
sudo sed -i "s/437000000/434000000/g"  /opt/xlxd/src/main.h
sudo sed -i "s/TRANSCODER_PORT                 10100/TRANSCODER_PORT                 $AMBPOR/g"  /opt/xlxd/src/main.h

#
   make clean
   make
   make install
#
XLXINSTDIR=/opt/
LOCAL_IP=$(ip a | grep inet | grep "eth0\|en" | awk '{print $2}' | tr '/' ' ' | awk '{print $1}')
INFREF=https://n5amd.com/digital-radio-how-tos/create-xlx-xrf-d-star-reflector/
cho "------------------------------------------------------------------------------"
echo "Getting the DMRID.dat file... "
echo "------------------------------------------------------------------------------"
wget -O /xlxd/dmrid.dat http://xlxapi.rlx.lu/api/exportdmr.php
echo "------------------------------------------------------------------------------"
echo "Copying web dashboard files and updating init script... "
mkdir /var/www/xlxd
#
 if [ -z "$DASH" ]
then DASH=1 

fi   
if [ $DASH = 1 ]
then
       cp -r /opt/xlxd/dashboard/* /var/www/xlxd/
elif [ $DASH = 2 ]
then
    cp -r /opt/xlxd/dashboard2/* /var/www/xlxd/
elif echo "$DASH" &> /dev/null
then
    cp -r /opt/xlxd/dashboard/* /var/www/xlxd/
fi
#
sudo sed -i "s/mailto:<?php echo.*/mailto:<?php echo \$PageOptions['ContactEmail']; ?>\"><?php echo \$PageOptions['ContactEmail']; ?><\/a> <\/div> <p><a title=\"Raspbian Proyect by HP3ICC © <?php \$cdate=date(\"Y\"); if (\$cdate > \"2018\") {\$cdate=\"2018-\".date(\"Y\");} echo \$cdate; ?>\" target=\"_blank\" href=https:\/\/github.com\/hp3icc\/easy-xlxd\/>Proyect: easy-xlxd<\/a>/"  /var/www/xlxd/index.php   
sudo sed -i "s/Reflector Dashboard/Reflector Dashboard \/ $DESCRIPTION/g"  /var/www/xlxd/index.php
cp /opt/xlxd/scripts/xlxd /etc/init.d/xlxd
sed -i "s/XLX999 192.168.1.240 127.0.0.1/$XRFNUM $LOCAL_IP $AMBIP/g" /etc/init.d/xlxd
update-rc.d xlxd defaults
# Delaying startup time
# mv /etc/rc3.d/S01xlxd /etc/rc3.d/S10xlxd ##Disabling as its not really needed. 
echo "Updating XLXD Config file... "
XLXCONFIG=/var/www/xlxd/pgs/config.inc.php
#
if [ -z "$ACTIXLX" ]; 
then ACTIXLX=N; 

fi   
if [ $ACTIXLX = Y ]
  then
  sed -i "s/'Active']                               = false/'Active']                               = true/g" /var/www/xlxd/pgs/config.inc.php
elif [ $ACTIXLX = Y ]
  then
  sed -i "s/'Active']                               = false/'Active']                               = true/g" /var/www/xlxd/pgs/config.inc.php 
fi
#
sed -i "s/600/300/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/tmp/xlxd/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/'ShowFullIP'/'ShowLast2ByteOfIP'/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/Int./XLX Module/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/Regional/XLX Module/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/National/XLX Module/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/NumberOfModules']                      = 10/NumberOfModules']                      = $NMODU/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/your_country/$CONTRIE/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/your_comment/$DESCRIPTION/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/'CustomTXT']                            = ''/'CustomTXT']                            = '$DESCRIPTION'/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/your_email/$EMAIL/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/LX1IQ/$CALLSIGN/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/http:\/\/your_dashboard/http:\/\/$XLXDOMAIN/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/\/tmp\/callinghome.php/\/xlxd\/callinghome.php/g" /var/www/xlxd/pgs/config.inc.php
echo "Copying directives and reloading apache... "
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/$XLXDOMAIN.conf
sed -i "s/VirtualHost \*/VirtualHost $XLXDOMAIN/g" /etc/apache2/sites-available/$XLXDOMAIN.conf
#sed -i "s/ysf-xlxd/xlxd/g" /etc/apache2/sites-available/$XLXDOMAIN.conf
sudo sed -i "s/www\/.*/www\/xlxd/g" /etc/apache2/sites-available/$XLXDOMAIN.conf
chown -R www-data:www-data /var/www/xlxd/
chown -R www-data:www-data /xlxd/
sudo chmod +x /etc/init.d/xlxd
sudo chmod +x /opt/xlxd/ambed/run
sudo chmod +x /xlxd/xlxd
sudo chmod +777 /xlxd/
sudo chmod +r /var/log/messages
a2ensite $XLXDOMAIN
sudo sed -i "s/www\/.*/www\/xlxd/g" /etc/apache2/sites-available/000-default.conf
a2ensite 000-default
#
##########################
sudo cat > /usr/local/bin/rebooter-xlxd.sh <<- "EOF"
#!/bin/bash
#sleep 30
while :
do
if systemctl status xlxd.service |grep Error >/dev/null 2>&1
then service xlxd restart

fi
  sleep 30
done
EOF
chmod +x /usr/local/bin/rebooter-xlxd.sh
######################################
#
cat > /lib/systemd/system/rebooter-xlxd.service  <<- "EOF"
[Unit]
Description=Rebooter-xlxd

[Service]
User=root
ExecStart=/usr/local/bin/rebooter-xlxd.sh

[Install]
WantedBy=default.target
EOF
#
if [ $INSTA = R ]
then
   cp /tmp/xlxd.blacklist /xlxd/xlxd.blacklist
   cp /tmp/xlxd.terminal /xlxd/xlxd.terminal
   cp /tmp/callinghome.php /xlxd/callinghome.php
   cp /tmp/xlxd.interlink /xlxd/xlxd.interlink
   cp /tmp/xlxd.whitelist /xlxd/xlxd.whitelist
fi
if [ $INSTA = r ]
then
    cp /tmp/xlxd.blacklist /xlxd/xlxd.blacklist
    cp /tmp/xlxd.terminal /xlxd/xlxd.terminal
    cp /tmp/callinghome.php /xlxd/callinghome.php
    cp /tmp/xlxd.interlink /xlxd/xlxd.interlink
    cp /tmp/xlxd.whitelist /xlxd/xlxd.whitelist
fi
#
wget --no-check-certificate -r 'https://docs.google.com/uc?export=download&id=1c60nJZGBHRLMxFsBI5SZRwTJXwnSSGZN' -O /var/www/xlxd/favicon.ico
###############################
sudo systemctl daemon-reload
service xlxd stop
service xlxd start
sudo systemctl restart apache2
sudo systemctl enable apache2
sudo systemctl enable xlxd
sudo systemctl enable rebooter-xlxd.service
sudo systemctl restart rebooter-xlxd.service
#
echo "------------------------------------------------------------------------------"
echo ""
echo ""
echo "******************************************************************************"
echo ""
echo ""
echo "XLXD is finished installing and ready to be used. Please read the following..."
echo ""
echo ""
echo "******************************************************************************"
echo ""
echo " For Public Reflectors: "
echo "If your XLX number is not already taken, enabling callinghome is all you need to do  "
echo "for your reflector to be added to all the host files automatically. It does take     "
echo "about an hour for the change to reflect, if your reflector is accessible and working."
echo "Once activated, the callinghome hash to backup will be /xlxd/callinghome.php. "
echo "More Information: $INFREF"
echo ""
echo ""
echo " For test/private Reflectors: "
echo "If you are using this reflector as a test or for offline access you will  "
echo "need to configure the host files of the devices connecting to this server."
echo "There are many online tutorials on 'Editing pi-star host files'.          "
echo ""
echo ""
echo "          Your $XRFNUM dashboad should now be accessible...            "
echo "                http://$XLXDOMAIN                                      "
echo ""
echo ""
echo "You can make further customizations to the main config file $XLXCONFIG."
echo "Be sure to thank the creators of xlxd for the ability to spin up          "
echo "your very own D-Star reflector.                                           "
echo ""
echo "------------------------------------------------------------------------------"
#sudo reboot
