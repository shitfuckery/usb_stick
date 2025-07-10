# USB Stick

## A complete Linux Mint system on an encrypted USB drive. Your OS, your software, your files, your privacy, any computer.

## Background

Sometimes a person realises a need to elevate their privacy requirements. In the world of computing this can be disruptive to the usual way of doing things. What if you could plug a USB stick into any computer, boot from it, and be in a more private environment. One setup the way you want, with your software, your files, and your configuration. Reboot again without the USB stick and the computer is back exactly as it was before.

The recipe portion of this document draws heavily from the the excellent [Standalone Kali Linux 2021.4 Installation on a USB Drive, Fully Encrypted Kali Linux](https://www.kali.org/docs/usb/usb-standalone-encrypted/) documentation.  This document aims to further simplify the process and to create an end result that is more approachable for non-technical users in that Linux Mint is easier to transition to from MacOS or Windows than Kali while still maintaining the privacy and security benefits of Linux.

### What You Get

The end result will be a fully functional default Linux Mint installation that will run from a removable encrypted USB drive. The drive can be booted on any UEFI compatible computer with an Intel or AMD CPU.  It will function exactly as if it was installed on a hard drive in that software can be added or removed, customized in any way, and all configuration and data changes will persist across boots. This is accomplished by installing Linux Mint and the Grub boot loader to the USB drive as if it was a normal hard drive.

### Why Linux Mint?

Linux Mint was chosen because it has a polished and accessible interface that non-technical Windows and MacOS users will be able to quickly become familiar with. In addition, the Linux Mint Debian Edition installer includes all of the required tools. This simplifies the installation process compared to the Kali recipe this document is based on. The tools used are industry standard free / open source tools that have been very well scrutinised and tested.

### On Privacy, Security, And Trust

This USB stick uses [LUKS](https://access.redhat.com/solutions/100463) (Linux Unified Key Setup) to provide full disk encryption of the USB stick. LUKS is an open specification industry standard that has been well vetted by people who know far more about encryption than I ever will.  If you pair LUKS with a strong passphrase and do not share that passphrase you can rest assured that no one will be able to read your files.  This provides a foundation of privacy on which security can be built, but it is important to remember that security is much more than privacy alone.

Encryption and account security is only as good as the passwords that protect them. Consider using a password manager and never reuse a password. A passphrase is often easier to remember and provides better security than a complicated password. An example might be “Yellow dogs can’t play with wet spiders.” In the rest of this document I will use the term passphrase instead of password as a nudge in that direction.

There's a saying in System Administration, I know I'm paranoid, but am I paranoid enough? Security is not an absolute. Different people or organisations face different security risks and requirements. You are a much better judge of the risks you face than I am. Broadly speaking, the aspects to consider are the applications used, their configuration, and any network usage. These are enormous topics that can not be properly covered here. The general compromise tends to be around usability versus security. For many situations the compromises made in the default Linux Mint install provide what I consider a good balance. If you disagree, you will at least find a solid foundation on which to build.

You don't know me and I don't know you. If you download and boot from the disk image linked in this document you are implicitly trusting me not to do something nefarious. Maybe you are willing to take that risk, maybe you aren't. I have provided both the finished disk image _and_ the recipe used to create it in the hope that if you don't trust the disk image you may use the recipe to create one of your own that you will be able to trust.

### On USB Drives

Reliability is everything. Despite best efforts I have bought enough unreliable garbage online that I no longer try. I now buy USB drives at a local retailer that will take returns and only buy name brand drives.  Right after reliability, consider USB-A vs USB-C and which one you are most likely to run into. At the time of writing, June 2025, I use a low profile USB-A drive and have a USB-A to USB-C adapter I sometimes use.  After reliability and interface, consider speed. All USB drives can be read from much faster than they can be written to. The write speed has the most impact on the performance of a USB drive based system, and it is also the one that USB drive marketing materials are most evasive about. This is where talking to a store clerk might help. Photography departments have informed opinions. Outside of this you’ll basically have to buy and test.

When using a USB drive based system you will notice slow write speeds if/when the system freezes up while waiting for a write to finish. While this is happening you will be unable to interact with the system. Patience is eventually rewarded and the system’s responsiveness will return once the write has finished. How frequently this happens and how long it takes to clear will depend on the write speed of the USB drive.

## Two Paths

There are two paths to an encrypted USB stick based system, you can either download the disk image and put it on a USB stick or you can follow the recipe and create your own encrypted USB stick based system from scratch. As mentioned above, one reason you might chose to follow the Recipe path is because you would rather not trust me or the disk image I created. Fair enough. Another reason to follow the recipe is to understand the process more and/or to customise it to your needs.

### The Disk Image

The disk image and the files used to validate it can be downloaded from Google Drive here:

1. The Disk Image [usb_drive_disk_image-release-0.9.0.img](https://drive.google.com/file/d/1IcqVFhNwCa6Co5bCC9ergWz3HbWLb9WX/view?usp=sharing)
2. An SHA256 hash of the disk image [usb_drive_disk_image-release-0.9.0.img.sha256sum](https://drive.google.com/file/d/1wv6HUucXcYjicNXm3N1yvQj2wu9YWpII/view?usp=sharing)
3. A GPG signature of the sha256sum file using code@shitfuckery.ca's GPG key [usb_drive_disk_image-release-0.9.0.img.sha256sum.sig BROKEN LINK](https://localhost)

The TL;DR instructions: Download the disk image, validate it, put it on a USB stick that is at least 16GB in size, boot from it, enjoy.

The much better explained version of the Disk Image instructions can be found at [README-using_the_disk_image.md BROKEN LINK](https://localhost)

### The Recipe

The recipe describes the steps I used to create the disk image that can be downloaded above. The intention was to create as small a disk image as possible so that it could be redistributed without people having to download too large a file (yes, I'm aware that almost 9GB is already very big). If you don't intend to redistribute the end result please

#### Preparation

You will need:
* A 64bit x86 (Intel or AMD CPU) based computer with two free USB ports
* A USB drive with the Linux Mint Debian Edition (LMDE) installer (https://linuxmint.com/download_lmde.php) loaded on it. Use the Linux Mint “Create bootable media” documentation for information on how to do this https://linuxmint-installation-guide.readthedocs.io/en/latest/.
* A blank USB drive that is at least 9GB in size. Note that this is the absolute minimum size and is not large enough for a properly usable system. Such a small drive should only be contemplated if your intention is to redistribute the end result and you would like the smallest possible disk image. To create a properly usable system you will need a blank USB drive that is at least 16GB in size (the larger the better) and the faster the better, especially write speed.
* A working Internet connection will be necessary to install some of the necessary software.

#### Boot the Linux Mint Debian Edition Installer

The first step is to boot your computer with the Linux Mint Debian Installer USB drive. Your computer will have a special key that needs to be pressed shortly after turning it on to have it boot from USB. The Linux Mint installation instructions have a [good write-up](https://linuxmint-installation-guide.readthedocs.io/en/latest/boot.html) on how to determine which key to press on your computer. On mine, pressing F12 after powering it on brings up the Boot Options menu and I can chose to boot from an attached USB drive.

![A screenshot of the Linux Mint desktop as seen after first booting. The icon for launching the terminal is circled in red.](https://localhost/icon48.png "Linux Mint installer desktop")

The Linux Mint installer desktop. Note the circled icon for the terminal in the bottom left, click on this to open the terminal. This is where we will be working and the commands given below are to be entered into the terminal.

#### Determine the Target USB Drive

Do not attach the Target USB drive (the one you want to install onto) until instructed to do so. A possible source of errors is writing to the wrong drive, so we always want to make sure we know which drive is our Target drive. The easiest way to do this is to observe the list of drives before and after the Target USB drive has been plugged in.

Open a terminal window. To do this either click on the icon circled in the screenshot above or press the Windows button on your keyboard and type 'terminal' followed by Enter. Either will result in a window like the one shown below opening.

![A screenshot showing the terminal window.](https://localhost/ "An open terminal window")

If you are like most computer users you probably don't use a terminal (or command line interface) very often. Resist the urge to be intimidated, you've got this! In most cases you will be able to cut and paste the instructions directly from this document into the terminal and have them work as expected.

To list the drives we are interested in enter the following command into the terminal and press Enter:

```bash
ls -l /dev/sd*
```

This will result in output that will look similar to the following screenshot.

![A screenshot showing sample output of the command ls -l /dev/sd*](https://localhost "Example output from ls -l /dev/sd*")

The sameple output shown above shows a single drive (/dev/sda) with two partitions (sda1 and sda2). You may see additional drivess in your output, this is normal and not a problem.

Now insert the Target USB drive and run the `ls -l /dev/sd*` command again, comparing the output against the earlier output. You will see a new drive listed.

![A screenshot showing the output of the command ls -l /dev/sd* after the Target drive has been plugged in](https://localhost "Example ls -l /dev/sd* output after the Target USB drive has been plugged in")

In the example shown above the Target USB drive is the newly listed drive /dev/sdb. In this example the Target USB drive has 4 existing partitions. Yours will likely have a different number. The number of partitions is not important, what is important is the name of the drive. In the example shown above this is /dev/sdb, yours may be different.

It is very important to go through the process of finding the correct Target USB drive and to repeat this step if you reboot your computer as drive letters can change during a reboot. If you are unsure which drive is your Target USB drive or these directions do not make sense please stop now and ask someone you know for help or [email code@shitfuckery.ca](mailto:code@shitfuckery.ca) and I will do my best to help as time allows. There is a real risk of deleting the wrong drive if you make a mistake here.

**IMPORTANT**

**Going forward these instructions will use /dev/sdTARGET in all commands referencing the Target USB drive. Please substitute the drive letter for TARGET (eg b in this /dev/sdb example) found in the previous step. Sometimes the instructions will include a partition number after TARGET (eg /dev/sdTARGET3) which would be /dev/sdb3 in this example.**

#### Partition the Target Drive

Partitioning a drive is a way to set aside drive space for particular uses. Modern computers use a UEFI system to boot the operating system, or OS. For our purposes this requires at least 4 partitions. One for the UEFI info, one for the bootloader, one for the /boot partition, and last root for everything else. Notable by its absence is a swap partition. In the disk image we redistribute a [script BROKEN LINK](https://localhost) is used to to automate the process of creating a swap partition during the setup process. This allows us to keep the disk image relatively small.

We start by deleting any existing partitions on the Target USB drive:

```bash
sudo sgdisk --zap-all /dev/sdTARGET
```

The following commands create the 4 partitions we need:

```bash
sudo sgdisk --new=1:0:+512M /dev/sdTARGET
sudo sgdisk --new=2:0:+2M /dev/sdTARGET
sudo sgdisk --new=3:0:+128M /dev/sdTARGET
sudo sgdisk --new=4:0:+16091137 /dev/sdTARGET
```

The following commands set the correct types for the partitions and assign them names. The names themselves aren't important, but may be helpful in the future if trying to sort out which partition is used for what.

````bash
sudo sgdisk --typecode=1:8301 --typecode=2:ef02 --typecode=3:ef00 --typecode=4:8300 /dev/sdTARGET
sudo sgdisk --change-name=1:boot --change-name=2:GRUB --change-name=3:EFI-SP--change-name=4:rootfs /dev/sdTARGET
````

#### Encrypt the USB Drive Partitions

We will be encrypting the 1st and 4th partitions, the ones used for the boot and root filesystems. The 2nd (bootloader) and 3rd (UEFI) will not be encrypted.  Were we adding a swap partition we would want to encrypt it too, but because we are making as small a disk image as possible we are not adding a swap partition.  The unencrypted 2nd and 3rd partitions will never hold any of your files or operating system files and no information can be gleened about your files or operating system from them.

We will be using LUKS version 1 to format the boot partition because GRUB, the bootloader we will be using, is able to decrypt LUKS v1 partitions, but not LUKS v2. GRUB needs to be able to decrypt the boot partition in order to load the kernel and the encryption key that is in turn used to decrypt the root partition.

When running the cryptsetup commands below you will be asked to provide a passphrase. For the purposes of recreating the disk image I redistribute the horribly insecure passphrase 'setup' could be used, however if you use this passphrase you will want to make sure you change it to something more secure in the future, perhaps by using the same [setup script LINK BROKEN](https://localhost) used in my disk image. Regardless, you will want to use the same passphrase on both encrypted partitions. While it is technically possible not to, little if anything is gained and it is dramatically less convenient.

```bash
sudo cryptsetup luksFormat --type=luks1 /dev/sdTARGET1
sudo cryptsetup luksFormat /dev/sdTARGET4
```

#### Open The Encrypted Partitions

Now that the boot and root partitions have been encrypted they need to be decrypted, or opened, before we can continue. You will be asked for a passphrase, use the same one you used in the previous step.

```bash
sudo cryptsetup open /dev/sdTARGET1 LUKS_BOOT
sudo cryptsetup open /dev/SDTARGET4 LUKS_ROOT
```

With the commands above the names LUKS_BOOT and LUKS_ROOT are applied to the decrypted partitions, they are then made available at /dev/mapper/LUKS_BOOT and /dev/mapper/LUKS_ROOT where they can be treated like a normal partition.

#### Format the Partitions

```bash
sudo mkfs.ext4 -L boot /dev/mapper/LUKS_BOOT
sudo mkfs.vfat -F 16 -n EFI-SP /dev/sdTARGET3
sudo mkfs.btrfs -L root /dev/mapper/LUKS_ROOT
```

You may notice, we have not formatted the /dev/sdTARGET2 partition. It will be used for the bootloader and does not use a filesystem.

#### Setup Btrfs Subvolumes

I am using btrfs for the root partitions because it has sophisticated features, such as snapshotting, that some users may find useful while not placing any additional burden on users who won't use those features.

```bash
sudo mount -o subvol=/ /dev/mapper/LUKS_ROOT /mnt
cd /mnt
sudo btrfs subvolume create @
sudo btrfs subvolume create @home
sudo btrfs subvolume create @root
sudo btrfs subvolume create @snapshots
sudo btrfs subvolume list .
```

The last command above will list the subvolumes and a subvolume ID. Use the subvolume ID for the @ subvolume from the previous command for the following command so as to set the @ subvolume as the default:


```bash
sudo btrfs subvolume set-default 256 .
```

Use the following commands to umount the root root partition:

```bash
cd /
sudo umount /mnt
```

#### Run the Live Installer In Expert Mode

Linux Mint has a graphical install program that makes installation very easy. It does not directly support installing to an encrypted USB drive, however by using its expert mode in conjunction with some terminal commands we can get around this.

We will want a second terminal instance available so that we can run the live-installer-expert-mode command in one and additional commands in another. To open a second terminal instance as a tab within the existing terminal window press `<ctrl><shift>t`. You can then switch between tabs by clicking on them with your mouse.

In the new instance type the following command to start the live installer in expert mode:

```bash
sudo live-installer-expert-mode
```

This will open a new window like the one shown in the screenshot below.

![A screenshot showing the opening screen of the LMDE installer.](https://localhost/ "The LMDE installer, note the expert mode circled at the top")

Click on the "Lets go!" button to continue. This will open a screen like the one shown below.

![A screenshot showing the language and location selector.](https://localhost/ "The language and location selector")

Select your preferred primary language and location from the list. Additional languages can be added after the installation.

If this window is too tall for you to see the Quit / Next buttons at the bottom you can move the window around by holding down the `<alt>` key while clicking and holding anywhere on the window and dragging it around.

Click the Next button to continue.

![A screenshot showing the timezone setting screen.](https://localhost/ "Click on the map to select your timezone.")

Click on your location on the map to select your timezone, then click the Next button to continue.

![A screenshot showing the keyboard layout selector.](https://localhost/ "Chose your keyboard layout")

Select your keyboard layout and variant. Note that if you chose Canadian English earlier the default selection here will not be the expected English (US) so will have to be changed.

![A screenshot showing the user account screen.](https://localhost/ "Enter your user account information")

Enter the user account information on this screen. Note that the checkbox for encrypting the user's home folder is not selected. This is because rather than just encrypting the user's home directory we have encrypted everything.

For the disk image I used 'setup' for the username, password, and computer name. These are all then changed using the [setup script LINK BROKEN](https://localhost) that is automatically run when a user logs in.

![A screenshot showing the partitioning screen.](https://localhost/ "Select the Manual Partitioning option")

The screenshot above shows the partitioning screen. It is **very important that you select the Manual Partitioning option** otherwise the installer will write to the hard drive, everwriting whatever is on it, instead of the Target USB drive.

![A screenshot showing the manual partitioning screen.](https://localhost/ "Click the Expert mode button")

The screenshot above shows the manual partitioning screen. **Click the Expert Mode button (circled in red)** to continue.

![A screenshot showing the Manual Partitioning Expert Mode screen.](https://localhost/ "Leave this window open and switch to the terminal")

The screenshot above shows the manuap partitioning expert mode screen. The installation process will pause at this screen so that we can manually mount the various filesystems we created earlier. At this point switch back to the terminal window by either pressing `<alt><tab>` or by clicking on the terminal icon at the bottom left of the screen. Then, because the installer will have been started from this terminal instance, click on the tab to switch to the other terminal instance.

We will create a directory called /target and mount the various filesystems we created earlier under it using the following commands:

```bash
sudo mkdir -p /target
sudo mount -o subvol=@ /dev/mapper/LUKS_ROOT /target
sudo mkdir -p /target/boot
sudo mount /dev/mapper/LUKS_BOOT /target/boot
sudo mkdir -p /target/boot/efi
sudo mount /dev/sdTARGET3 /target/boot/efi
sudo mkdir -p /target/home
sudo mount -o subvol=@home /dev/mapper/LUKS_ROOT /target/home
sudo mkdir -p /target/root
sudo mount -o subvol=@root /dev/mapper/LUKS_ROOT /target/root
sudo mkdir -p /target/snapshots
sudo mount -o subvol=@snapshots /dev/mapper/LUKS_ROOT /target/snapshots
```

All of the filesystems necessary to install to the Target USB drive should now be mounted under /target. To confirm this run the following command and compare your results to the screenshot shown below.

```bash
df -h
```

![A screenshot showing the output of the `df -h` command.](https://localhost/ "The items that start with /target in the right-most column are the ones we are interested in")

The items that start with /target in the right-most column are the ones we are interested in. Their order doesn’t matter and the centre columns information will be different, but the left-most and right-most columns should match the screenshot with the exception of /dev/sda3 where the drive letter will match your TARGET drive.

At this point switch back to the installer window and click on the Next button in the bottom right. This will take you to a screen like the one shown below. **It is very important that you deselect the checkbox circled in the screenshot below. A mistake here would overwrite the bootloader on the hard drive of the computer you are working on.** We will be manually installing the GRUB bootloader in order to pass the --removable option, which is required when installing to a USB drive and not available otherwise.

![A screenshot showing the bootloader installation screen.](https://localhost/ "Deselect the checkbox so that GRUB is not automatically installed.")

After deselecting the GRUB installation checkbox click on the Next button.

The next screen will show a summary of the configuration like the screenshot below. Review yours to make sure it is accurate.  It is important that the “Filesystem operations” match the screenshot. If anything looks amis you the Back button to go back and make whatever changes are necessary.


![A screenshot showing the installation configuation summary.](https://localhost/ "Review the settings to make sure they are correct.")

After reviewing the summary click the Install button to start the actual installation process. Expect this process to take quite a while as it requires writing over 8GB of small files to the USB drive.

Eventually the install will pause at a screen like the one shown below. This is where we will do some final manual work.

![A screenshot showing the Installation Paused screen.](https://localhost/ "Switch back to the terminal to finalise installation.")

At this point we will finalise the installation by manually creating the fstab and crypttab files, editing configuration to enable GRUB to work with LUKS encryption, installing additional software required to use GRUB on a USB drive, and then finally creating a new initial RAM disk and actually installing GRUB.

#### Create /etc/fstab File

The file /etc/fstab describes the fileystem table, the various filesystems that the operating system will use. Normally this is created automatically during the installation process, but because we are stalling to an encrypted USB drive we need to create it ourselves.  Switch back to the terminal and enter the following commands:

```bash
sudo bash -c “echo ‘PARTUUID=$(blkid -s PARTUUID -o value /dev/sdTARGET3) /boot/efi vfat umask=0077 0 1’ >> /target/etc/fstab”
sudo bash -c “echo ‘/dev/mapper/LUKS_ROOT / btrfs defaults,noatime,ssd,compress=lzo,subvol=@ 0 0’ >> /target/etc/fstab
sudo bash -c “echo ‘/dev/mapper/LUKS_BOOT /boot ext4 defaults,noatime 0 1’ >> /target/etc/fstab”
sudo bash -c “echo ‘/dev/mapper/LUKS_ROOT /home btrfs defaults,noatime,ssd,compress=lzo,subvol=@home 0 2’ >> /target/etc/fstab”
sudo bash -c “echo ‘/dev/mapper/LUKS_ROOT /root btrfs defaults,noatime,ssd,compress=lzo,subvol=@root 0 3’ >> /target/etc/fstab”
sudo bash -c “echo ‘/dev/mapper/LUKS_ROOT /snapshots btrfs defaults,noatime,ssd,compress=lzo,subvol=@snapshots 0 4’ >> /target/etc/fstab”
```

#### Create an Encryption Key File

The following commands will create a 4KB file of "random stuff" that will serve as an encryption key for the encrypted partitions. For the purposes of the drive image I distribute, this key is temporary will be replaced by a unique key when the setup script is run by the end user.

```bash
sudo mkdir -p /target/etc/luks
sudo dd if=/dev/urandom of=/target/etc/luks/boot_os.keyfile bs=1024 count=4
```

#### Create the /etc/crypttab File

The file /etc/crypttab is used to decrypt the encrypted partitions and to map them to the correct filesystem in the fstab file created earlier. Use the following commands to create it:

```bash
sudo bash -c “echo ‘LUKS_BOOT UUID=$(blkid -s UUID -o value /dev/sdTARGET1) /etc/luks/boot_os.keyfile luks,discard’ >> /target/etc/crypttab”
sudo bash -c “echo ‘LUKS_ROOT UUID=$(blkid -s UUID -o value /dev/sdTARGET4) /etc/luks/boot_os.keyfile luks,discard’ >> /target/etc/crypttab”
```

#### Configure LUKS and GRUB to Work Together

Configure LUKS and Grub to be able to decrypt the filesystem. When you run the two cryptsetup commands you will be asked to enter the passphrase that was used to encrypt the partitions earlier.

```bash
sudo bash -c “echo ‘KEYFILE_PATTERN=/etc/luks/*.keyfile’ >> /target/etc/cryptsetup-initramfs/conf-hook”
sudo bash -c “echo ‘UMASK=0077’ >> /target/etc/initramfs-tools/initramfs.conf”
sudo chmod 500 /target/etc/luks
sudo chmod 400 /target/etc/luks/boot_os.keyfile
sudo cryptsetup luksAddKey /dev/sdTARGET1 /target/etc/luks/boot_os.keyfile
sudo cryptsetup luksAddKey /dev/sdTARGET4 /target/etc/luks/boot_os.keyfile
sudo bash -c “echo ‘GRUB_ENABLE_CRYPTODISK=y’ >> /target/etc/default/grub”
```

#### Connect to the Internet

Up to this point an Internet connection has not been required, however we need to get a few non-standard packages over the the next steps.  If you do not have an Internet connection you can stop at this point and return here later with only having to repeat the step to mount the various filesystems under /target.

![A screenshot showing the wifi icon.](https://localhost/ "Click on the wifi icon to configure your Internet connection")

After connecting to the Internet return to the terminal and continue the following steps.

#### Create Initial RAM Disk

To create the initial RAM disk (initrd) run the following commands:

```bash
sudo mount --bind /dev /target/dev
sudo mount --bind /dev/pts /target/dev/pts
sudo mount --bind /proc /target/proc
sudo mount --bind /sys /target/sys
sudo mount --bind /sys/firmware/efi/efivars /target/sys/firmware/efi/efivars
sudo mount --bind /run /target/run
sudo mount --bind /etc/resolv.conf /target/etc/resolv.conf
sudo chroot /target
mount -a
```

The chroot command above stands for change root, which effectively makes the /target directory become the / directory. This is necessary because we want to use all the configuration on the Target USB drive and we want the results to be written to the Target USB drive.

If there are any error messages after running the `mount -a` command it indicates an error in the fstab file.

Run the following commands to install the necessary grub related tools and create the initial RAM disk.

```bash
apt-get update && sudo apt-get -y install grub-common grub-efi-amd64 os-prober
/usr/sbin/update-initramfs -u -k all
```

#### Install GRUB

Run the following commands to install GRUB

```bash
grub-install --removable /dev/sdTARGET
update-grub
```

#### Install Any Additional Software

If you would like to add any additional software you can install it now using the apt package manager. For the disk image I distribute no additional software is added, instead additional software is added by the setup script that is run by the end user. In this way the disk image is kept a little smaller.

#### Exit the chroot

To continue the next steps we will need to excit the chroot by using the following command:

```bash
exit
```

#### Automate System Set-Up

In order to simplify the system set-up process for the end user a setup script has been created that automates the process of changing the LUKS encryption passphrase and encryption key, adding a new user account, disabling the original setup user account, adding and encrypting a swap partition, growing the root filesystem to use the entire USB drive, and installing any additional software. The setup script is configured to run automatically when the user logs in. Over the next few steps we will set that up.

Download the setup script using the following command:

```bash
cd ~/Downloads
wget https://localhost/setup.sh
wget https://localhost/autostartscript
```

Enable the automatic running of the setup.sh script by moving the two downloaded files into the correct locations:

```bash
sudo mkdir -p /target/home/setup/.config/autostart/
sudo mv /home/mint/Downloads/setup.sh /target/home/setup/setup.sh
sudo mv /home/mint/Downloads/USB\ System\ Setup.desktop /target/home/setup/.config/autostart/


#### Customise Configuration

/etc/skel/.bashrc example with adding a beer:

# It's Friday after 4pm, put a beer in your shell prompt.
beer() {
   if [[ $(date +%u) -eq 5 && $(date +%k) -gt 15 ]]
     then
       printf "🍺 " # one space at the end because time fixes all?
     fi
}
PS1="$(beer)$PS1"

