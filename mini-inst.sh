#!/bin/bash
#
# Copyright 2016,2017 JS Foundation and other contributors, https://js.foundation/
# Copyright 2015,2016 IBM Corp.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

VER=0.18.4

sudo rm -rf /usr/local/bin/node-red*
sudo rm -rf /usr/bin/node-red*
sudo rm -rf /usr/bin/update-nodejs-and-nodered

# Get systemd script - start and stop scripts - svg icon - and .desktop file into correct places.
if [ -d "resources" ]; then
    cd resources
    sudo chown root:root *
    sudo chmod +x node-red-start
    sudo chmod +x update-nodejs-and-nodered
    sudo cp node-red-start /usr/bin/
    sudo cp update-nodejs-and-nodered /usr/bin/
    sudo cp node-red-icon.svg /usr/share/icons/gnome/scalable/apps/node-red-icon.svg
    sudo chmod 644 /usr/share/icons/gnome/scalable/apps/node-red-icon.svg
    sudo cp Node-RED.desktop /usr/share/applications/Node-RED.desktop
    sudo chown pi:pi *
    cd ..
else
    echo " "
    echo "resources - subdirectory not in place... exiting."
    exit 1
fi
#sudo systemctl disable nodered

# Restart lxpanelctl so icon appears in menu - programming
lxpanelctl restart >/dev/null
echo " "
echo "Tar up the existing install"
sudo rm -rf /tmp/n*
cd /
sudo tar zcf /tmp/nredm.tgz /usr/bin/node-red-start /usr/bin/update-nodejs-and-nodered /usr/share/applications/Node-RED.desktop /usr/share/icons/gnome/scalable/apps/node-red-icon.svg
echo " "
ls -l /tmp/nredm.tgz
echo " "
echo "Extract nredm.tgz to /tmp directory"
sudo mkdir -p /tmp/node-red_$VER/DEBIAN
sudo tar zxf /tmp/nredm.tgz -C /tmp/node-red_$VER
cd /tmp/node-red_$VER
echo " "
echo "Reset file ownerships and permissions"
sudo chown -R root:root *
sudo chmod -R -s *
sudo find . -iname "*.md" -exec chmod 644 {} \;
sudo find . -iname LICENSE -exec chmod 644 {} \;
sudo find . -iname *.png -exec chmod 644 {} \;
sudo find . -iname *.txt -exec chmod 644 {} \;
sudo find . -type d -exec chmod 755 {} \;
echo " "
echo "Create control file"
cd DEBIAN
echo "Package: node-red" | sudo tee control
echo "Version: $VER" | sudo tee -a control
echo "Section: editors" | sudo tee -a control
echo "Priority: optional" | sudo tee -a control
echo "Architecture: all" | sudo tee -a control
echo "Replaces: nodered" | sudo tee -a control
echo "Homepage: http://nodered.org" | sudo tee -a control
echo "Maintainer: Dave Conway-Jones <dceejay@gmail.com>" | sudo tee -a control
echo "Description: Node RED is a flow based editor for the Internet of Things" | sudo tee -a control
echo " A graphical flow editor for event based applications." | sudo tee -a control
echo " Runs on node.js - using a browser for the user interface." | sudo tee -a control
echo " See http://nodered.org for more information, documentation and examples." | sudo tee -a control
echo " ." | sudo tee -a control
echo " Copyright 2017 IBM Corp." | sudo tee -a control
echo " Licensed under the Apache License, Version 2.0" | sudo tee -a control
echo " http://www.apache.org/licenses/LICENSE-2.0" | sudo tee -a control

echo "service nodered stop >/dev/null 2>&1; rm -f /usr/bin/node-red >/dev/null 2>&1; exit 0" | sudo tee postinst
echo "service nodered stop >/dev/null 2>&1; exit 0" | sudo tee prerm
echo "rm -rf /usr/lib/node_modules/node-red* /usr/bin/node-red-stop /usr/bin/node-red-log >/dev/null 2>&1; exit 0" | sudo tee postrm
sudo chmod 0755 postinst prerm postrm

cd ../usr/share
sudo mkdir -p doc/node-red
cd doc/node-red
echo "Copyright 2017 IBM Corp." | sudo tee copyright
echo "node-red ($VER) unstable; urgency=low" | sudo tee changelog
echo "  * Point release." | sudo tee -a changelog
echo " -- DCJ <ceejay@vnet.ibm.com>  $(date '+%a, %d %b %Y %H:%M:%S +0000')" | sudo tee -a changelog
echo "" | sudo tee -a changelog
sudo gzip -9 changelog

echo " "
echo "Build the actual deb file"
cd /tmp/
sudo dpkg-deb --build node-red_$VER
ls -lrt no*.deb
echo " "
echo "Move .deb to /home/pi directory"
sudo mv node-red_$VER.deb /home/pi/
cd /home/pi
sudo chown pi:pi node-red_$VER.deb
echo " "
echo "Now running lintian report"
lintian node-red_$VER.deb > /home/pi/lint.log
echo ' '
echo 'Errors   ' $(cat lint.log | grep E: | wc -l)
echo 'Warnings ' $(cat lint.log | grep W: | wc -l)
echo "All done - see ~/lint.log"
