#### Importing cfengine repo gpg key
sudo wget http://cfengineers.net/repo/autobuilder.gpg -O /etc/apt/trusted.gpg.d/cfengineers-repo.gpg


#### Adding cfengine repository for Raspbian Jesse
sudo bash -c "echo 'deb http://cfengineers.net/repo raspjessie main' >> /etc/apt/sources.list.d/cfengineers.list"


#### Updating and intalling cfengine
sudo apt-get update
sudo apt-get -y install cfengine3

#### Installing dependencies
sudo apt-get -y install git nodejs npm lshw wireless-tools


#### Make node binary symlink
sudo ln -s /usr/bin/nodejs /usr/bin/node


#### Clone SuperMesh's test build to system
git clone https://github.com/satindergrewal/SuperMesh


#### Move SuperMesh to /opt directory
sudo mv SuperMesh /opt/

# Fix permissions of supermesh files
chmod 644 /opt/SuperMesh/private/system_scripts/*.cf

#### Change directory to SuperMesh
cd /opt/SuperMesh/


#### Installing SuperMesh
npm install


#### Copying SuperMesh as a system service and enabling it to start at system boot
sudo cp -av /opt/SuperMesh/private/system_scripts/supermesh.service /etc/systemd/system/
sudo systemctl enable supermesh


#### Copyting configuration data from SuperMesh Sample Data to system
sudo cp -av /opt/SuperMesh/private/system_scripts/sample_data /opt/SuperMeshData

#### Installing more required system packages
sudo apt-get -y install isc-dhcp-server hostapd pdns-recursor

#### Starting SuperMesh sytstem service
sudo systemctl start supermesh

# Setting up IP forwarding
sudo cf-agent -K /opt/SuperMesh/private/system_scripts/sysctl_conf.cf
sleep 30; curl -L http://localhost:3000/admin/firewall/enableipv4fwd

#### Configuring Raspberry Pi settings using SuperMesh's default system scripts
# Setting up and restarting network settings
sudo cf-agent -K /opt/SuperMesh/private/system_scripts/edit_network_config.cf
sudo systemctl daemon-reload
sudo systemctl restart networking

# Setting up DHCPD settings & restarting service
sudo cf-agent -K /opt/SuperMesh/private/system_scripts/dhcpd_conf.cf
sudo systemctl daemon-reload
sudo systemctl enable isc-dhcp-server
sudo systemctl restart isc-dhcp-server

#### Setting up hostapd drivers
# Copying hostapd drviers to system for Edimax 802.11bgn wifi adapter & Edimax 802.11ac wifi adapter
sudo cp -av /opt/SuperMesh/private/system_scripts/drivers/hostapd* /usr/sbin/

# Renaming original hostapd and creating a symlink to it
sudo mv /usr/sbin/hostapd /usr/sbin/hostapd_original
sudo ln -s /usr/sbin/hostapd_original /usr/sbin/hostapd

# Making sure hostapd files are executable
sudo chmod +x /usr/sbin/hostapd*

# Setting up hostapd
node /opt/SuperMesh/private/js/install_helper.js

# Setting up Access Point settings & restarting service
sudo cf-agent -K /opt/SuperMesh/private/system_scripts/hostapd_conf.cf
sudo systemctl daemon-reload
sudo systemctl enable hostapd
sudo systemctl restart hostapd

# Setting up DNS Service & restarting service
sudo cf-agent -K /opt/SuperMesh/private/system_scripts/recursor_conf.cf
sudo systemctl daemon-reload
sudo systemctl enable pdns-recursor
sudo systemctl restart pdns-recursor

#### Remove any unwanted files which generated during install
sudo rm /etc/network/interfaces.cf-before-edit
sudo rm /etc/dhcp/dhcpd.conf.cf-before-edit
sudo rm /etc/hostapd/hostapd.conf.cf-before-edit
sudo rm /etc/default/isc-dhcp-server.cf-before-edit
sudo rm /etc/default/hostapd.cf-before-edit
sudo rm /etc/sysctl.conf.cf-before-edit
sudo rm /etc/powerdns/recursor.conf.cf-before-edit 

#### Reboot the system
sudo reboot


