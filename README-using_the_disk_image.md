# Create an Encrypted USB Stick Based Linux Mint System

These instructions will walk you through the process of using the associated disk image to create your own encrypted USB stick based Linux Mint system. The instructions vary based on whether you are using a computer running Windows, MacOS, or Linux. The resulting USB stick can be used on any 64 bit x86 based computer (Intel or AMD CPU) including Intel based Apple computers. The resulting USB stick can not be used on computers using Apple's own ARM based CPUs, however the creation of the USB stick itself can be done on ARM based computers.

## Requirements

The following 3 files downloaded to your computer:
Disk Image: https://drive.google.com/file/d/1IcqVFhNwCa6Co5bCC9ergWz3HbWLb9WX/view?usp=sharing
SHA256sum: https://drive.google.com/file/d/1wv6HUucXcYjicNXm3N1yvQj2wu9YWpII/view?usp=sharing
GPG Signature: https://drive.google.com/file/d/1xcYVQbNeAKmKepDZeLzVdngE3acpfezv/view?usp=sharing

A USB stick that is at least 16GB in size. A larger USB stick will provide more room for your own software and files. We typically use 128GB sticks, but the size you need will depend on the size of files you intend to use and how much additional software you intend to install.

## Validate the Disk Image

Validating the disk image assures you that the file has be downloaded properly, that it has not been altered in any way since being posted, and that it was posted by us.

At the time of writing the disk image version number is 0.90. If the version number has changed update the following commands accordingly. The following commands assume you have saved the files to your user's Downloads directory. If you have saved the files somewhere else upate the following commands accordingly.

## Check the SHA256sum of the disk image:

An SHA256sum is a hash of seemingly random characters calculated based on the contents of a file. Two identical files will result in the same hash being generated while even the most minor change will result in a different hash being generated.  If the two hashes match you can be assured that the disk image you downloaded is the same as the one used to generate the SHA256sum file. If the two hashes are not the same the files do not match and you should not use the disk image.

### Windows
Open a cmd prompt (press the windows key and type cmd then press enter) type the following (updating the path to the file to match where you saved the disk image):

```bash
certutil -hashfile C:\Users\user1\Downloads\usb_drive_disk_image-release-0.9.0.img SHA256
```

Compare the output from the previous command with the contents of the usb_drive_disk_image-release-0.9.0.img.sha256sum file:

```bash
type C:\Users\user1\Downloads\usb_drive_disk_image-release-0.9.0.img.sha256sum
```

### MacOS:
Open a terminal and type the following:

```bash
shasum -a 256 ~/Downloads/usb_drive_disk_image-release-0.9.0.img
```

Compare the output from the previous command with the contents of the usb_drive_disk_image-release-0.9.0.img.sha256sum file:

```bash
cat ~/Downloads/usb_drive_disk_image-release-0.9.0.img.sha256sum
```

### Linux:
Open a terminal and type the following:

```bash
sha256sum ~/Downloads/usb_drive_disk_image-release-0.9.0.img
```

Compare the output from the previous command with the contents of the usb_drive_disk_image-release-0.9.0.img.sha256sum file:

```bash
cat ~/Downloads/usb_drive_disk_image-release-0.9.0.img.sha256sum
```


## Check the GPG Signature of the .sha256sum File 

GPG (Gnu Privacy Guard) is available on Windows, MacOS, and Linux. Once installed the commands to use it are the same on each platform.  GPG uses public key encryption which, among other things, allows you to confirm that a file has been signed by a specific secret key. In our case the .sha256sum file will be signed by the key belonging to code@shitfuckery.ca and the signature stored in the file ending with .sig.

GPG is installed by default on Linux. For Windows and MacOS use the following instructions.

### Windows

If you do not already have gpg installed on your computer you can get it from [gpg4win.org](https://gpg4win.org/download.html). Follow the instructions there to install gpg4win. 

### MacOS
If you do not already have gpg installed on your computer you can get it from [gpgtools.org](https://gpgtools.org) or install it with brew using the command `brew install gnupg`.

### To validate the signature on Windows, MacOS, or Linux

Use the following commands from the terminal / command prompt to search for our public key and download it to your computer.

```bash
gpg --keyserver keyserver.ubuntu.com --search-keys code@shitfuckery.ca
```

Verify that the .sha256sum file was signed by our secret GPG key using the following command:

```bash
gpg --verify ~/Downloads/usb_drive_disk_image-release-0.9.0.img.sha256sum.sig ~/Downloads/usb_drive_disk_image-release-0.9.0.img.sha256sum
```

The output of the above command should include text along the lines of the following:

```
gpg: Signature made Thu 10 Jul 2025 12:44:39 PM PDT
gpg:                using EDDSA key BA4EF26A2E2AFB3F8D017C886CD4FFD1C1C1952A
gpg:                issuer "code@shitfuckery.ca"
gpg: Good signature from "Shitfuckery Code Signing <code@shitfuckery.ca>"
```

If the command did not output similar text saying that the signature is good there is a problem with the signature file and you should _NOT_ use the disk image. Please contact us at code@shitfuckery.ca and include "Disk image validation problem" in the email subject and the text that was output by the above command in the body of your email.

## Write the Disk Image to a USB stick

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
ls -l /dev/drive*
```

#### Linux
```bash
ls -l /dev/sd*
```

Now plug in the USB stick and run the above command a second time. You should see an additional drive listed. The newly listed drive is your USB stick.

Screenshot from MacOS showing the before and after output:

The USB stick in this case is name /dev/drive2. On your computer this may be different.

Screenshot from Linux showing the before and after output:

The USB stick in this case is name /dev/sda. On your computer this may be different.

With the drive name determined substitute it into the following command:

```bash
sudo dd if=~/Downloads/usb_drive_disk_image-release-0.9.0.img of=/dev/<name of your drive>
```

By default the dd command does not return any progress indicator while it is running.  On MacOS you can press `<control>-T` to show progress and on linux you can add `status=progress` to the command (eg `dd if=disk.img of=/dev/<name of your drive> status=progress`).

The dd command can be expected to take up to 45 minutes to run, with it being faster or slower depending on the speed of your USB stick. When it finishes the drive image will have been written to the USB stick.


## Boot the Computer Using the USB Stick

Each computer has a special "hot key" that when pressed during the boot process will allow you to boot from a USB device. This key is often shown on the initial boot screen when the computer is powered on. On Framework and Dell computers pressing the `F12` key during the boot process will bring up the Boot Options menu and allow you to chose to boot from the USB Stick. On Macs holding down the `<option>` key while powering on the computer will bring up the Boot Options menu. On other computers the key may be different. Your computer's user manual will have this information and [this site](https://www.disk-image.com/faq-bootmenu.htm) has a good list of manufacturers and the hot key to press to bring up the Boot Menu. As you will see F12, ESC, F8, or F9 cover the most common ones.

With the USB stick connected to your computer power it on and press the hot key to bring up the boot options menu and select the USB stick to boot from it.

Very shortly into the boot process you will see output similar to this screenshot where the bootloader asks for a password/passphrase to decrypt the USB stick so that it can continue the boot process. 


screenshot of the grub passphrase screen


Enter the default disk encryption passphrase "setup" to continue the boot process. Be aware that this may take some time, so be patient.  You will eventual end up at a screen that looks like the following screenshot.


screenshot of login screen


## Log in as setup with the password setup

When you log in as the setup user a script will open a window like the one below.  Follow the instructions in the script to encrypt the USB stick with your own passphrase and encryption key, remove the stock passphrase and encryption key, create a new user account, disable the stock 'setup' user, and grow the filesystem so that it uses all of your USB stick. Once the script has finished you can log out as the setup user and log in as the newly created user.

Enjoy your new USB stick based Linux Mint install!

Next Steps:

Install Updates - be aware that this will take quite a while as there will be a lot to install.
Install additional software
Explore
