# raspbian-deb-package
Scripts required to build the Node-RED deb package for Raspbian.

The easiest way to build the package is to run these two script files on a clean
SD card running in a Raspberry Pi Arm6 model - that way they will include the
correct instruction set for other Arm6 type Pi (Original A and B models) and yet
be forwards compatible with the Arm7 versions (Pi2 etc).

Both script files should be transferred to the pi home directory and set executable..

    chmod +x node-red*.sh

### node-red-pi-install.sh

You should only run this script once.

Firstly it does an apt-get update and installs node.js and npm.

It then npm installs the latest Node-RED from npm. This can take 10-15 mins on a Pi 1.

It also installs the node-red-admin tool, and a few useful extra nodes.

Then it removes a load of crud files from all the installed dependancies -
such as test, doc, samples, examples and so on.

Finally we fetch the icon file, init scripts, and desktop file and install them.

Once this finishes the Pi should be able to run Node-RED and have an icon under
menu - programming

### node-red-deb-pack.sh

Next run this script - it also cleans up the crud just to be sure... then packs
all the files and unpacks them into a directory in /tmp/

It then moves files from `/usr/local/...` to `/usr/...`  as required for pre-installed applications, and adds the necessary `DEBIAN/control` file.

Finally it builds the actual deb file - moves it back to the `/home/pi` directory and then runs `linitian` to report all the violations.

Don't worry there are loads ! so to trim then down to what I consider actually relevant try running

    cat lint.log | grep E: | grep -v '\.node'

for the Errors - and

    cat lint.log | grep W: | grep -v '!node' | grep -v 'extra' | grep -v "image" | grep -v "please" | grep -v "not-executable" | grep -v '\.node'

for the warnings.

### Notes

Both these scripts could be run as one. Though while messing around it made more sense to do the install once and then re-pack as many times as necessary.

Other improvements would be to also tidy up prior to the
install so repeated runs of that script would clean out
any existing Node-RED files.
