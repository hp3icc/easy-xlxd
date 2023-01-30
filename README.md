# easy-xlxd

XLXD MULTIMODE REFLECTOR ,customized modified script, allows to adjust in an easy way:

* style dashboard select clasic or new

* port number ysf reflector

* number of enabled modules

* default module YSF

* xlx reflector number or letters

* country

* reflector description xlxd

* ambe ssrver address

* ambe server port

* routine is included that auto restarts reflector xlxd in case of internet loss

#

# Install

    apt-get update
    
    apt-get install curl sudo -y
    
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/hp3icc/easy-xlxd/main/xlx-install.sh)"
    
   
 To extend or change configuration values, just run the script again and configure according to your preference
 
#

 # Location files config
 
  * Main Config file:
 
  /var/www/xlxd/pgs/config.inc.php
  
  * interlink & other files :  
   
  /xlxd/  
   
#
  
 # Location Dashboard Files
 
 /var/www/xlxd/

#

# credit

 * original scrip n5amd without modifications by hp3icc :

 https://github.com/n5amd/xlxd-debian-installer

 * Source xlxd files :
 
 https://github.com/LX3JL/xlxd
