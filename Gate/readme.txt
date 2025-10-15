# instructions for new install

sudo apt-get update
sudo apt-get upgrade

Needed for Segnix
# python2.7-dev
# build-essential
# git-core

sudo apt-get install mgetty etherwake apache2 php8.0 python3-pip

# move mgetty configs over

# add new systemd service check if this is correct or to system link it from /lib folder
cp mgetty.service to /etc/systemd/system 

sudo systemctl daemon-reload # Reload the service files to include the new service.
sudo systemctl start mgetty.service # start service
sudo systemctl status mgetty.service # To check the status of your service
sudo systemctl enable mgetty.service # To enable your service on every reboot


# key info https://openenergymonitor.github.io/forum-archive/node/12311.html
#Add to the end of the file
sudo nano /boot/config.txt
dtoverlay=pi3-disable-bt
#We also need to run to stop BT modem trying to use UART
sudo systemctl disable hciuart


#ensure our user is in the dialout group
groups

sudo usermod -a -G www-data pi
sudo adduser www-data gpio

sudo reboot 
# this is needed after adding user to groups


# for using the original IteadSIM800 GSM HAT
git clone https://github.com/lamondlab/IteadSIM800
sudo pip3 install pyserial


# we have a spare modmypi GSM SIM800 HAT. It may work with the Itead library
# It also has its own github library: https://github.com/modmypi/SIM800
