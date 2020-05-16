#!/bin/bash
echo "Welcome to SuccessionCLI! Written by Samg_is_a_Ninja and demhademha"
checkRoot=`whoami`
if [ $checkRoot != "root" ]; then
    echo "SuccessionCLI needs to be run as root. Please su and try again."
    exit
fi
#We are going to create a resources folder in the User’s var directory 
mkdir -p /private/var/mobile/Media/Succession/
#Contact helper tool to get iOS version and device model
ProductVersion=`SuccessionCLIhelper --deviceVersion`
#we are now going to get the product buildversion for example, 17c54 and set it as a variable   
ProductBuildVersion=`SuccessionCLIhelper --deviceBuildNumber`
#we now get the machine ID, (for example iPhone9,4), and store it as a variable
DeviceIdentifier=`SuccessionCLIhelper --deviceModel`
#We’ll print these values that we have retrieved  
echo Your $DeviceIdentifier is running iOS version $ProductVersion build $ProductBuildVersion
echo "Please make sure this information is accurate before continuing. Press enter to confirm or exit if inaccurate."
read varblank
shouldExtractIPSW=true
shouldDownloadIPSW=true
if [ -f /private/var/mobile/Media/Succession/rfs.dmg ]; then
    while true; do
        read -p "Detected provided rootfilesystem disk image, would you like to use it? (y/n) " yn
        case $yn in
            [Yy]* ) shouldExtractIPSW=false; break;;
            [Nn]* ) shouldExtractIPSW=true; break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
fi
if ! $shouldExtractIPSW; then
    rm -rf /private/var/mobile/Media/Succession/ipsw*
    shouldDownloadIPSW=false
fi
if [ -f /private/var/mobile/Media/Succession/ipsw.ipsw ]; then
    while true; do
        read -p "Detected provided ipsw, would you like to use it? (y/n) " yn
        case $yn in
            [Yy]* ) shouldDownloadIPSW=false; break;;
            [Nn]* ) shouldDownloadIPSW=true; break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
fi

if $shouldDownloadIPSW; then
    echo succession will download the correct IPSW for your device: press enter to proceed
    read varblank2

    #print a warning message 

    echo once you press enter again, succession will begin the download 
    echo  DO NOT LEAVE TERMINAL 
    echo  DO NOT POWER OFF YOUR DEVICE 
    read varblank2   
    #we tell bash where to save the IPSW 
    echo preparing to download IPSW...
    echo downloading IPSW...
    # Clean up any files from previous runs
    rm -rf /private/var/mobile/Media/Succession/*
    #we download the ipsw from apple’s servers through ipsw.me’s api
    #TODO: add pzb to just download what we need instead of the entire IPSW
    curl  -# -L -o /private/var/mobile/Media/Succession/partial.ipsw http://api.ipsw.me/v2.1/$DeviceIdentifier/$ProductBuildVersion/url/dl
    #now that the download is complete, rename "partial.ipsw" to "ipsw.ipsw"
    mv /private/var/mobile/Media/Succession/partial.ipsw /private/var/mobile/Media/Succession/ipsw.ipsw
fi
if $shouldExtractIPSW; then
    #we create a new directory to put the ipsw that is going to be extracted   
    echo extracting IPSW...
    # Clean up partially extracted ipsws from previous runs
    rm -rf /private/var/mobile/Media/Succession/ipsw/*
    # If this is the first run, we need a destination folder to dump to
    mkdir /private/var/mobile/Media/Succession/ipsw/
    # 7z is a much faster and more advanced zip tool, and most devices will have it.
    pathToSevenZ=`which 7z`
    if [ -x $pathToSevenZ ]; then
        nameOfDMG=`7z l /private/var/mobile/Media/Succession/ipsw.ipsw | grep "dmg" | sort -k 4 -r | awk 'END {print $NF}'`
        7z x -o/private/var/mobile/Media/Succession/ipsw /private/var/mobile/Media/Succession/ipsw.ipsw $nameOfDMG
        7z x -o/private/var/mobile/Media/Succession/ipsw /private/var/mobile/Media/Succession/ipsw.ipsw BuildManifest.plist
    else 
        #we now navigate to the directory that we just created in order to save our extracted ipsw there after unzipping it   
        cd /private/var/mobile/Media/Succession/ipsw/
        unzip /private/var/mobile/Media/Succession/ipsw.ipsw
        cd ~
    fi
    # TODO: verify version and integrity of IPSW from BuildManfiest
    #we create a variable called dmg as we need to find and use the largest dmg later   
    echo moving extracted files... 
    # List all extracted files and move the largest one to /private/var/mobile/Media/Succession/rfs.dmg
    dmg=`ls -S /private/var/mobile/Media/Succession/ipsw/ | head -1`
    mv /private/var/mobile/Media/Succession/ipsw/$dmg /private/var/mobile/Media/Succession/rfs.dmg
    # Clean up
    rm -rf /private/var/mobile/Media/Succession/ipsw/
    rm /private/var/mobile/Media/Succession/ipsw.ipsw
fi
echo "Rootfilesystem dmg successfully extracted!"
#needs completing 
