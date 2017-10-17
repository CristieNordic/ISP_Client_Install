
Function Get-InstallConfig {
    $ISPInstallPath = "C:\Temp\TSM\BAClient"
    $ISPInstallFile = "setup.txt"
    $ISPDefaultDsmFile = "dsm.opt"
}


Function Get-DefaultVariables {
    echo ""
    echo ""
    $ISP = "IBM Spectrum Protect"
}

Function Get-OSVersion {
    echo "Check what version of Operating Systems you are running..."
    echo "Please Wait..."

    $osversion = (Get-WmiObject -class Win32_OperatingSystem).Caption
    $os64or32bit = (Get-WmiObject Win32_OperatingSystem).OSArchitecture
    $nodename = (Get-WmiObject Win32_OperatingSystem).CSName

    echo "You are running version: $osversion on $os64or32bit"
    echo ""
    echo ""
}

Function Get-ISPClientExist {
    echo "Check if IBM Spectrum Protect Backup-Archive Client exist"
    echo "Please Wait..."

    $ISPClientExistVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\IBM\ADSM\CurrentVersion\BackupClient" -Name PtfLevel).PtfLevel
    if (test-path "HKLM:\SOFTWARE\IBM\ADSM\CurrentVersion\BackupClient") {
        echo "You have already a $ISP Client Installed version: $ISPClientExistVersion"
        $ISPBAClientExist = $True
    }
    else {
        echo "$ISP Backup-Archive Client does not exist"
        $ISPBAClientExist = $False
    }
    echo ""
    echo ""
}

Function Get-ISPInstallPath {
    echo "Check if you the path to $ISP Client Installation Files exist"

    if (-not (test-path -path "$ISPInstallPath\$ISPInstallFile")) {
        echo "This file should exist"
    }
    else {
        echo "Found $ISP Backup-Archive Client Installer"
        echo "Found the installations files under directory $ISPInstallPath"
        if (test-path -path "$ISPInstallPath"
    }
    echo ""
    echo ""
}

Get-DefaultVariables
Get-OSVersion
Get-ISPClientExist
Get-ISPInstallPath



