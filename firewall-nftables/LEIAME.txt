1- compile requisites
 emerge nftables

##############################################
2- create initial rules and add to boot
rc-service nftables save && rc-update add nftables default

##############################################
3- Copy files to /etc/init.d and /etc/nftables

git clone https://github.com/coffnix/scripts-linux.git

rsync -avz scripts-linux/firewall-nftables/etc/ /etc/

##############################################
4- Fix permission to script init and add to boot

chmod +x /etc/init.d/firewall-nft

rc-update add firewall-nft default

##############################################
5- Start Firewall

rc-service nftables start
rc-service firewall-nft start

##############################################
6- Be happy :D
