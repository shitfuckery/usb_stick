#!/bin/bash
set -e

#########################################################
#                                                       #
# Script to complete USB drive system setup:            #
#                                                       #
#  - re-encrypt the filesystem with a new passphrase    #
#  - re-encrypt the filesystem with a new keyfile       #
#  - remove the setup filesystem passphrase and keyfile #
#  - add a new user                                     #
#  - grow the filesystem to use the whole drive, adding #
#    enough swap to allow hibernation if size allows    #
#  - disable the setup user                             #
#  - install additional software if necessary           #
#  - remove the setup user                              #
#                                                       #
# For testing start this script with gnome-terminal:    #
#    /home/setup/setup.sh                               #
#                                                       #
# To have it automatically run when a user first boots  #
# their system use the                                  #
# setup/.config/autostart/USB System Setup.desktop file #
# or similar.                                           #
#########################################################


function enter_pass () {
        read -s -r -p "${1}: " pass1
        echo ""
        read -s -r -p "Verify - ${1}: " pass2

        if [ "${pass1}" = "${pass2}" ];
        then
                return 0
        else
                echo "Sorry, they did not match. Please try again."
                enter_pass "${1}"       
        fi
}

echo ""
echo ""
echo "IMPORTANT DO NOT CLOSE THIS WINDOW"
echo ""
echo "This script sets up your drive encryption and user account. The security"
echo "of your system depends on following these steps."
echo ""
echo "The first passphrase will be used to encrypt the storage and will be"
echo "needed every time you boot a computer from this USB drive. This"
echo "must be a strong passphrase that you will remember. If this passphrase"
echo "is lost it will be impossible to recover any files from the system."
echo ""
echo "Often a nonsensical phrase is easier to remember than a complicated"
echo "but shorter password."

enter_pass "Enter a storage encryption passphrase"
DRIVEPASSPHRASE=${pass1}

echo ""
echo "Please take a moment to record that passphrase somewhere safe."
echo ""
echo "The next questions are for your account on the operating system."
echo "You will need this username/password combination to log into your"
echo "user account."
echo ""
read -p "Please enter a username: " USERNAME

enter_pass "Please enter a password" 
PASSWORD=${pass1}

echo ""
echo "Thank-you."
echo ""
echo "Last step!"
read -p "Please enter a name for your computer: " HOSTNAME

echo "One moment while things are set up."
echo ""
echo "Most of what follows can be safely ignored."
sleep 5

DRIVEDEVICE=`findmnt -n /boot/efi | awk '{ print $2 }' | sed -e 's/[0-9]$//'`;
KEYFILE="/etc/luks/personalised-boot_os.keyfile";
RESUME_DEV="/dev/mapper/LUKS_SWAP";
OLDPASS="setup";
OLDKEY="/etc/luks/boot_os.keyfile";
BITWARDEN_DEB="/home/setup/Bitwarden-2025.6.0-amd64.deb";

SETUP_PROGRESS=".setup_progress";
SETUP_HDPASS="hd_pass";
SETUP_HDKEYFILE="hd_keyfile";
SETUP_CRYPTTAB="update_crypttab";
SETUP_RMSETUPPASS="rm_setuppass";
SETUP_RMSETUPKEYFILE="rm_setupkeyfile";
SETUP_ADDUSER="add_user";
SETUP_GROWFS="grow_filesystem";
SETUP_DISABLESETUP="setup_login_disabled";
SETUP_INSTALLSOFT="setup_install_software";
SETUP_RMSETUPUSER="rm_setupuser";
CHANGES=0

if [ ! -d ~/$SETUP_PROGRESS ]; then
	# Create a directory for tracking setup progress
	mkdir ~/$SETUP_PROGRESS;
fi

if [ -d ~/$SETUP_PROGRESS ]; then

	# If the setup progress directory exists continue setup

	if [ ! -f ~/$SETUP_PROGRESS/$SETUP_HDPASS ]; then

		CHANGES=1

		echo "Updating drive encryption with your new passphrase..."

		# Encrypt the drive with the user's passphrase - using named pipe to provide the
		# existing password. 
		echo "Encrypting the boot partition..."
		mkfifo pipe 
		echo -n "${OLDPASS}" | cryptsetup luksAddKey --key-file - ${DRIVEDEVICE}1 pipe &
		echo -n "${DRIVEPASSPHRASE}" > pipe
		rm pipe

		echo "Encrypting the root partition..."
		mkfifo pipe
		echo -n "${OLDPASS}" | cryptsetup luksAddKey --key-file - ${DRIVEDEVICE}4 pipe &
		echo -n "${DRIVEPASSPHRASE}" > pipe
		rm pipe

		touch ~/$SETUP_PROGRESS/$SETUP_HDPASS

	fi

	if [ ! -f ~/$SETUP_PROGRESS/$SETUP_HDKEYFILE ]; then
		
		CHANGES=1

		echo "Updating the keyfile associated with your encrypted drive..."

		if [ ! -f $KEYFILE ]; then

			# Create the keyfile
			dd if=/dev/urandom of=$KEYFILE bs=4096 count=1
			chmod 400 $KEYFILE

		fi

		# Add new keyfile
		echo "Adding new key to boot..."
		cryptsetup luksAddKey --key-file $OLDKEY --new-keyfile $KEYFILE ${DRIVEDEVICE}1 $KEYFILE

		echo "Adding new key to root..."
		cryptsetup luksAddKey --key-file $OLDKEY --new-keyfile $KEYFILE ${DRIVEDEVICE}4 $KEYFILE

		touch ~/$SETUP_PROGRESS/$SETUP_HDKEYFILE

	fi

	if [ ! -f ~/$SETUP_PROGRESS/$SETUP_CRYPTTAB ]; then

		CHANGES=1

		echo "Updating crypttab to use the new keyfile..."

		# Update crypttab to use the new keyfile
		sed -i 's/boot_os.keyfile/personalised-boot_os.keyfile/g' /etc/crypttab
		touch ~/$SETUP_PROGRESS/$SETUP_CRYPTTAB

	fi

	if [ ! -f ~/$SETUP_PROGRESS/$SETUP_RMSETUPPASS ]; then

		CHANGES=1

		echo "Removing the default passphrase from your drive..."

		# Remove the original drive passphrase. 
		echo "Removing the default pass from boot..."
		cryptsetup luksKillSlot --key-file $KEYFILE ${DRIVEDEVICE}1 0 

		echo "Removing the default pass from root..."
		cryptsetup luksKillSlot --key-file $KEYFILE ${DRIVEDEVICE}4 0 

		touch ~/$SETUP_PROGRESS/$SETUP_RMSETUPPASS

	fi

	if [ ! -f ~/$SETUP_PROGRESS/$SETUP_RMSETUPKEYFILE ]; then

		CHANGES=1

		echo "Removing the default keyfile from your drive..."

		# Remove the original setup keyfile 
		echo "Removing the default key from boot..."
		cryptsetup luksKillSlot --key-file $KEYFILE ${DRIVEDEVICE}1 1

		echo "Removing the default key from root..."
		cryptsetup luksKillSlot --key-file $KEYFILE ${DRIVEDEVICE}4 1

		touch ~/$SETUP_PROGRESS/$SETUP_RMSETUPKEYFILE

	fi

	if [ ! -f ~/$SETUP_PROGRESS/$SETUP_ADDUSER ]; then

		CHANGES=1

		echo "Creating your new user account..."

		# Add new user account
		useradd -m --groups sudo -s /bin/bash -p `openssl passwd -6 "$PASSWORD"` $USERNAME 

		# Update hostname and make it our own
		echo "${HOSTNAME}" > /etc/hostname
		hostname $HOSTNAME

		touch ~/$SETUP_PROGRESS/$SETUP_ADDUSER

	fi

	if [ ! -f ~/$SETUP_PROGRESS/$SETUP_GROWFS ]; then

		CHANGES=1

		echo "Expanding the filesystem so that it uses the whole USB stick..."

		# Size FS to use full thumbdrive space

		# Move second GPT header to the end of the drive
		echo "Moving second GPT header to end of the drive..."
		sgdisk -e ${DRIVEDEVICE} 

		# Check RAM size, drive size, and determine SWAP size
		RAM_MB=`free -m | grep Mem | awk ' { print $2 } '`
		FREE_SECTORS=`sgdisk -p ${DRIVEDEVICE} | grep ^Total | awk ' { print $5 } '`
		FREE_MB=`echo "${FREE_SECTORS}*512/1024/1024" | bc`
		echo "RAM: ${RAM_MB}MB"
		echo "Unpartitioned drive space: ${FREE_MB}MB"

		# In order to hybernate there must be at least as much swap as there is RAM
		# but on space restricted systems go easy
		RAMSIZETEST=`echo "${RAM_MB}*3" | bc`


		if [[ $FREE_MB -gt $RAMSIZETEST ]]; then
			# Create a swap drive the size of RAM in GB + 1 GB
			SWAP_GB=`echo "${RAM_MB}/1024+1" | bc`
		else
			# Create a 1GB swap partition
			SWAP_GB=1
		fi

		# Grow  

		if [[ $SWAP_GBx != "x" ]]; then
			# Grow (delete and recreate larger) the root partition
			# and add SWAP after it, set the swap for RESUME
			echo "Resizing the root partition..."
			sgdisk --delete=4 ${DRIVEDEVICE}
			sgdisk --new=4:0:-${SWAP_GB}G ${DRIVEDEVICE}
			sgdisk --typecode=4:8300 ${DRIVEDEVICE}
			echo "Creating the swap partition..."
			sgdisk --new=5:0:0 ${DRIVEDEVICE}
			sgdisk --typecode=5:8200 ${DRIVEDEVICE}
			partprobe ${DRIVEDEVICE}

			# Encrypt the SWAP partition
			echo "Encrypting the swap partition..."
			echo -n $DRIVEPASSPHRASE | cryptsetup luksFormat --key-file - ${DRIVEDEVICE}5
			echo "Adding the keyfile to the new swap partition..."
			echo -n $DRIVEPASSPHRASE | cryptsetup open --key-file - ${DRIVEDEVICE}5 LUKS_SWAP
		        echo -n $DRIVEPASSPHRASE | cryptsetup luksAddKey --key-file - --new-keyfile $KEYFILE ${DRIVEDEVICE}5 $KEYFILE
			mkswap -L swap /dev/mapper/LUKS_SWAP

			# Update crypttab and fstab
			echo "Updating crypttab and fstab..."
			echo "LUKS_SWAP UUID=$(blkid -s UUID -o value ${DRIVEDEVICE}5) $KEYFILE luks,discard" >> /etc/crypttab
			echo "/dev/mapper/LUKS_SWAP	none	swap	sw	0	0" >> /etc/fstab

			# Enable the new swap
			echo "Enabling the new swap partition..."
			swapon /dev/mapper/LUKS_SWAP
			RESUME_DEV="/dev/mapper/LUKS_SWAP"
		else
			# Grow the root partition to maximum size, leaving swap as-is.
			echo "Your USB stick does not have enough free space to make a swap"
			echo "partition large enough to allow your computer to hibernate."
			echo ""
			echo "Resizing root partition to use the available free space..."
			sgdisk --delete=4 ${DRIVEDEVICE}
			sgdisk --new=4:0:0 ${DRIVEDEVICE}
			sgdisk --typecode=4:8300 ${DRIVEDEVICE}
			partprobe ${DRIVEDEVICE}
		fi

		# Grow the root filesystem to match the partition
		echo "Resizing the LUKS filesystem..."
		cryptsetup resize --key-file $KEYFILE /dev/mapper/LUKS_ROOT
		echo "Resizing the BTRFS filesystem..."
		btrfs filesystem resize max / 

		# Set the resume partition
		echo "Setting the resume partition to ${RESUME_DEV}..."
		RESUME_UUID=`blkid -s UUID -o value $RESUME_DEV`
		sed -i -e 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="resume=${RESUME_UUID}"/' /etc/default/grub
		update-grub
		update-initramfs -u -k all

		# Mark section complete
		touch ~/$SETUP_PROGRESS/$SETUP_GROWFS
		

	fi


	if [ ! -f ~/$SETUP_PROGRESS/$SETUP_DISABLESETUP ]; then

		CHANGES=1

		echo "Disabling login for the setup user account..."

		# We can't remove the setup account while actively using it so
		# instead we will disable logins from it. This will allow the
		# script to continue to run and the user to continue this login
		# session but will not allow new logins or sudo access.
		usermod --expiredate 1 setup

		touch ~/$SETUP_PROGRESS/$SETUP_DISABLESETUP

	fi


	if [ ! -f ~/$SETUP_PROGRESS/$SETUP_INSTALLSOFT ]; then

		CHANGES=1

		echo "Install additional software..."

		# If you would like to add any additional software that was not
		# included in the drive image you can do that here. Most software
		# can be installed with apt-get, in this example we add the Signal
		# GPG key and repository before going on to add Signal and other
		# software.
		#
		# A network connection is required for this step. We inform the user
		# and give them the opportunity to quit if they do not have a
		# connection.

                echo ""
		echo ""
		echo "A network connection is required for this step. If you have a"
		echo "network available please connect to it now and then enter Y to"
		echo "continue."
		echo ""
		echo "If you do not have a network connection please enter N to exit"
		echo "now. All other necessary steps have been made and you can log"
		echo "in to your newly created user account and begin using your"
		echo "system. When you have a network connection please consider running"
		echo "the command 'sudo apt-get update && sudo apt-get install -y \\"
		echo "signal-desktop torbrowser-launcher qrencode chromium inkscape gimp'"
		echo "to install the software that would have been installed now."

		read -s -r -p "${1}: " NETWORK_CONTINUE 

		if [ "${NETWORK_CONTINUE}" = "Y" ]; then

			wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > /tmp/signal-desktop-keyring.gpg;
			cat /tmp/signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
			echo "deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main" |\
				sudo tee /etc/apt/sources.list.d/signal-xenial.list

			apt-get update
			apt-get install -y signal-desktop torbrowser-launcher qrencode chromium inkscape gimp

			if [ -f $BITWARDEN_DEB ]; then

				# Outside of this script the bitwarden .deb file has been
				# copied to the USB drive. This was done because 
				# the .deb file download process requires javascript and can't
				# be done here with typical CLI tools.
				#
				# Install bitwarden and then delete the .deb file.
				dpkg -i $BITWARDEN_DEB 
				rm -f $BITWARDEN_DEB

			fi

			# Disable the echoing of * to screen when sudo password entered
			echo 'Defaults !pwfeedback' | tee /etc/sudoers.d/9_no_pwfeedback

			touch ~/$SETUP_PROGRESS/$SETUP_INSTALLSOFT

		else
			exit 0
		fi


	fi


	# Remove setup user if there are no processes owned by setup
	SETUPPROCESSES=`ps aux | awk ' { print $1 } ' | grep setup | wc -l`

	if [[ ! ${SETUPPROCESSES} -gt 0 ]] && [[ ! -f ~/$SETUP_PROGRESS/$SETUP_RMSETUPUSER  ]]; then
		
		# It is safe to remove the setup user. We are not logged in as setup and
		# setup has no running processes.

		echo ""
		echo "Removing setup user."
		deluser --remove-home --quiet setup
		delgroup --quiet setup
		echo ""

		touch ~/$SETUP_PROGRESS/$SETUP_RMSETUPUSER

	fi


	if [[ ${CHANGES} = 0 ]] && [[ ! ${SETUPPROCESSES} -gt 0 ]]; then
		echo ""
		echo "No changes were made to your system. Setup is complete."
		echo ""
		echo "Please remove the setup script from the Startup Applications"
		echo "to get rid of this annoying window ;-). Here's hwo to do that:"
		echo ""
		echo "Click the Menu button (bottom left) and type:"
		echo ""
		echo "Startup Applications"
		echo ""
		echo "then press enter. You will be asked to enter you account password"
		echo "and will then be shown a list of the programs that are started"
		echo "automatically when you log into your account."
		echo ""
		echo "Look for 'Setup Script' in the list. Select it and click Remove."
	fi

fi

echo ""
echo ""
echo "The setup script has completed successfully.  You can now log out and"
echo "back in as your new user. Click the Menu button in the bottom left to"
echo "find the Log Out button."
echo ""
echo "The setup user has been disabled. You can remove it entirely in the"
echo "Users and Groups settings after logging in with your new account."
echo ""
echo ""
read -p "Press Enter to close this window." CLOSE
