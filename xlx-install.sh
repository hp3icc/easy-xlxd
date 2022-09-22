#!/bin/bash
sudo rm -r /root/reflector-install-files/
sudo rm -r /root/xlxd
sudo rm -r /opt/xlxd
clear
echo ""
echo "XLX uses 3 digit numbers for its reflectors. For example: 032, 999, 099."
read -p "What 3 digit XRF number will you be using?  " XRFDIGIT
XRFNUM=XLX$XRFDIGIT
echo ""
echo "--------------------------------------"
read -p "What is the FQDN of the XLX Reflector dashboard? Example: xlx.domain.com.  " XLXDOMAIN
echo ""
echo "--------------------------------------"
read -p "What contrie your server?  " CONTRIE
echo ""
echo "--------------------------------------"
read -p "description your server?  " DESCRIPTION
echo ""
echo "--------------------------------------"
read -p "What E-Mail address can your users send questions to?  " EMAIL
echo ""
echo "--------------------------------------"
read -p "What is the admins callsign?  " CALLSIGN
echo ""
echo ""
echo "------------------------------------------------------------------------------"
echo "Making install directories and installing dependicies...."
echo "------------------------------------------------------------------------------"
#
sudo apt install git
sudo apt install apache2 php5
sudo apt install build-essential
sudo apt install g++
# the following is only needed for XLX, not for XRF
sudo apt install libmariadb-dev-compat -y
# the following is needed if you plan on supporting local YSF frequency registration database
sudo apt install php-mysql mariadb-server mariadb-client -y

echo "------------------------------------------------------------------------------"
cd /opt
git clone https://github.com/LX3JL/xlxd.git
cd xlxd/src/

   echo "------------------------------------------------------------------------------"
  
#
sudo sed -i "s/define NB_OF_MODULES                   10/define NB_OF_MODULES                   1/g"  main.h
#sudo sed -i "s/define YSF_PORT                        42000/define YSF_PORT                        420002/g"  main.h
sudo sed -i "s/define YSF_AUTOLINK_ENABLE             0/define YSF_AUTOLINK_ENABLE             1/g"  main.h
sudo sed -i "s/MODULE             'B'/MODULE             'A'/g"  main.h
#
   make clean
   make
   make install
#
XLXINSTDIR=/opt/
LOCAL_IP=$(ip a | grep inet | grep "eth0\|en" | awk '{print $2}' | tr '/' ' ' | awk '{print $1}')

echo "------------------------------------------------------------------------------"
echo "Copying web dashboard files and updating init script... "
cp -R $XLXINSTDIR/xlxd/dashboard/* /var/www/xlxd/
cp $XLXINSTDIR/xlxd/scripts/xlxd /etc/init.d/xlxd
sed -i "s/XLX999 192.168.1.240 127.0.0.1/$XRFNUM $LOCAL_IP 127.0.0.1/g" /etc/init.d/xlxd
update-rc.d xlxd defaults
# Delaying startup time
# mv /etc/rc3.d/S01xlxd /etc/rc3.d/S10xlxd ##Disabling as its not really needed. 
echo "Updating XLXD Config file... "
XLXCONFIG=/var/www/xlxd/pgs/config.inc.php
#
sed -i "s/'ShowFullIP'/'ShowLast2ByteOfIP'/g" $XLXCONFIG
sed -i "s/Int./XLX Module/g" $XLXCONFIG
sed -i "s/'Active']                               = false/'Active']                               = true/g" $XLXCONFIG
sed -i "s/NumberOfModules']                      = 10/NumberOfModules']                      = 1/g" $XLXCONFIG
#
sed -i "s/your_email/$EMAIL/g" $XLXCONFIG
sed -i "s/LX1IQ/$CALLSIGN/g" $XLXCONFIG
sed -i "s/http:\/\/your_dashboard/http:\/\/$XLXDOMAIN/g" $XLXCONFIG
sed -i "s/\/tmp\/callinghome.php/\/xlxd\/callinghome.php/g" $XLXCONFIG
echo "Copying directives and reloading apache... "
cp $DIRDIR/templates/apache.tbd.conf /etc/apache2/sites-available/$XLXDOMAIN.conf
sed -i "s/apache.tbd/$XLXDOMAIN/g" /etc/apache2/sites-available/$XLXDOMAIN.conf
sed -i "s/ysf-xlxd/xlxd/g" /etc/apache2/sites-available/$XLXDOMAIN.conf
chown -R www-data:www-data /var/www/xlxd/
chown -R www-data:www-data /xlxd/
a2ensite $XLXDOMAIN
service xlxd start
systemctl restart apache2
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
