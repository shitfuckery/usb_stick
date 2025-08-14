# Create an Encrypted USB Stick Based Linux Mint System

These instructions will walk you through the process of using the disk image linked below to create your own encrypted USB stick based Linux Mint system. The instructions vary based on whether you are using a computer running Windows, MacOS, or Linux. The resulting USB stick can be used on any 64 bit x86 based computer (Intel or AMD CPU) including Intel based Apple computers. The resulting USB stick can not be used on computers using Apple's own ARM based CPUs, however the creation of the USB stick itself can be done on ARM based computers.

*  [Requirements](#requirements)
*  [Validate the Disk Image](#validate-the-disk-image)
   *  [Check the SHA256sum of the Disk Image](#check-the-sha256sum-of-the-disk-image)
      *  [Windows](#windows)
      *  [MacOS](#macos)
      *  [Linux](#linux)
   *  [Check the GPG Signature of the .sha256sum File](#check-the-gpg-signature-of-the-sha256sum-file)
      *  [To Validate the Signature on Windows, MacOS, or Linux](#to-validate-the-signature-on-windows-macos-or-linux)
*  [Write the Disk Image to a USB Stick](#write-the-disk-image-to-a-usb-stick)
   *  [Windows)](#windows)
   *  [MacOS and Linux](#macos-and-linux)
      *  [MacOS](#macos)
      *  [Linux](#linux)
*  [Boot the Computer Using the USB Stick](#boot-the-computer-using-the-usb-stick)
*  [Log-in as setup with the Password setup](#log-in-as-setup-with-the-password-setup)
*  [Next Steps](#next-steps)
   *  [Install Updates](#install-updates)
   *  [Install Additional Software](#install-additional-software)
   *  [Explore](#explore)


## Requirements

*  The following 3 files downloaded to your computer:
   *  The Disk Image [usb_drive_disk_image-release-0.9.1.img](https://drive.google.com/file/d/1793e18WW2609yOq_INA1Bd0K9OyXtkEO/view?usp=sharing)
   *  An SHA256 hash of the disk image [usb_drive_disk_image-release-0.9.1.img.sha256sum](https://drive.google.com/file/d/1sac3oDU_vMvkOMTa7jECM0f4dTM9r45S/view?usp=sharing)
   *  A GPG signature of the sha256sum file using code@shitfuckery.ca's GPG key [usb_drive_disk_image-release-0.9.1.img.sha256sum.sig](https://drive.google.com/file/d/1MpKDAR0Evdus2Y9C-T9EuLEbafh7wb2E/view?usp=sharing)
*  A USB stick that is at least 16GB in size. A larger USB stick will provide more room for your own software and files. We typically use 128GB sticks, but the size you need will depend on the size of files you intend to use and how much additional software you intend to install.
*  Windows users will need the program [Rufus](https://rufus.ie/en/) to put the disk image onto a USB stick.
*  Gnu Privacy Guard (GPG) for confirming the integrity of the disk image.
   *  Windows [gpg4win.org](https://gpg4win.org/download.html) Follow the instructions there to install gpg4win.
   *  MacOS [gpgtools.org](https://gpgtools.org) or install it with brew using the command `brew install gnupg`.
   *  Linux includes GPG by default, if for some reason you don't already have it use your distro's package management tools to install it (eg `apt install gpg`)

## Validate the Disk Image

Validating the disk image assures you that the file has be downloaded properly, that it has not been altered in any way since being posted, and that it was posted by us.

At the time of writing the disk image version number is 0.9.1. If the version number has changed update the following commands accordingly. The following commands assume you have saved the files to your user's Downloads directory. If you have saved the files somewhere else upate the following commands accordingly.

### Check the SHA256sum of the Disk Image:

An SHA256sum is a hash of seemingly random characters calculated based on the contents of a file. Two identical files will result in the same hash being generated while even the most minor change will result in a different hash being generated.  If the two hashes match you can be assured that the disk image you downloaded is the same as the one used to generate the SHA256sum file. If the two hashes are not the same the files do not match and you should not use the disk image.

#### Windows
Open a cmd prompt (press the windows key and type cmd then press enter) type the following (updating the path to the file to match where you saved the disk image):

```bash
certutil -hashfile C:\Users\user1\Downloads\usb_drive_disk_image-release-0.9.1.img SHA256
```

Compare the output from the previous command with the contents of the usb_drive_disk_image-release-0.9.1.img.sha256sum file:

```bash
type C:\Users\user1\Downloads\usb_drive_disk_image-release-0.9.1.img.sha256sum
```

#### MacOS:
Open a terminal and type the following:

```bash
shasum -a 256 ~/Downloads/usb_drive_disk_image-release-0.9.1.img
```

Compare the output from the previous command with the contents of the usb_drive_disk_image-release-0.9.1.img.sha256sum file:

```bash
cat ~/Downloads/usb_drive_disk_image-release-0.9.1.img.sha256sum
```

#### Linux:
Open a terminal and type the following:

```bash
sha256sum ~/Downloads/usb_drive_disk_image-release-0.9.1.img
```

Compare the output from the previous command with the contents of the usb_drive_disk_image-release-0.9.1.img.sha256sum file:

```bash
cat ~/Downloads/usb_drive_disk_image-release-0.9.1.img.sha256sum
```


### Check the GPG Signature of the .sha256sum File 

GPG (Gnu Privacy Guard) is available on Windows, MacOS, and Linux. Once installed the commands to use it are the same on each platform.  GPG uses public key encryption which, among other things, allows you to confirm that a file has been signed by a specific secret key. In our case the .sha256sum file will be signed by the key belonging to code@shitfuckery.ca and the signature stored in the file ending with .sig.

GPG is installed by default on Linux. For Windows and MacOS use the following instructions.

#### To Validate the Signature on Windows, MacOS, or Linux

Use the following commands from the terminal / command prompt to search for our public key and download it to your computer.

```bash
gpg --keyserver keyserver.ubuntu.com --search-keys code@shitfuckery.ca
```

Verify that the .sha256sum file was signed by our secret GPG key using the following command:

```bash
gpg --verify ~/Downloads/usb_drive_disk_image-release-0.9.1.img.sha256sum.sig ~/Downloads/usb_drive_disk_image-release-0.9.1.img.sha256sum
```

The output of the above command should include text along the lines of the following:

```
gpg: Signature made Thu 10 Jul 2025 12:44:39 PM PDT
gpg:                using EDDSA key BA4EF26A2E2AFB3F8D017C886CD4FFD1C1C1952A
gpg:                issuer "code@shitfuckery.ca"
gpg: Good signature from "Shitfuckery Code Signing <code@shitfuckery.ca>"
```

The command is likely to output an additional warning that our GPG key is not signed by a key you trust, this is expected and does not effect the confirmation that our GPG key was used to sign the sha256sum file.

If the command did not output similar text saying that the signature is good there is a problem with the signature or sha256sum file and you should _NOT_ use the disk image. Please create an issue on github.com or contact us at code@shitfuckery.ca and include "Disk image validation problem" in the email subject and the text that was output by the above command in the body of your email.


## Write the Disk Image to a USB Stick

After the disk image has been validated it is safe to use.

The disk image contains many files, using it requires more than just copying the disk image file to the USB stick.  On MacOS and Linux the program dd is used.  On Windows the use of the program Rufus is recommended.

### Windows

Download the program [Rufus](https://rufus.ie/en/).
Good instructions for using Rufus are available [here](https://www.winhelponline.com/blog/windows-iso-to-usb-dvd-tool-bootable-media/#rufus). Note that ISO and IMG files are effectively the same thing so where the instructions reference an ISO or .iso file you can substitute the disk image file downloaded above that ends with .img.

### MacOS and Linux

We will be using the program `dd` from the terminal to write the disk image to the USB stick. The first step will be to determine the name your computer gives to the USB stick so that we can refer to it properly when using dd.

To determine the name of the USB stick on your computer we will run the following commands twice, once without the USB stick plugged into your computer and a second time with it plugged in.  The command used varies slightly between MacOS and Linux.

Before plugging in the USB stick run the following command and note the drives listed:

#### MacOS
```bash
ls -l /dev/disk*
```

#### Linux
```bash
ls -l /dev/sd*
```

Now plug in the USB stick and run the above command a second time. You should see an additional drive listed. The newly listed drive is your USB stick.

>[!WARNING]
>It is important to ensure you write the disk image to the correct drive. A mistake here could overwrite the hard drive on the computer you are using.

Screenshot from MacOS showing the before and after output:

<img width="100%" alt="MacOS screenshot showing the before and after plugging in the USB drive output of ls -l /dev/disk*" src="https://github.com/user-attachments/assets/494140a6-c890-468f-99ad-1f0fc12191a2" />

The USB stick in this case is named /dev/disk2. On your computer this may be different.

Screenshot from Linux showing the before and after output:

<img width="100%" alt="Linux screenshot showing the before and after plugging in the USB drive output of ls -l /dev/sd*" src="https://github.com/user-attachments/assets/35ad20e0-898f-4b38-afdc-bcbf501ce3bf" />

The USB stick in this case is name /dev/sda. On your computer this may be different.

With the drive name determined substitute it into the following command:

```bash
sudo dd if=~/Downloads/usb_drive_disk_image-release-0.9.1.img of=/dev/<name of your drive>
```

By default the dd command does not return any progress indication while it is running.  On MacOS you can press `<control>-T` to show progress and on linux you can add `status=progress` to the command (eg `dd if=disk.img of=/dev/<name of your drive> status=progress`).

The dd command can be expected to take up to 45 minutes to run, with it being faster or slower depending on the speed of your USB stick. When it finishes the drive image will have been written to the USB stick.


## Boot the Computer Using the USB Stick

Each computer has a special "hot key" that when pressed during the boot process will allow you to boot from a USB device. This key is often shown on the initial boot screen when the computer is powered on. On Framework and Dell computers pressing the `F12` key during the boot process will bring up the Boot Options menu and allow you to chose to boot from the USB Stick. On Macs holding down the `<option>` key while powering on the computer will bring up the Boot Options menu. On other computers the key may be different. Your computer's user manual will have this information and [this site](https://www.disk-image.com/faq-bootmenu.htm) has a good list of manufacturers and the hot key to press to bring up the Boot Menu. As you will see F12, ESC, F8, or F9 cover the most common ones.

With the USB stick connected to your computer power it on and press the hot key to bring up the boot options menu and select the USB stick to boot from it.

Very shortly into the boot process you will see output similar to this screenshot where the bootloader asks for a password/passphrase to decrypt the USB stick so that it can continue the boot process. 


<img width="100%" alt="Photo showing a computer screen and text asking the user to enter a password to decrypt the drive" src="https://github.com/user-attachments/assets/235d7c36-b819-4b71-bcb2-cc09238e745f" />


Enter the default disk encryption passphrase "setup" and press `Enter` to continue the boot process. Be aware that this may take some time, so be patient.  You will eventual end up at a screen that looks like the following screenshot.


<img width="100%" alt="Photo showing the initial login window for Linux Mint. In this case the setup user is being prompted for their password." src="https://github.com/user-attachments/assets/605e2d84-c649-43eb-947e-d7b2eadb00e9" />



## Log in as setup with the Password setup

Log in as the user setup with the password `setup`.

A few seconds after you log in as the setup user a script will open a window like the one below.  Follow the instructions in the script to set up your encrypted USB stick. The script will:

  * Reencrypt the boot and root partitions so that they are using Volume Keys unique to your USB stick
  * Add your encryption passphrase to the boot and root partitions and remove the stock passphrase
  * Create a new user account for your use
  * Disable the stock 'setup' user
  * Grow the filesystem so that it uses all of your USB stick
  * Install Tor Browser, Signal, Chrommium, and Bitwarden
  * Make some minor customisations as an example
  * When you log in as your new user the script will remove the 'setup' user and clean up after itself 


<img width="100%" alt="Screenshot of the Linux Mint desktop shortly after the setup user has logged in for the first time." src="https://github.com/user-attachments/assets/b0ee77db-f765-4011-af37-b9645ed01247" />

As you can see in the screenshot above, a warning about being low on disk space is expected. The setup script will grow the filesystem on your USB stick, which will give you access to the full size of your USB stick and get rid of this warning message.

If you have access to an internet connection please set it up so that the script can install Tor, Signal, and Chromium. Click on the icon in the bottom right circled in red in the screenshot below to connect to wifi.

<img width="100%" alt="A screenshot showing the wifi icon." src="https://github.com/user-attachments/assets/dd75b299-6349-463a-b274-b5823779c23c" />

Enjoy your new Linux Mint on an encrypted USB stick!

### Next Steps:

#### Install Updates 

Like any newly set-up computer there will be a lot of updates to install. Updates can be installed by clicking on the shield icon in the lower right of the screen. Please take care of this as soon as possible. You can expect there to be quite a lot of updates to install. 

<img width="100%" alt="Screenshot showing how to launch Update Manager" src="https://github.com/user-attachments/assets/817fc3ee-2855-4cc1-ae01-4516d73c69fc" />


<img width="100%" alt="Screenshot showing the Update Manager" src="https://github.com/user-attachments/assets/d0ef85a9-9c6a-4ffa-a801-61cabfd476ec" />


#### Install Additional Software

There is a very wide selection of software for Linux Mint. Install the software you want. Make it your own.

Launch the Software Manager under the "Start" menu.

<img width="100%" alt="Screenshot showing how to launch Software Manager" src="https://github.com/user-attachments/assets/cf06be54-feee-4ad8-9aa0-ee13d0ad4d5c" />

Then select the software you would like to install.

<img width="100%" alt="Screenshot showing the launched Software Manager" src="https://github.com/user-attachments/assets/0f9b2ea7-a459-47c3-be1d-003f8d0a9ffa" />


#### Explore

Poke around and get to know your system and set it up the way you want it.  A good place to start is in the System Settings.

<img width="100%" alt="Screenshot showing how to launch System Settings from under the 'Start' menu" src="https://github.com/user-attachments/assets/49c27a2f-449f-49ad-a9fe-1a2520729232" />

A good place to start in System Settings is in enabling the firewall.

<img width="2256" height="1504" alt="Screenshot from 2025-08-08 16-09-48" src="https://github.com/user-attachments/assets/05ea18ce-23e5-4f63-958f-81878f023daf" />

Set the system up the way you want it.  Enjoy!
