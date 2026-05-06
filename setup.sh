#!/bin/bash

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
#  - remove the setup user and related config           #
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

	if [ -z "${2+x}" ]; then
		# No error message to handle
		HEADERTEXT="${1}"
	else
		HEADERTEXT="\Zb\Z1${2}\Zn\n\n${1}"
	fi

        IFS=$'\n' read -r -d '' pass1 pass2 < <( dialog --colors --no-cancel --erase-on-exit --insecure --passwordform "${HEADERTEXT}" 0 0 0 \
                                                 "Enter Passphrase:"    1 1 "" 1 22 30 1024 \
				                 "Re-enter Passphrase:" 2 1 "" 2 22 30 1024 \
				                 3>&1 1>&2 2>&3 3>&-)

        if [ "${pass1}" = "${pass2}" ]; then

		PWCHECK=`echo "${pass1}" | cracklib-check`
		if [[ ! "${PWCHECK}" =~ OK$ ]]; then
			enter_pass "${1}" "${PWCHECK}"
		else
			return 0
		fi

        else
		ERRORMSG="Sorry, the passphrases did not match. Please try again."
                enter_pass "${1}" "${ERRORMSG}"

        fi
}


function enter_text () {

	if [ -z "${4+x}" ]; then
		# No error message to handle
		HEADERTEXT="${1}"
	else
		HEADERTEXT="\Zb\Z1${4}\Zn\n\n${1}"
	fi

	text=$(dialog --colors --erase-on-exit --inputbox "${HEADERTEXT}" 0 0 2>&1 >/dev/tty)

	if [[ "${text}" =~ ${2} ]]; then
		return 0
	else
		ERRORMSG="${3}"
		enter_text "${1}" "${2}" "${3}" "${ERRORMSG}"
	fi

}


DRIVEDEVICE=`findmnt -n /boot/efi | awk '{ print $2 }' | sed -e 's/[0-9]$//'`;
KEYFILE="/etc/luks/personalised-boot_os.keyfile";
RESUME_DEV="/dev/mapper/LUKS_SWAP";
OLDPASS="setup";
OLDKEY="/etc/luks/boot_os.keyfile";
BITWARDEN_DEB="/home/setup/Bitwarden-2026.3.1-amd64.deb";
SETUP_PROGRESS=".setup_progress";

SETUP_HDPASS="hd_pass";
SETUP_REENCRYPT="reencrypt";
SETUP_HDKEYFILE="hd_keyfile";
SETUP_CRYPTTAB="update_crypttab";
SETUP_ADDUSER="add_user";
SETUP_HOSTNAME="hostname";
SETUP_GROWFS="grow_filesystem";
SETUP_DISABLESETUP="setup_login_disabled";
SETUP_PASSECHO="disable_password_echo";
SETUP_INSTALLNETSOFT="install_net_software"
SETUP_BITWARDEN="bitwarden";
SETUP_RMSETUPUSER="rm_setupuser";

CHANGES=0
NONETWORK=0

MSGTEXT="\Zb\Z1IMPORTANT DO NOT CLOSE THIS WINDOW\Zn\n\nThis script sets up your filesystem encryption and user account. The security of your system depends on following these steps. Please allow this script to complete its work.\n\nWhile this script runs you may see pop ups warning about limited disk space and the need to install updates. These can be safely ignored/dismissed for the time being. This script will resize the filesystem, which will take care of the limited disk space message(s). Please install updates after this script has finished."

dialog --colors --erase-on-exit --msgbox "$MSGTEXT" 0 0

if [ ! -d ~/$SETUP_PROGRESS ]; then

	# Create a directory for tracking setup progress
	# This script is run as root, progress tracking files are in the root
	# user's home directory.
	mkdir ~/$SETUP_PROGRESS;

fi

	
if [ ! -f ~/$SETUP_PROGRESS/$SETUP_HDPASS ]; then

	MSGTEXT="The first step is to update the passphrase used to decrypt the USB stick. It is the passphrase asked for when the USB stick is first booted. This must be a strong passphrase that you will remember. \Zb\Z1If this passphrase is lost it will be impossible to recover your files.\Zn\n\nOften a nonsensical phrase (eg Blue tigers glow in the dark) is easier to remember and more secure than a complicated but shorter password."
	dialog --colors --erase-on-exit --msgbox "$MSGTEXT" 0 0	

	enter_pass "Enter a storage encryption passphrase"
	DRIVEPASSPHRASE=${pass1}

	MSGTEXT="Please take a moment to record the passphrase somewhere safe."
	dialog --erase-on-exit --msgbox "$MSGTEXT" 0 0	

	CHANGES=1

	{
	# Encrypt the drive with the user's passphrase - using named pipe to provide the
	# existing password. 
		echo "Adding passphrase to the boot partition..."
		mkfifo pipe 
		echo -n "${OLDPASS}" | cryptsetup luksAddKey --progress-frequency 10 --key-file - ${DRIVEDEVICE}1 pipe &
		echo -n "${DRIVEPASSPHRASE}" > pipe
		rm pipe

		echo "Adding passphrase to the root partition..."
		mkfifo pipe
		echo -n "${OLDPASS}" | cryptsetup luksAddKey --progress-frequency 10 --key-file - ${DRIVEDEVICE}4 pipe &
		echo -n "${DRIVEPASSPHRASE}" > pipe
		rm pipe
	} 2>&1 | dialog --erase-on-exit --progressbox "Updating drive encryption with your new passphrase..." 21 72 

	touch ~/$SETUP_PROGRESS/$SETUP_HDPASS

fi


if [ ! -f ~/$SETUP_PROGRESS/$SETUP_REENCRYPT ]; then

	CHANGES=1

	# We reencrypt the boot and root partitions so that the underlying
	# volume key is unique to this particular USB stick.
	# LUKS1, used on boot to be compatible with GRUB, can not be reencrypted while open.
	umount /boot/efi
	umount /boot
	cryptsetup close /dev/mapper/LUKS_BOOT
	{
		echo "This will take a few minutes..."
		echo ""
		echo "\ZbReencrypting the boot partition...\Zn"
		echo ""
		echo -n "${DRIVEPASSPHRASE}" | cryptsetup reencrypt --progress-frequency 10 --key-file - --key-slot 2 ${DRIVEDEVICE}1
		echo ""
		echo "\ZbReencrypting the root partition..\Zn"
		echo ""
		echo -n "${DRIVEPASSPHRASE}" | cryptsetup open ${DRIVEDEVICE}1 LUKS_BOOT
		mount /dev/mapper/LUKS_BOOT /boot
		mount ${DRIVEDEVICE}3 /boot/efi

	# LUKS2 can be reencrypted while mounted and in use.
	echo -n "${DRIVEPASSPHRASE}" | cryptsetup reencrypt --progress-frequency 10 --key-file - --key-slot 2 ${DRIVEDEVICE}4
	} 2>&1 | dialog --colors --erase-on-exit --progressbox "Reencrypting the drive so that the underlying volume key is unique to this USB stick." 21 72 

	touch ~/$SETUP_PROGRESS/$SETUP_REENCRYPT

fi


if [ ! -f ~/$SETUP_PROGRESS/$SETUP_HDKEYFILE ]; then
		
	CHANGES=1

	if [ ! -f $KEYFILE ]; then

		# Create the keyfile
		dd if=/dev/urandom of=$KEYFILE bs=4096 count=1
		chmod 400 $KEYFILE

	fi

	# Add new keyfile
	{
		echo "Adding new key to boot..."
		echo -n "${DRIVEPASSPHRASE}" | cryptsetup luksAddKey --progress-frequency 10 --key-file - --new-keyfile $KEYFILE ${DRIVEDEVICE}1 $KEYFILE
		echo ""
		echo "Adding new key to root..."
		echo -n "${DRIVEPASSPHRASE}" | cryptsetup luksAddKey --progress-frequency 10 --key-file - --new-keyfile $KEYFILE ${DRIVEDEVICE}4 $KEYFILE
	} 2>&1 | dialog --erase-on-exit --progressbox "Adding an encryption keyfile unique to this USB stick..." 21 72 

	touch ~/$SETUP_PROGRESS/$SETUP_HDKEYFILE

fi


if [ ! -f ~/$SETUP_PROGRESS/$SETUP_CRYPTTAB ]; then

	CHANGES=1

	# Update crypttab to use the new keyfile
	sed -i "s/${OLDKEY//\//\\/}/${KEYFILE//\//\\/}/g" /etc/crypttab
	touch ~/$SETUP_PROGRESS/$SETUP_CRYPTTAB

fi


if [ ! -f ~/$SETUP_PROGRESS/$SETUP_ADDUSER ]; then

	CHANGES=1

	MSGTEXT="The next two questions are for your account on the operating system. You will need this username/password combination to log into your user account.\n\nPlease enter a username:"
	USERNAME=$(dialog --erase-on-exit --inputbox "${MSGTEXT}" 0 0 2>&1 >/dev/tty)

	enter_pass "Please enter a password for your user account." 
	PASSWORD=${pass1}

	# Add new user account
	useradd -m --groups sudo -s /bin/bash -p `openssl passwd -6 "$PASSWORD"` $USERNAME 

	touch ~/$SETUP_PROGRESS/$SETUP_ADDUSER

fi


if [ ! -f ~/$SETUP_PROGRESS/$SETUP_HOSTNAME ]; then

	CHANGES=1

	MSGTEXT="Lets give your computer a name so that it can identify itself when it is on a network. The name may contain letters, numbers, and hyphens but cannot start with a hyphen.\n\nPlease enter a name for your computer:"

	enter_text "${MSGTEXT}" "^[^\-][a-zA-Z0-9-]{1,}$" "The name may contain only letters, numbers, and hyphens AND must not start with a hyphen."
	HOSTNAME=${text}

	echo "${HOSTNAME}" > /etc/hostname
	hostname $HOSTNAME

	touch ~/$SETUP_PROGRESS/$SETUP_HOSTNAME

fi


if [ ! -f ~/$SETUP_PROGRESS/$SETUP_GROWFS ]; then

	CHANGES=1

	{
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
			echo -n $DRIVEPASSPHRASE | cryptsetup luksFormat --progress-frequency 10 --key-file - ${DRIVEDEVICE}5
			echo "Adding the keyfile to the new swap partition..."
			echo -n $DRIVEPASSPHRASE | cryptsetup open --key-file - ${DRIVEDEVICE}5 LUKS_SWAP
			echo -n $DRIVEPASSPHRASE | cryptsetup luksAddKey --progress-frequency 10 --key-file - --new-keyfile $KEYFILE ${DRIVEDEVICE}5 $KEYFILE
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
		cryptsetup resize --progress-frequency 10 --key-file $KEYFILE /dev/mapper/LUKS_ROOT
		echo "Resizing the BTRFS filesystem..."
		btrfs filesystem resize max / 

		# Set the resume partition
		echo "Setting the resume partition to ${RESUME_DEV}..."
		RESUME_UUID=`blkid -s UUID -o value $RESUME_DEV`
		sed -i -e 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="resume=${RESUME_UUID}"/' /etc/default/grub
		update-grub
		update-initramfs -u -k all
	} 2>&1 | dialog --erase-on-exit --progressbox "Expanding the filesystem so that it uses the whole USB stick..." 21 72 

	# Mark section complete
	touch ~/$SETUP_PROGRESS/$SETUP_GROWFS
	
fi


if [ ! -f ~/$SETUP_PROGRESS/$SETUP_DISABLESETUP ]; then

	CHANGES=1

	# We can't remove the setup account while actively using it so
	# instead we will disable logins from it. This will allow the
	# script to continue to run and the user to continue this login
	# session but will not allow new logins or sudo access.
	usermod --expiredate 1 setup

	touch ~/$SETUP_PROGRESS/$SETUP_DISABLESETUP

fi


if [ ! -f ~/$SETUP_PROGRESS/$SETUP_PASSECHO ]; then

	CHANGES=1

	# Disable the echoing of * to screen when sudo password entered
	echo 'Defaults !pwfeedback' | tee /etc/sudoers.d/9_no_pwfeedback

	touch ~/$SETUP_PROGRESS/$SETUP_PASSECHO
fi


if [ ! -f ~/$SETUP_PROGRESS/$SETUP_INSTALLNETSOFT ]; then

	# If you would like to add any additional software that was not
	# included in the drive image you can do that here. Most software
	# can be installed with apt-get, in this example we add the Signal
	# GPG key and repository before going on to add Signal and other
	# software.
	#
	# A network connection is required for this step. We inform the user
	# and give them the opportunity to quit if they do not have a
	# connection.

	# Test for an internet connection
	if : > /dev/udp/8.8.8.8/53; then

		CHANGES=1

		{
			wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > /tmp/signal-desktop-keyring.gpg;
			cat /tmp/signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
			echo "deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main" |\
				sudo tee /etc/apt/sources.list.d/signal-xenial.list
			apt-get update
			apt-get install -y signal-desktop torbrowser-launcher chromium wireguard-tools systemd-resolved
		} 2>&1 | dialog --erase-on-exit --progressbox "Installing Signal, Tor, Chromium, Wireguard and related software from the network..." 21 72 

		touch ~/$SETUP_PROGRESS/$SETUP_INSTALLNETSOFT

	else

		NONETWORK=1
		MSGTEXT="An internet connection is not available. Skipping installing software from the network for now."
		dialog --colors --erase-on-exit --msgbox "$MSGTEXT" 0 0
	fi

fi


if [ ! -f ~/$SETUP_PROGRESS/$SETUP_BITWARDEN ]; then

	CHANGES=1

	# The following is an example of installing a .deb file that cannot be installed using apt-get
	# for some reason.

	# Outside of this script the bitwarden .deb file has been
	# copied to the USB drive. This was done because 
	# the .deb file download process requires javascript and can't
	# be done here with typical CLI tools.
	#
	# Install bitwarden and then delete the .deb file.
	{
		dpkg -i $BITWARDEN_DEB 
		rm -f $BITWARDEN_DEB
	} 2>&1 | dialog --erase-on-exit --progressbox "Installing Bitwarden password manager..." 21 72 

	touch ~/$SETUP_PROGRESS/$SETUP_BITWARDEN

fi


# Remove setup user if there are no processes owned by setup
SETUPPROCESSES=`ps aux | awk ' { print $1 } ' | grep setup | wc -l`

if [[ ! ${SETUPPROCESSES} -gt 0 ]] && [[ ! -f ~/$SETUP_PROGRESS/$SETUP_RMSETUPUSER  ]]; then

	# It is safe to remove the setup user. We are not logged in as setup and
	# setup has no running processes.

	deluser --remove-home --quiet setup

	touch ~/$SETUP_PROGRESS/$SETUP_RMSETUPUSER

fi


PROG=`ls ~/$SETUP_PROGRESS/ | wc -l`

if [[ "${PROG}" = "12" ]]; then

	# All the setup steps have been completed and the setup user does not have any
	# running processes.  We're done!!

	# Disable the automatic startup of setup.sh and the script itself.
	rm -f /etc/skel/.config/autostart/USB\ System\ Setup.desktop
	rm -f /home/$SUDO_USER/.config/autostart/USB\ System\ Setup.desktop
	rm -f /usr/local/bin/setup.sh

	# Remove running of setup.sh from sudoers
	rm -f /etc/sudoers.d/setup

	# We are all done!
	MSGTEXT="\ZbWe are all done!\Zn\n\nThe setup user has been removed and the final steps have been completed.\n\nWe hope you enjoy using Linux Mint on an encrypted USB stick!\n\nClick OK or press Enter to finish."
	dialog --colors --erase-on-exit --msgbox "$MSGTEXT" 0 0
else
	# We are finished this particular run through the script, but the setup process
	# itself is not complete.

	MSGTEXT="This run through the setup script is complete. You should now have a new passphrase set up for the encryption, a new user account, and the filesystem will be expanded to use your whole USB stick.\n\nThere are a few more setup steps to finish, so this script will run again when you log in with your new user account. Please reboot and log back in as your new user so that the setup process can be completed.\n\nIf you have a network available please connect to it after logging in.\n\nClick OK or press Enter to reboot now."
	dialog --erase-on-exit --msgbox "$MSGTEXT" 0 0
	/usr/sbin/reboot

fi
