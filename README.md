# The Shitfuckery USB Stick

## A complete Linux Mint system on an encrypted USB stick. Your OS, your software, your files, your privacy, any computer.

<!-- Future home of an image to represent the Shitfuckery USB Stick -->

## Background

Sometimes a person realises a need to elevate their privacy requirements. In the world of computing this can be disruptive to the usual way of doing things. What if you could plug a USB stick into any computer, boot from it, and be in a more private environment. One setup the way you want, with your software, your files, and your configuration. Reboot again without the USB stick and the computer is back exactly as it was before.

This document is based on the excellent [Standalone Kali Linux 2021.4 Installation on a USB Drive, Fully Encrypted Kali Linux](https://www.kali.org/docs/usb/usb-standalone-encrypted/). The key distinctions between the two are; Mint is known for its ease of use while Kali is known for its technical sophistication, this recipe has a simplified creation process because the Linux Mint Debian Installer includes all of the tools necessary and legacy BIOS support has been dropped, this recipe builds a disk image that, while still big at 8.4GB, is intended to be redistributed and includes a setup script that automates the final setup process for the end user.

### What You Get

The end result will be a fully functional Linux Mint installation that will run from a removable encrypted USB stick. The stick can be used to boot any UEFI compatible computer with an Intel or AMD CPU. It will function exactly as if it was installed on a hard drive, in that software can be added or removed, customized in any way, and all configuration and data changes will persist across boots. This is accomplished by installing Linux Mint and the GRUB boot loader to the USB stick as if it was a normal hard drive.

### Why Linux Mint?

Linux Mint was chosen because it has a polished and accessible interface that non-technical Windows and MacOS users will be able to quickly become familiar with. In addition, the Linux Mint Debian Edition installer includes all of the required tools. This simplifies the installation process compared to the Kali recipe. The tools used are industry standard Libre / Open Source tools that have been very well scrutinised and tested.

### On Privacy, Security, And Trust

This USB stick uses [LUKS](https://access.redhat.com/solutions/100463) (Linux Unified Key Setup) to provide full disk encryption of the USB stick. LUKS is an open specification industry standard that has been well vetted by people who know far more about encryption than I ever will.  If you pair LUKS with a strong passphrase and do not share that passphrase you can rest assured that no one will be able to read your files.  This provides a foundation of privacy on which security can be built, but it is important to remember that security is much more than privacy alone.

Encryption and account security is only as good as the passwords that protect them. Consider using a password manager and never reuse a password. A passphrase is often easier to remember and provides better security than a complicated password. An example might be “Yellow dogs can’t play with wet spiders.” In the rest of this document I will use the term passphrase instead of password as a nudge in that direction.

There's a saying in System Administration, I know I'm paranoid, but am I paranoid enough? Security is not an absolute. Different people or organisations face different security risks and requirements. You are a much better judge of the risks you face than I am. Broadly speaking, the aspects to consider are the applications used, their configuration, and any network usage. These are enormous topics that can not be properly covered here. The general compromise tends to be around usability versus security. For many situations the compromises made in the default Linux Mint install provide what I consider a good balance. At the very least it provide a solid foundation on which to further customise.

We don't know each other. If you download and boot from the [disk image](#the-disk-image) linked in this document you are implicitly trusting us not to do something nefarious. Maybe you are willing to take that risk, maybe you aren't. We have provided both the finished disk image _and_ the recipe used to create it in the hope that if you don't trust the disk image you will still find this useful because you can vet and follow the recipe to create your own disk image that you will be able to trust.

### On USB Sticks

Reliability is everything. Despite best efforts I have bought enough unreliable garbage online that I no longer try. I now buy USB sticks at a local retailer that will take returns and only buy name brand drives. Right after reliability, consider USB-A vs USB-C and which one you are most likely to run into. At the time of writing, June 2025, I use a low profile USB-A drive and have a USB-A to USB-C adapter I sometimes use.  After reliability and interface, consider speed. All USB sticks can be read from much faster than they can be written to. The write speed has the most impact on the performance of a USB stick based system, and it is also the one that USB stick marketing materials are most evasive about. This is where talking to a store clerk might help. Photography shops will have informed opinions. Outside of this you basically have to buy and test.

When using a USB stick based system you will notice slow write speeds if/when the system freezes up while waiting for a write to finish. While this is happening you may be unable to interact with the system. Patience is eventually rewarded and the system’s responsiveness will return once the write has finished. How frequently this happens and how long it takes to clear will depend on the write speed of the USB stick.

## Two Paths

There are two paths to an encrypted USB stick based system, you can either download the disk image and put it on a USB stick or you can follow the recipe and create your own encrypted USB stick based system from scratch. As mentioned above, one reason you might chose to follow the Recipe path is because you would rather not trust us or the disk image we created. Totally understandable. Another reason to follow the recipe is to understand the process more and/or to customise it to your needs.

### The Disk Image

The disk image and the files used to validate it can be downloaded from Google Drive here:

1. The Disk Image [usb_drive_disk_image-release-0.9.0.img](https://drive.google.com/file/d/1IcqVFhNwCa6Co5bCC9ergWz3HbWLb9WX/view?usp=sharing)
2. An SHA256 hash of the disk image [usb_drive_disk_image-release-0.9.0.img.sha256sum](https://drive.google.com/file/d/1wv6HUucXcYjicNXm3N1yvQj2wu9YWpII/view?usp=sharing)
3. A GPG signature of the sha256sum file using code@shitfuckery.ca's GPG key [usb_drive_disk_image-release-0.9.0.img.sha256sum.sig](https://drive.google.com/file/d/1xcYVQbNeAKmKepDZeLzVdngE3acpfezv/view?usp=sharing)

The TL;DR instructions: Download the disk image, validate it, put it on a USB stick that is at least 16GB in size, boot from it, allow the setup script to run, enjoy.

The much more thorough and better explained version of the Disk Image instructions can be found at [README-using_the_disk_image.md](README-using_the_disk_image.md).

### The Recipe

The recipe describes the steps used to create the disk image that can be downloaded above. The intention was to create as small a disk image as possible so that it could be redistributed without people having to download too large a file (yes, it is still very large). By following this recipe you will be able to vet the steps taken and create your own disk image with any customisations you require.

#### Preparation

You will need:
* A 64bit x86 (Intel or AMD CPU) based computer with two free USB ports
* A USB stick with the [Linux Mint Debian Edition (LMDE)](https://linuxmint.com/download_lmde.php) installer loaded on it. Use the Linux Mint [Create bootable media](https://linuxmint-installation-guide.readthedocs.io/en/latest/) documentation for information on how to do this.
* A blank USB stick that is at least 9GB in size. Note that this is the absolute minimum size and is not large enough for a properly usable system. For the purposes of creating the disk image this is enough, but for an end user 16GB (bigger is better) should be considered the absolute minimum USB stick size.
* A working Internet connection will be necessary to install some of the necessary software.

#### Boot the Linux Mint Debian Edition Installer

The first step is to boot your computer with the Linux Mint Debian Installer USB stick. Every computer has a special keyboard key that can to be pressed shortly after turning it on that will allow it to boot from USB. The Linux Mint installation instructions have a [good write-up](https://linuxmint-installation-guide.readthedocs.io/en/latest/boot.html) on how to determine which key to press for your computer. On a Dell, for instance, pressing F12 after powering it on brings up the Boot Options menu.

<img alt="A screenshot of the Linux Mint desktop as seen after first booting. The icon for launching the terminal is circled in red." src="https://github.com/user-attachments/assets/0cfc5f2d-dd7d-40e3-be80-9c1cdabc1e1f " width="100%">

The Linux Mint installer desktop. Note the circled icon for the terminal in the bottom left, click on this to open the terminal. This is where we will be working and the commands given below are to be entered into the terminal.

#### Determine the Target USB Drive Letter

[!CAUTION]

Do not attach the Target USB stick (the one you want to install onto) until instructed to do so. A possible source of errors is writing to the wrong USB stick or drive, so we always want to make sure we know which one is our Target USB stick. The easiest way to do this is to observe the list of drives before and after the Target USB stick has been plugged in.

Open a terminal window. To do this either click on the icon circled in the screenshot above or press the Windows button on your keyboard and type 'terminal' followed by Enter. Either will result in a window like the one shown below opening.

<img width="100%" alt="Screenshot shoting an open terminal window" src="https://github.com/user-attachments/assets/6fabdc32-4454-4a5b-ae14-d6671fdeeb4d" />

If you are like most computer users you probably don't use a terminal (or command line interface) very often. Resist the urge to be intimidated, you've got this! In most cases you will be able to cut and paste the instructions directly from this document into the terminal and have them work as expected.

To list the drives we are interested in enter the following command into the terminal and press Enter:

```bash
ls -l /dev/sd*
```

This will result in output that will look similar to the following screenshot.

<img width="100%" alt="A screenshot showing sample output of the command ls -l /dev/sd*" src="https://github.com/user-attachments/assets/16b1fa01-ea72-4e8c-883e-3ae78d1f8c96" />

The sameple output shown above shows a single drive (/dev/sda) with two partitions (sda1 and sda2). You may see additional drives in your output, this is normal and not a problem.

Now insert the Target USB stick and run the `ls -l /dev/sd*` command again, comparing the output against the earlier output. You will see a new drive listed.

<img width="100%" alt="A screenshot showing the output of the command ls -l /dev/sd* after the Target USB stick has been plugged in" src="https://github.com/user-attachments/assets/c40c287c-5267-4c0b-bf30-ade28cd719eb" />

In the example shown above the Target USB stick is the newly listed drive /dev/sdb. In this example the Target USB stick has 4 existing partitions. Yours will likely have a different number. The number of partitions is not important, what is important is the name of the drive. In the example shown above this is /dev/sdb, yours may be different.

It is very important to go through the process of finding the correct Target USB stick and to repeat this step if you reboot your computer as drive letters can change from one boot to the next. If you are unsure which drive is your Target USB stick or these directions do not make sense please stop now and ask someone you know for help or open an issue here and we will do our best to help as time allows. There is a real risk of deleting or overwriting the wrong drive if you make a mistake here.

[!IMPORTANT]

**Going forward these instructions will use /dev/sdTARGET in all commands referencing the Target USB stick. Please substitute the drive letter for TARGET (eg b in this /dev/sdb example) found in the previous step. Sometimes the instructions will include a partition number after TARGET (eg /dev/sdTARGET3) which would be /dev/sdb3 in this example.**

#### Partition the Target USB Stick

Partitioning a drive is a way to set aside space for particular uses. Modern computers use a UEFI system to boot the operating system, or OS. For our purposes this requires at least 4 partitions. One for the UEFI info, one for the bootloader, one for the boot partition, and root for everything else. Notable by its absence is a swap partition. [Later in this recipe](#automate-system-set-up) a script is added that will automate the process of creating a swap partition after first boot. This allows us to keep the disk image relatively small.

We start by deleting any existing partitions on the Target USB stick:

```bash
sudo sgdisk --zap-all /dev/sdTARGET
```

The following commands create the 4 partitions we need:

```bash
sudo sgdisk --new=1:0:+512M /dev/sdTARGET
```
```bash
sudo sgdisk --new=2:0:+2M /dev/sdTARGET
```
```bash
sudo sgdisk --new=3:0:+128M /dev/sdTARGET
```
```bash
sudo sgdisk --new=4:0:+16091137 /dev/sdTARGET
```

The following commands set the correct types for the partitions and assign them names. The names themselves aren't important, but may be helpful in the future if trying to sort out which partition is used for what.

```bash
sudo sgdisk --typecode=1:8301 --typecode=2:ef02 --typecode=3:ef00 --typecode=4:8300 /dev/sdTARGET
```
```bash
sudo sgdisk --change-name=1:boot --change-name=2:GRUB --change-name=3:EFI-SP--change-name=4:rootfs /dev/sdTARGET
```

#### Encrypt the USB Stick Partitions

We will be encrypting the 1st and 4th partitions, the ones used for the boot and root filesystems. The 2nd (bootloader) and 3rd (UEFI) will not be encrypted. Were we adding a swap partition we would want to encrypt it too, but because we are making as small a disk image as possible we are not adding a swap partition. The unencrypted 2nd and 3rd partitions will never hold any of your files or operating system files and no information can be gleened about your files or operating system from them.

We will be using LUKS version 1 to format the boot partition because GRUB, the bootloader we will be using, is able to decrypt LUKS v1 partitions, but not LUKS v2. GRUB needs to be able to decrypt the boot partition in order to load the kernel and the encryption key that is in turn used to decrypt the root partition.

When running the cryptsetup commands below you will be asked to provide a passphrase. We have used the horribly insecure passphrase 'setup' throughout the creation of the disk image and then run a script to change every instance to something more secure on first boot. If you want to use the same automation script you can use the same 'setup' throughout or, if you change it, update the setup.sh script to match. If you don't plan to use the automation script we suggest using a much stronger passphrase and using the same passphrase for all of your partitions.

[!NOTE]

Many of the following commands include a partition number after the TARGET (eg /dev/sdTARGET1), be sure to leave that number in place when changing TARGET to your drive letter (eg /dev/sdb1).

```bash
sudo cryptsetup luksFormat --type=luks1 /dev/sdTARGET1
```
```bash
sudo cryptsetup luksFormat /dev/sdTARGET4
```

#### Open The Encrypted Partitions

Now that the boot and root partitions have been encrypted they need to be decrypted, or opened, before we can continue. You will be asked for a passphrase, use the same one you used in the previous step.

```bash
sudo cryptsetup open /dev/sdTARGET1 LUKS_BOOT
```
```bash
sudo cryptsetup open /dev/SDTARGET4 LUKS_ROOT
```

With the commands above the names LUKS_BOOT and LUKS_ROOT are applied to the decrypted partitions, they are then made available at /dev/mapper/LUKS_BOOT and /dev/mapper/LUKS_ROOT where they can be treated like a normal partition.

#### Format the Partitions

```bash
sudo mkfs.ext4 -L boot /dev/mapper/LUKS_BOOT
```
```bash
sudo mkfs.vfat -F 16 -n EFI-SP /dev/sdTARGET3
```
```bash
sudo mkfs.btrfs -L root /dev/mapper/LUKS_ROOT
```

You may notice we have not formatted the /dev/sdTARGET2 partition. It will be used for the bootloader and does not use a filesystem.

#### Setup Btrfs Subvolumes

We are using btrfs for the root partition because it has sophisticated features, such as subvolumes and snapshotting, that some users may find useful.

```bash
sudo mount -o subvol=/ /dev/mapper/LUKS_ROOT /mnt
```
```bash
cd /mnt
```
```bash
sudo btrfs subvolume create @
```
```bash
sudo btrfs subvolume create @home
```
```bash
sudo btrfs subvolume create @root
```
```bash
sudo btrfs subvolume create @snapshots
```
```bash
sudo btrfs subvolume list .
```

The last command above will list the subvolumes and a subvolume ID. Use the subvolume ID for the @ subvolume from the previous command for the following command so as to set the @ subvolume as the default. We are using 256 as an example:


```bash
sudo btrfs subvolume set-default 256 .
```

Use the following commands to umount the root partition:

```bash
cd /
```
```bash
sudo umount /mnt
```

#### Run the Live Installer In Expert Mode

Linux Mint has a graphical install program that makes installation very easy. It does not directly support installing to an encrypted USB stick, however by using its expert mode in conjunction with some terminal commands we can get around this.

We will want a second terminal instance available so that we can run the live-installer-expert-mode command in one and additional commands in another. To open a second terminal instance as a tab within the existing terminal window make sure the terminal window is selected and press `<ctrl><shift>t`. You can then switch between tabs by clicking on them with your mouse.

In the new instance type the following command to start the live installer in expert mode:

```bash
sudo live-installer-expert-mode
```

This will open a new window like the one shown in the screenshot below.

<img width="100%" alt="A screenshot showing the opening screen of the LMDE installer." src="https://github.com/user-attachments/assets/21eba1d5-1b7f-4dd5-86c6-b9635afb82c6" />

Note the expert mode circled at the top.

Click on the "Lets go!" button to continue. This will open a screen like the one shown below.

<img width="100%" alt="A screenshot showing the language and location selector." src="https://github.com/user-attachments/assets/076dfb9f-d39c-451d-9397-3c421a72c14e" />


Select your preferred primary language and location from the list. Additional languages can be added after the installation.

If this window is too tall for you to see the Quit / Next buttons at the bottom you can move the window around by holding down the `<alt>` key while clicking and holding anywhere on the window and dragging it around.

Click the Next button to continue.

<img width="100%" alt="A screenshot showing the timezone setting screen." src="https://github.com/user-attachments/assets/8a7a8de7-153d-4187-a98e-cff81e11dff8" />

Click on your location on the map to select your timezone, then click the Next button to continue.

<img width="100%" alt="A screenshot showing the keyboard layout selector." src="https://github.com/user-attachments/assets/37d21d88-23a3-470d-9039-27dcf1ab7272" />

Select your keyboard layout and variant. Note that if you chose Canadian English earlier the default selection here will not be the expected English (US) so will have to be changed.

<img width="100%" alt="A screenshot showing the user account screen." src="https://github.com/user-attachments/assets/5f1c6b14-80f1-4a39-be1d-d007b3b3cce1" />

Enter the user account information on this screen. Note that the checkbox for encrypting the user's home folder is not selected. This is because rather than just encrypting the user's home directory we have encrypted everything.

For the disk image we used 'setup' for the username, password, and computer name. These are all then changed using the [setup script](#automate-system-set-up) that is automatically run when a user logs in.

<img width="100%" alt="A screenshot showing the partitioning screen." src="https://github.com/user-attachments/assets/eb16762c-3f02-4b88-ba96-f34b1a92c5ac" />

[!CAUTION]

The screenshot above shows the partitioning screen. It is **very important that you select the Manual Partitioning option** otherwise the installer will write to the hard drive, overwriting whatever is on it, instead of the Target USB .

<img width="100%" alt="A screenshot showing the manual partitioning screen." src="https://github.com/user-attachments/assets/256b33b3-2903-47b3-ad83-3c8e9c1c9ff6" />

The screenshot above shows the manual partitioning screen. **Click the Expert Mode button (circled in red)** to continue.

<img width="100%" alt="A screenshot showing the Manual Partitioning Expert Mode screen." src="https://github.com/user-attachments/assets/c554a2c1-e022-4c50-92a6-5a2cf0bf6690" />

The screenshot above shows the manual partitioning expert mode screen. The installation process will pause at this screen so that we can manually mount the various filesystems we created earlier. At this point switch back to the terminal window by either pressing `<alt><tab>` or by clicking on the terminal icon at the bottom left of the screen. Then, because the installer will have been started from this terminal instance, click on the tab to switch to the other terminal instance.

We will create a directory called /target and mount the various filesystems we created earlier under it using the following commands:

```bash
sudo mkdir -p /target
```
```bash
sudo mount -o subvol=@ /dev/mapper/LUKS_ROOT /target
```
```bash
sudo mkdir -p /target/boot
```
```bash
sudo mount /dev/mapper/LUKS_BOOT /target/boot
```
```bash
sudo mkdir -p /target/boot/efi
```
```bash
sudo mount /dev/sdTARGET3 /target/boot/efi
```
```bash
sudo mkdir -p /target/home
```
```bash
sudo mount -o subvol=@home /dev/mapper/LUKS_ROOT /target/home
```
```bash
sudo mkdir -p /target/root
```
```bash
sudo mount -o subvol=@root /dev/mapper/LUKS_ROOT /target/root
```
```bash
sudo mkdir -p /target/snapshots
```
```bash
sudo mount -o subvol=@snapshots /dev/mapper/LUKS_ROOT /target/snapshots
```

All of the filesystems necessary to install to the Target USB stick should now be mounted under /target. To confirm this run the following command and compare your results to the screenshot shown below.

```bash
df -h
```

<img width="100%" alt="A screenshot showing the output of the `df -h` command." src="https://github.com/user-attachments/assets/440f2bf0-1384-4451-bf57-539589bf7fc2" />

The items that start with /target in the right-most column are the ones we are interested in. Their order doesn’t matter and the centre columns information will be different, but the left-most and right-most columns should match the screenshot with the exception of /dev/sda3 where the drive letter will match your TARGET drive.

At this point switch back to the installer window and click on the Next button in the bottom right. This will take you to a screen like the one shown below.

[!CAUTION]

 **It is very important that you deselect the checkbox circled in the screenshot below. A mistake here would overwrite the bootloader on the hard drive of the computer you are working on.**

 We will be manually installing the GRUB bootloader in order to pass the --removable option, which is required when installing to a USB stick and not available otherwise.

<img width="100%" alt="A screenshot showing the bootloader installation screen." src="https://github.com/user-attachments/assets/96473add-0334-487e-a22c-5e7566d93a04" />

After deselecting the GRUB installation checkbox click on the Next button.

The next screen will show a summary of the configuration like the screenshot below. Review yours to make sure it is accurate.  It is important that the “Filesystem operations” match the screenshot. If anything looks amis use the Back button to go back and make whatever changes are necessary.

<img width="100%" alt="A screenshot showing the installation configuation summary." src="https://github.com/user-attachments/assets/475e8b8a-f730-4c0d-977a-6a3001350701" />

After reviewing the summary click the Install button to start the actual installation process. Expect this process to take quite a while as it requires writing over 8GB of small files to the USB stick.

Eventually the install will pause at a screen like the one shown below. This is where we will do some final manual work.

<img width="100%" alt="A screenshot showing the Installation Paused screen." src="https://github.com/user-attachments/assets/c103eb5e-24f6-427e-86d4-ea57c222cf5c" />

At this point we will finalise the installation by manually creating the fstab and crypttab files, editing configuration so GRUB can work with LUKS encryption, installing additional software required to use GRUB on a USB stick, and then finally creating a new initial RAM disk and actually installing GRUB.

#### Create /etc/fstab File

The file /etc/fstab describes the fileystem table, the various filesystems that the operating system will use. Normally this is created automatically during the installation process, but because we are installing to an encrypted USB stick we need to create it ourselves. Switch back to the terminal by pressing `<alt><tab>` or clicking on the terminal icon and enter the following commands:

```bash
sudo bash -c “echo ‘PARTUUID=$(blkid -s PARTUUID -o value /dev/sdTARGET3) /boot/efi vfat umask=0077 0 1’ >> /target/etc/fstab”
```
```bash
sudo bash -c “echo ‘/dev/mapper/LUKS_ROOT / btrfs defaults,noatime,ssd,compress=lzo,subvol=@ 0 0’ >> /target/etc/fstab
```
```bash
sudo bash -c “echo ‘/dev/mapper/LUKS_BOOT /boot ext4 defaults,noatime 0 1’ >> /target/etc/fstab”
```
```bash
sudo bash -c “echo ‘/dev/mapper/LUKS_ROOT /home btrfs defaults,noatime,ssd,compress=lzo,subvol=@home 0 2’ >> /target/etc/fstab”
```
```bash
sudo bash -c “echo ‘/dev/mapper/LUKS_ROOT /root btrfs defaults,noatime,ssd,compress=lzo,subvol=@root 0 3’ >> /target/etc/fstab”
```
```bash
sudo bash -c “echo ‘/dev/mapper/LUKS_ROOT /snapshots btrfs defaults,noatime,ssd,compress=lzo,subvol=@snapshots 0 4’ >> /target/etc/fstab”
```

#### Create an Encryption Key File

The following commands will create a 4KB file of "random stuff" that will serve as an encryption key for the encrypted partitions. This initial key will be replaced by a unique key when the setup script is run by the end user.

```bash
sudo mkdir -p /target/etc/luks
```
```bash
sudo dd if=/dev/urandom of=/target/etc/luks/boot_os.keyfile bs=1024 count=4
```

#### Create the /etc/crypttab File

The file /etc/crypttab is used to decrypt the encrypted partitions and to map them to the correct filesystem in the fstab file created earlier. Use the following commands to create it:

```bash
sudo bash -c “echo ‘LUKS_BOOT UUID=$(blkid -s UUID -o value /dev/sdTARGET1) /etc/luks/boot_os.keyfile luks,discard’ >> /target/etc/crypttab”
```
```bash
sudo bash -c “echo ‘LUKS_ROOT UUID=$(blkid -s UUID -o value /dev/sdTARGET4) /etc/luks/boot_os.keyfile luks,discard’ >> /target/etc/crypttab”
```

#### Configure LUKS and GRUB to Work Together

Configure LUKS and Grub to be able to decrypt the filesystem. When you run the two cryptsetup commands you will be asked to enter the passphrase that was used to encrypt the partitions earlier.

```bash
sudo bash -c “echo ‘KEYFILE_PATTERN=/etc/luks/*.keyfile’ >> /target/etc/cryptsetup-initramfs/conf-hook”
```
```bash
sudo bash -c “echo ‘UMASK=0077’ >> /target/etc/initramfs-tools/initramfs.conf”
```
```bash
sudo chmod 500 /target/etc/luks
```
```bash
sudo chmod 400 /target/etc/luks/boot_os.keyfile
```
```bash
sudo cryptsetup luksAddKey /dev/sdTARGET1 /target/etc/luks/boot_os.keyfile
```
```bash
sudo cryptsetup luksAddKey /dev/sdTARGET4 /target/etc/luks/boot_os.keyfile
```
```bash
sudo bash -c “echo ‘GRUB_ENABLE_CRYPTODISK=y’ >> /target/etc/default/grub”
```

#### Connect to the Internet

Up to this point an Internet connection has not been required, however we need to get a few non-standard packages over the the next steps.  If you do not have an Internet connection you can stop at this point and return here later with only having to repeat the step to mount the various filesystems under /target.

<img width="100%" alt="A screenshot showing the wifi icon." src="https://github.com/user-attachments/assets/dd75b299-6349-463a-b274-b5823779c23c" />

After connecting to the Internet return to the terminal and continue the following steps.

#### Create Initial RAM Disk

To create the initial RAM disk (initrd) run the following commands:

```bash
sudo mount --bind /dev /target/dev
```
```bash
sudo mount --bind /dev/pts /target/dev/pts
```
```bash
sudo mount --bind /proc /target/proc
```
```bash
sudo mount --bind /sys /target/sys
```
```bash
sudo mount --bind /sys/firmware/efi/efivars /target/sys/firmware/efi/efivars
```
```bash
sudo mount --bind /run /target/run
```
```bash
sudo mount --bind /etc/resolv.conf /target/etc/resolv.conf
```
```bash
sudo chroot /target
```
```bash
mount -a
```

The chroot command above stands for change root, which effectively makes the /target directory become the / directory. This is necessary because we want to use all the configuration on the Target USB stick and we want the results to be written to the Target USB stick.

If there are any error messages after running the `mount -a` command it indicates an error in the fstab file.

Run the following commands to install the necessary grub related tools and create the initial RAM disk.

```bash
apt-get update && sudo apt-get -y install grub-common grub-efi-amd64 os-prober
```
```bash
/usr/sbin/update-initramfs -u -k all
```

#### Install GRUB

Run the following commands to install GRUB

```bash
grub-install --removable /dev/sdTARGET
```
```bash
update-grub
```

#### Install Any Additional Software

If you would like to add any additional software you can install it now using the apt package manager. For our disk image no additional software is added, instead additional software is added by the setup script that is run by the end user. In this way the disk image is kept a little smaller.

#### Exit the chroot

To continue the next steps we will need to exit the chroot by using the following command:

```bash
exit
```

#### Automate System Set-Up

In order to simplify the system set-up process for the end user a [setup script](setup/setup.sh) has been created that automates the process of changing the LUKS encryption passphrase and encryption key, adding a new user account, disabling the original setup user account, adding and encrypting a swap partition, growing the root filesystem to use the entire USB stick, and installing any additional software. The setup script is configured to run automatically when the user logs in. Over the next few steps we will set this up.

Download the setup script and a second file that will automatically start it using the following commands:

```bash
cd ~/Downloads
```
```bash
wget https://github.com/shitfuckery/usb_stick/raw/refs/heads/main/setup/setup.sh
```
```bash
wget https://github.com/shitfuckery/usb_stick/raw/refs/heads/main/setup/.config/autostart/USB%20System%20Setup.desktop
```

Enable the automatic running of the setup.sh script by moving the two downloaded files into the correct locations:

```bash
sudo mkdir -p /target/home/setup/.config/autostart /target/etc/skel/.config/autostart
```
```bash
sudo cp /home/mint/Downloads/setup.sh /target/usr/local/bin/setup.sh
```
```bash
sudo chmod 755 /target/usr/local/bin/setup.sh
```
```bash
sudo cp /home/mint/Downloads/USB\ System\ Setup.desktop /target/etc/skel/.config/autostart/
```
```bash
sudo mv /home/mint/Downloads/USB\ System\ Setup.desktop /target/home/setup/.config/autostart/
```

Allow setup.sh to be run as root with sudo without requiring a password for users in the sudo group. This is done to allow the setup.sh script to be run automatically by both the setup user and also by the user account created during the setup process so that it can clean up after itself by removing the setup user once it is no longer necessary. This file is automatically removed at the end of the setup process by setup.sh.

```bash
sudo bash -c "echo '%sudo	ALL=(ALL:ALL) NOPASSWD:/usr/local/bin/setup.sh' > /target/etc/sudoers.d/setup"
```
```bash
sudo chmod 440 /target/etc/sudoers.d/setup
```


#### Customise Configuration

You can customise the configuration of future user accounts by adding the custom configuration to the /target/etc/skel directory. Files in this directory will be copied to the home directory of any future users, such as the one the setup.sh script creates.

In our exapmle we download a gist from github and add it to the end of the /target/etc/skel/.bashrc file that will add a beer emoticon to the bash prompt after 4pm on Fridays because sometimes we need a reminder. You could of course do more useful things, like configure software in a particular way, such as disabling third-party cookies in the browsers, enabling a default VPN, pinning particular applications to the task bar, etc.


Download the [gist](https://gist.github.com/beanjammin/1a3978ce41b9a621ef84075047deffb8) with the following command:

```bash
wget https://gist.github.com/beanjammin/1a3978ce41b9a621ef84075047deffb8/raw/ddb11141ea7d8255296200abe429b04975eca305/gistfile1.txt
```

Now add the gistfile contents to the end of the /target/etc/skel/.bashrc file with the following command:

```bash
sudo bash -c "cat gistfile1.txt >> /target/etc/skel/.bashrc
```

Set the Hostname

```bash
sudo echo "usbstick-setup" > /target/etc/hostname
```

Download Bitwarden and make it available.

The last bit of customisation to finish off the recipe is the installation of the Bitwarden Linux client. While it's great that Bitwarden provide the Linux client in a .deb format, unfortunately it is not in a proper repository so it can not be installed with apt-get.  Additionally the download process requires javascript, so we can not easily script it's download, so it has to be done manually.

Bitwarden's Linux client can be downloaded from [https://bitwarden.com/download/](https://bitwarden.com/download/).  Be sure to download the .deb version and copy it to the setup user's home directory.  At the time of writing the version is Bitwarden-2025.7.0-amd64.deb.  Assuming you downloaded the file to the Downloads directory you can copy it the setup user's home directory with the following command:

```bash
sudo cp ~/Downloads/Bitwarden-2025.7.0-amd64.deb /target/home/setup/
```

As the version number is bound to have changed, be sure to update the BITWARDEN variable near the top of the setup.sh script.

In a future write up we plan to discuss pairing the Bitwarden client with [Vaultwarden](https://github.com/dani-garcia/vaultwarden/) a Bitwarden compatible server that provides enterprise-like password sharing a permissions functionality, but with a GNU AGPLv3 license.

Congratulations, you are done!
