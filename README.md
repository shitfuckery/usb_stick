# The Shitfuckery USB Stick

## A complete Linux Mint system on an encrypted USB stick. Your OS, your software, your files, your privacy, any computer.

<!-- Future home of an image to represent the Shitfuckery USB Stick -->

*  [Quick Start](#quick-start)
*  [Background](#background)
   *  [What You Get](#what-you-get)
   *  [Why Linux Mint](#why-linux-mint)
   *  [On Privacy, Security, And Trust](#on-privacy-security-and-trust)
   *  [On USB Sticks](#on-usb-sticks)
*  [Two Paths](#two-paths)
   *  [The Disk Image (Recommended for most people)](#the-disk-image)
      *  [Disk Image Instructions](README-using_the_disk_image.md)
   *  [The Recipe - DIY Your Own and Understand the Process](RECIPE.md)
*  [Possible Next Steps](#possible-next-steps)

## Quick Start

Download the latest disk image and validate it with the sha256sum and signature files.

   *  The Disk Image [usb_drive_disk_image-release-1.0.1.img](https://drive.google.com/file/d/1M3Aeu9Icm7-tvmDO5LJEf08odGyvV9g9/view?usp=sharing)
   *  A sha256sum hash of the disk image [usb_drive_disk_image-release-1.0.1.img.sha256sum](https://drive.google.com/file/d/1SyshEk7VLiTdwWowH0A6mGcEyYURAhJq/view?usp=sharing)
   *  A GPG signature of the sha256sum file using code(at)shitfuckery.ca's GPG key [usb_drive_disk_image-release-1.0.1.img.sha256sum.sig](https://drive.google.com/file/d/1dLAiyIVHZshxmR6IArkCBuCfMDHQcqpP/view?usp=sharing)

Use Rufus (Windows) or dd (MacOS and Linux) to write the disk image to a USB stick that is at least 16GB in size (larger is much better). Do not just copy the disk image file to the USB stick. (If that last bit doesn't make sense please use the longer instructions.)

Boot your computer from the USB stick using 'setup' as the password whenever asked and follow the instructions in the terminal window that opens automatically to complete the set-up. Enjoy! 

## Background

Sometimes a person realises a need to elevate their privacy requirements. In the world of computing this can be disruptive to the usual way of doing things. What if you could plug a USB stick into almost any computer, boot from it, and be in a more private environment? One setup the way you want, with your software, your files, and your configuration. Reboot again without the USB stick and the computer is exactly as it was, completely unchanged. Sound interesting? Read on!

### What You Get

The end result will be a fully functional Linux Mint installation that will run from a removable encrypted USB stick. The stick can be used to boot any UEFI compatible computer with a 64bit x86 CPU (AKA anything that runs Windows or an Intel based Mac). It will function exactly as if it was installed on a hard drive in that software can be added or removed, customised in any way, and all configuration and data changes will persist across boots. This is accomplished by installing Linux Mint and the GRUB boot loader to the USB stick as if it was a normal hard drive. Boot any computer with your USB stick and make it your own. Reboot without the USB stick and its back the way it was.

### Why Linux Mint?

Linux Mint was chosen because it has a polished and accessible interface and is known for its user friendliness. If you are coming from Windows or MacOS you will most likely be able to quickly become familiar with Linux Mint. It basically "just works" and stays out of your way.

We are using the Linux Mint Debian Edition (LMDE) variation which, as the name suggests, builds on the Debian Linux distribution. Ubuntu, another popular Linux distribution also builds on Debian so you will usually be able to use software packaged for either of those systems without any changes. Linux Mint uses the apt package manager which makes installing and updating all of the software on your system easy. You could reasonably consider apt the original App Store, but since it's all Free/Libre Open Source Software it's not called a store, it's just how you manage your software.

The tools used are industry standard Libre / Open Source tools that have been well vetted and tested.

### On Privacy, Security, And Trust

This USB stick uses [LUKS](https://access.redhat.com/solutions/100463) (Linux Unified Key Setup) to provide full disk encryption of the USB stick. LUKS is an open specification industry standard that has been well vetted by people who know far more about encryption than we ever will. If you pair LUKS with a strong passphrase and do not share that passphrase you can rest assured that no one will be able to read your files. This provides a foundation on which further privacy and security can be built, but it is important to remember that security is much more than privacy alone.

Encryption and account security is only as good as the passwords that protect them. Consider using a password manager (like the included Bitwarden) and never reuse a password. A passphrase is often easier to remember and provides better security than a complicated password. An example might be “Yellow dogs can’t play with wet spiders” (please don't use this example). In the rest of this document I will use the term passphrase instead of password as a nudge in that direction.

There's a saying in System Administration, I know I'm paranoid, but am I paranoid enough? Security is not an absolute. Different people or organisations face different security risks and requirements. You are a much better judge of the risks you face than I am. Broadly speaking, the aspects to consider are the applications used, their configuration, and your network usage. These are enormous topics that can not be properly covered here. The general compromise tends to be around usability versus security. For many situations the compromises made in the default Linux Mint install provide what I consider a well balanced starting point. It provides a solid foundation on which to build. 

Trust is a hard one. We don't know each other. If you download and boot from the disk image we created you are implicitly trusting us not to do something nefarious. Maybe you are willing to take that risk, maybe you aren't. We have provided both the finished disk image _and_ the recipe used to create it in the hope that if you don't trust the disk image you will still find this useful because you can vet and follow the recipe to create your own disk image that you will be able to trust. We raise this issue because we think it is important for you to be aware of the issues around trust in software and computing in general.

### On USB Sticks

Reliability is everything. Despite best efforts I have bought enough unreliable garbage online that I no longer try. I now buy USB sticks at a local retailer that will take returns and only buy name brand drives. Right after reliability, consider USB-A vs USB-C and which one you are most likely to run into. At the time of writing, November 2025, I use a low profile USB-A drive and have a USB-A to USB-C adapter I sometimes use.  After reliability and interface, consider speed. All USB sticks can be read from much faster than they can be written to. The write speed has the most impact on the performance of a USB stick based system, and it is also the one that USB stick marketing materials are most evasive about. This is where talking to a store clerk might help. Photography shops will have informed opinions. Outside of this you basically have to buy and test.

When using a USB stick based system you will notice slow write speeds if/when the system freezes up while waiting for a write to finish. While this is happening you may be unable to interact with the system. Patience is eventually rewarded and the system’s responsiveness will return once the write has finished. How frequently this happens and how long it takes to clear will depend on the write speed of the USB stick.

## Two Paths

We provide two paths to an encrypted USB stick based system, you can either download the disk image and put it on a USB stick or you can follow the recipe and create your own encrypted USB stick system from scratch. As mentioned above, one reason you might chose to follow the Recipe path is because you would rather not trust us or the disk image we created. Totally understandable. Another reason to follow the recipe is to understand the process more and/or to customise it to your needs.

### The Recipe

The recipe describes the steps used to create the disk image discussed further below. The intention was to create as small a disk image as possible so that it could be redistributed without people having to download too large a file (yes, 8+GB is still plenty large) and to provide an automated way to help with the initial setup. By following the recipe you will be able to vet the steps taken, understand the process, and make any customisations you require.

You can find the [recipe instructions here](RECIPE.md).

### The Disk Image (Recommended for most people)

#### Requirements

*  The following 3 files downloaded to your computer:
   *  The Disk Image [usb_drive_disk_image-release-1.0.1.img](https://drive.google.com/file/d/1M3Aeu9Icm7-tvmDO5LJEf08odGyvV9g9/view?usp=sharing)
   *  An SHA256 hash of the disk image [usb_drive_disk_image-release-1.0.1.img.sha256sum](https://drive.google.com/file/d/1SyshEk7VLiTdwWowH0A6mGcEyYURAhJq/view?usp=sharing)
   *  A GPG signature of the sha256sum file using code(at)shitfuckery.ca's GPG key [usb_drive_disk_image-release-1.0.1.img.sha256sum.sig](https://drive.google.com/file/d/1dLAiyIVHZshxmR6IArkCBuCfMDHQcqpP/view?usp=sharing)
*  A USB stick that is at least 16GB in size. A larger USB stick will provide more room for your own software and files. We typically use 128GB sticks, but the size you need will depend on the size of files you intend to use and how much additional software you intend to install.
*  Windows users will need the program [Rufus](https://rufus.ie/en/) to write the disk image onto a USB stick.
*  Gnu Privacy Guard (GPG) for confirming the integrity of the disk image.
   *  Windows [gpg4win.org](https://gpg4win.org/download.html) Follow the instructions there to install gpg4win.
   *  MacOS [gpgtools.org](https://gpgtools.org) or install it with brew using the command `brew install gnupg`.
   *  Linux includes GPG by default, if for some reason you don't already have it use your distro's package management tools to install it (eg `apt install gpg`)

#### Validate the Disk Image

Strictly speaking this step isn't necessary, however it is a Very Good Idea(tm). Validating the disk image assures you that the file has been downloaded properly, that it has not been altered in any way since being posted, and that it was posted by us. This should be part of your decision about whether to trust the disk image or not. If it does not validate DO NOT use the disk image.

At the time of writing the disk image version number is 1.0.1. If the version number has changed update the following commands accordingly. The following commands assume you have saved the files to your Downloads directory. If you have saved the files somewhere else adjust accordingly.

##### Check the SHA256sum of the Disk Image:

An SHA256sum is a hash of seemingly random characters calculated based on the contents of a file. Two identical files will result in the same hash being generated while even the most minor change will result in a different hash being generated.  If the two hashes match you can be assured that the disk image you downloaded is the same as the one used to generate the SHA256sum file. If the two hashes are not the same the files do not match and you should not use the disk image.

###### Windows
Open a cmd prompt (press the windows key and type cmd then press enter) and type the following:

```bash
certutil -hashfile C:\Users\user1\Downloads\usb_drive_disk_image-release-1.0.1.img SHA256
```

Compare the output from the previous command with the contents of the usb_drive_disk_image-release-1.0.1.img.sha256sum file:

```bash
type C:\Users\user1\Downloads\usb_drive_disk_image-release-1.0.1.img.sha256sum
```

###### MacOS:
Open a terminal and type the following:

```bash
shasum -a 256 ~/Downloads/usb_drive_disk_image-release-1.0.1.img
```

Compare the output from the previous command with the contents of the usb_drive_disk_image-release-1.0.1.img.sha256sum file:

```bash
cat ~/Downloads/usb_drive_disk_image-release-1.0.1.img.sha256sum
```

###### Linux:
Open a terminal and type the following:

```bash
sha256sum ~/Downloads/usb_drive_disk_image-release-1.0.1.img
```

Compare the output from the previous command with the contents of the usb_drive_disk_image-release-1.0.1.img.sha256sum file:

```bash
cat ~/Downloads/usb_drive_disk_image-release-1.0.1.img.sha256sum
```


##### Check the GPG Signature of the .sha256sum File 

GPG (Gnu Privacy Guard) is available on Windows, MacOS, and Linux. Once installed the commands to use it are the same on each platform. GPG uses public key encryption which, among other things, allows you to confirm that a file has been signed by a specific secret key. In our case the .sha256sum file should be digitally signed by the key belonging to code(at)shitfuckery.ca. The signature is stored in the file ending with .sig. Confirming this will ensure that the files were posted by us because it is cryptographically impossible to change the disk image and create a matching .sha256sum file without breaking our signature.

GPG is installed by default on Linux. For Windows and MacOS download GPG from the following links: 

Windows - [https://www.gpg4win.org/](https://www.gpg4win.org/)
MacOS - [https://gpgtools.org/](https://gpgtools.org/)

##### To Validate the Signature on Windows, MacOS, or Linux

Use the following commands from the terminal / command prompt to search for our public key and download it to your computer. You will need a working internet connection for this.

```bash
gpg --keyserver keyserver.ubuntu.com --search-keys code@shitfuckery.ca
```

Verify that the .sha256sum file was signed by our secret GPG key using the following command:

```bash
gpg --verify ~/Downloads/usb_drive_disk_image-release-1.0.1.img.sha256sum.sig ~/Downloads/usb_drive_disk_image-release-1.0.1.img.sha256sum
```

The output of the above command should include text along the lines of the following:

```
gpg: Signature made Thu 10 Jul 2025 12:44:39 PM PDT
gpg:                using EDDSA key BA4EF26A2E2AFB3F8D017C886CD4FFD1C1C1952A
gpg:                issuer "code@shitfuckery.ca"
gpg: Good signature from "Shitfuckery Code Signing <code@shitfuckery.ca>"
```

The command is likely to output an additional warning that our GPG key is not signed by a key you trust, this is expected and does not effect the confirmation that our GPG key was used to sign the sha256sum file. As an aside, if you are interested to learn more about how the "web of trust works" this is a good resource [https://en.wikipedia.org/wiki/Web_of_trust](https://en.wikipedia.org/wiki/Web_of_trust).

If the command did not output similar text saying that the signature is good there is a problem with the signature or sha256sum file and you should _NOT_ use the disk image. Please create an issue on github.com or contact us at code(at)shitfuckery.ca and include "Disk image validation problem" in the email subject and include the text that was output by the above command in the body of your email and attach your .sha256sum and .sig files.


#### Write the Disk Image to a USB Stick

After the disk image has been validated it is safe to use.

The disk image file can be thought of as a container. Although it is one file it contains many files and must be written to your USB stick in a way that makes those files accessible, because of this special software must be used. On MacOS and Linux the program dd is used. On Windows the program Rufus will accomplish the same.

##### Windows

Download the program [Rufus](https://rufus.ie/en/).
Good instructions for using Rufus are available [here](https://www.winhelponline.com/blog/windows-iso-to-usb-dvd-tool-bootable-media/#rufus). Note that ISO and IMG files are effectively the same thing so where the instructions reference an ISO or .iso file you can substitute the disk image file downloaded above that ends with .img.

##### MacOS and Linux

We will be using the built-in program `dd` from the terminal to write the disk image to the USB stick. The first step will be to determine the name your computer gives to the USB stick so that we can refer to it properly when using dd.

To determine the name of the USB stick on your computer we will run the following commands twice, first without the USB stick plugged into your computer and a second time with it plugged in, using the difference between the output to determine the name of the USB stick.  The command used varies slightly between MacOS and Linux.

Before plugging in the USB stick run the following command and note the drives listed:

###### MacOS
```bash
ls -l /dev/disk*
```

###### Linux
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

The USB stick in this case is named /dev/sda. On your computer this may be different.

With the drive name determined substitute it into the following command:

MacOS:
```bash
sudo dd if=~/Downloads/usb_drive_disk_image-release-1.0.1.img of=/dev/<name of your drive>
```
Linux:
```bash
sudo dd if=~/Downloads/usb_drive_disk_image-release-1.0.1.img of=/dev/<name of your drive> status=progress
```

By default the dd command does not return any progress indication while it is running.  On MacOS you can press `<control>-T` to show progress and on linux you can add `status=progress` to the command.

The dd command can be expected to take quite a while to run, with it being faster or slower depending on the speed of your USB stick. When it finishes the drive image will have been written to the USB stick.


#### Boot the Computer Using the USB Stick

Each computer has a special "hot key" that, when pressed during the boot process, will allow you to boot from a USB device. This key is often shown on the initial boot screen when the computer is powered on. On Framework and Dell computers pressing the `F12` key during the boot process will bring up the Boot Options menu and allow you to chose to boot from the USB Stick. On Macs holding down the `<option>` key while powering on the computer will bring up the Boot Options menu. On other computers the key may be different. Your computer's user manual will have this information and [this site](https://www.disk-image.com/faq-bootmenu.htm) has a good list of manufacturers and the hot key to press to bring up the Boot Menu. As you will see F12, ESC, F8, or F9 cover the most common ones.

With the USB stick connected to your computer power it on and press the hot key to bring up the boot options menu and select the USB stick to boot from it.

Very shortly into the boot process you will see output similar to this screenshot where the bootloader asks for a passphrase to decrypt the USB stick so that it can continue the boot process. 


<img width="100%" alt="Photo showing a computer screen and text asking the user to enter a passphrase to decrypt the drive" src="https://github.com/user-attachments/assets/495a1840-7d40-4070-b896-95b8e1805354" />


Enter the default disk encryption passphrase "setup" and press `Enter` to continue. Be aware that the screen will not show your keypresses as you type in the passphrase and there will be a notable delay while the decryption happens before the boot process continues. Please be patient.  If you have entered the passphrase correctly you will eventually end up at a screen that looks like the following screenshot. If that is not the case the passphrase was not entered correctly, reboot your computer to try again.


<img width="100%" alt="Photo showing the initial login window for Linux Mint. In this case the setup user is being prompted for their password." src="https://github.com/user-attachments/assets/605e2d84-c649-43eb-947e-d7b2eadb00e9" />


#### Log in as setup with the Password setup

Log in as the user setup with the password `setup`.

A few seconds after you log in as the setup user a script will open a window like the one below. Follow the instructions in the script to set up your encrypted USB stick. The script will:

  * Reencrypt the boot and root partitions so that they are using encryption keys unique to your USB stick
  * Add your encryption passphrase to the boot and root partitions and remove the stock passphrase
  * Create a new user account for your use
  * Disable the stock 'setup' user
  * Grow the filesystem so that it uses all of your USB stick
  * Install Tor Browser, Signal, Chromium, and Bitwarden
  * Make some minor customisations as an example
  * When you log in as your new user the script will remove the 'setup' user and clean up after itself 


<img width="100%" alt="Screenshot of the Linux Mint desktop shortly after the setup user has logged in for the first time." src="https://github.com/user-attachments/assets/b0ee77db-f765-4011-af37-b9645ed01247" />

As you can see in the screenshot above, a warning about being low on disk space is expected. The setup script will grow the filesystem on your USB stick, which will give you access to the full size of your USB stick and get rid of this warning message.

If you have access to an internet connection please set it up so that the script can install Tor, Signal, and Chromium. Click on the icon in the bottom right circled in red in the screenshot below to connect to wifi.



<img width="100%" alt="A screenshot showing the wifi icon." src="https://github.com/user-attachments/assets/dd75b299-6349-463a-b274-b5823779c23c" />



Congratulations, the hard part is done! Enjoy your new Linux Mint on an encrypted USB stick!

#### Next Steps:

##### Install Updates 

Like any newly set-up computer there will be updates to install. Updates can be installed by clicking on the shield icon in the lower right of the screen. Please take care of this as soon as possible. You can expect there to be quite a lot of updates initially.

<img width="100%" alt="Screenshot showing how to launch Update Manager" src="https://github.com/user-attachments/assets/817fc3ee-2855-4cc1-ae01-4516d73c69fc" />


<img width="100%" alt="Screenshot showing the Update Manager" src="https://github.com/user-attachments/assets/d0ef85a9-9c6a-4ffa-a801-61cabfd476ec" />


##### Install Additional Software

There is a very wide selection of software for Linux Mint. Install the software you want. Make it your own.

Launch the Software Manager under the "Start" menu.

<img width="100%" alt="Screenshot showing how to launch Software Manager" src="https://github.com/user-attachments/assets/cf06be54-feee-4ad8-9aa0-ee13d0ad4d5c" />

Then select the software you would like to install.

<img width="100%" alt="Screenshot showing the launched Software Manager" src="https://github.com/user-attachments/assets/0f9b2ea7-a459-47c3-be1d-003f8d0a9ffa" />


##### Explore

Poke around and get to know your system and set it up the way you want it.  A good place to start is in the System Settings.

<img width="100%" alt="Screenshot showing how to launch System Settings from under the 'Start' menu" src="https://github.com/user-attachments/assets/49c27a2f-449f-49ad-a9fe-1a2520729232" />

A good place to start in System Settings is in enabling the firewall.

<img width="2256" height="1504" alt="Screenshot from 2025-08-08 16-09-48" src="https://github.com/user-attachments/assets/05ea18ce-23e5-4f63-958f-81878f023daf" />

Set the system up the way you want it.  Enjoy!
