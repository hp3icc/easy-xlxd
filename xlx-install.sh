#!/bin/bash
sudo rm -r /root/reflector-install-files/
sudo rm -r /root/xlxd
sudo rm -r /xlxd
sudo rm -r /opt/xlxd
sudo rm -r /var/www/xlxd
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
read -p "# modules sample 10  :" NMODU
echo ""
echo "--------------------------------------"
read -p "ysf port sample 42000  :" YSFPOR
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
sudo sed -i "s/define NB_OF_MODULES                   10/define NB_OF_MODULES                   $NMODU/g"  main.h
sudo sed -i "s/define YSF_PORT                        42000/define YSF_PORT                        $YSFPOR/g"  main.h
sudo sed -i "s/define YSF_AUTOLINK_ENABLE             0/define YSF_AUTOLINK_ENABLE             1/g"  main.h
sudo sed -i "s/MODULE             'B'/MODULE             'A'/g"  main.h
sudo sed -i "s/437000000/445525000/g"  main.h

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

cp -r /opt/xlxd/dashboard/* /var/www/xlxd/
cp /opt/xlxd/scripts/xlxd /etc/init.d/xlxd
sed -i "s/XLX999 192.168.1.240 127.0.0.1/$XRFNUM $LOCAL_IP 127.0.0.1/g" /etc/init.d/xlxd
update-rc.d xlxd defaults
# Delaying startup time
# mv /etc/rc3.d/S01xlxd /etc/rc3.d/S10xlxd ##Disabling as its not really needed. 
echo "Updating XLXD Config file... "
XLXCONFIG=/var/www/xlxd/pgs/config.inc.php
#
sed -i "s/'ShowFullIP'/'ShowLast2ByteOfIP'/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/Int./XLX Module/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/Regional/XLX Module/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/National/XLX Module/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/'Active']                               = false/'Active']                               = true/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/NumberOfModules']                      = 10/NumberOfModules']                      = $NMODU/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/your_country/$CONTRIE/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/your_comment/$DESCRIPTION/g" /var/www/xlxd/pgs/config.inc.php
#
sed -i "s/your_email/$EMAIL/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/LX1IQ/$CALLSIGN/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/http:\/\/your_dashboard/http:\/\/$XLXDOMAIN/g" /var/www/xlxd/pgs/config.inc.php
sed -i "s/\/tmp\/callinghome.php/\/xlxd\/callinghome.php/g" /var/www/xlxd/pgs/config.inc.php
echo "Copying directives and reloading apache... "
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/$XLXDOMAIN.conf
sed -i "s/VirtualHost \*/VirtualHost $XLXDOMAIN/g" /etc/apache2/sites-available/$XLXDOMAIN.conf
#sed -i "s/ysf-xlxd/xlxd/g" /etc/apache2/sites-available/$XLXDOMAIN.conf
sed -i "s/html/xlxd/g" /etc/apache2/sites-available/$XLXDOMAIN.conf
chown -R www-data:www-data /var/www/xlxd/
chown -R www-data:www-data /xlxd/
a2ensite $XLXDOMAIN
service xlxd stop
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
