##################################################################################
##  Silent Installation Script for IBM Spectrum Protect Backup-Archive Client   ##
##  Made by Cristie Nordic AB                                                   ##
##################################################################################

Function Get-InstallConfig {
    # This is only Standard Global Variables that the script is calling

    echo ""
    echo ""

    $ISPScriptVersion = "1.0"

    $Global:ISPInstallPath = ".\TSMClient"
    $Global:ISPInstallFile = "IBM Spectrum Protect Client.msi"
    $Global:DsmFile = "dsm.opt"
    $Global:DsmInstallPath = "Program Files 64\Tivoli\TSM\config"
    $Global:ISP = "IBM Spectrum Protect"
    $Global:BAC = "Backup-Archive Client"

    $Global:ISPContinue = $True
    echo "Welcome to Cristie Silent Installation Script $ISPScriptVersion for $ISP $BAC"
}

Function Get-OSVersion {
    echo "Check what version of Operating Systems you are running..."
    echo "Please Wait..."

    $Global:osversion = (Get-WmiObject -class Win32_OperatingSystem).Caption
    $Global:true64bit = (Get-WmiObject Win32_OperatingSystem).OSArchitecture
    $Global:nodename = (Get-WmiObject Win32_OperatingSystem).CSName

    echo "You are running version: $osversion on $true64bit"
    echo ""
    echo ""

    if (-not ($osversion)) {
        $Global:ISPContinue = $False
        echo "Can't Find Operating System Version"
    }

    if (-not ($true64bit -eq "64-Bit")) {
        $Global:ISPContinue = $False
        echo "This is not a 64-bits Operating System"
    }

    if (-not ($nodename)) {
        $Global:ISPContinue = $False
        echo "Can't find the correct hostname"
    }

}

Function Get-ISPClientExist {
    echo "Check if $ISP $BAC exist"
    echo "Please Wait..."
    echo ""

    $ISPClientExistVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\IBM\ADSM\CurrentVersion\BackupClient" -Name PtfLevel).PtfLevel
    if (test-path "HKLM:\SOFTWARE\IBM\ADSM\CurrentVersion\BackupClient") {
        echo "You have already a $ISP Client Installed version: $ISPClientExistVersion"
        echo "Please uninstall the $ISP Client before continue"
        $Global:ISPBAClientExist = $True
        $Global:ISPContinue = $False
    }
    else {
        echo ""
        echo "####################################"
        echo ""
        echo "$ISP $BAC does not exist"
        $Global:ISPBAClientExist = $False
    }
    echo ""
    echo ""
}

Function Get-ISPInstallPath {
    echo "Check if you the path to $ISP $BAC Installation Files exist"

    if (-not (test-path -path "$ISPInstallPath\$ISPInstallFile")) {
        echo "Can't find the installations files for $ISP $BAC in $ISPInstallPath"
        $Global:ISPContinue = $False
    }
    else {
        echo "Found $ISP $BAC Installer"
        echo "Found the installations files under directory $ISPInstallPath"
        $Global:ISPContinue = $True
        if (-not (test-path -path "$ISPInstallPath\$DsmInstallPath\$DsmFile")) {

            echo "Does not found default $DsmFile file under directory $ISPInstallPath\$DsmInstallPath"
            $Global:ISPContinue = $False
        }

    }
    echo ""
    echo ""
}

Function Install-ISPClient {
    echo "ISPBAClientExist it set to $ISPBAClientExist"
    if ($ISPBAClientExist -eq $False) {
        echo "Installing Microsoft Windows 64-Bit C++ Runtime"
        echo "Please Wait ..."
        echo ""
        $vcredistX86 = "vcredist_x86.exe"
        $vcredistX64 = "vcredist_x64.exe"

        # Future we need to create a for loop here instead to check if files even exist
        # $vcredistPath = @("{270b0954-35ca-4324-bbc6-ba5db9072dad}", "{BF2F04CD-3D1F-444e-8960-D08EBD285C3F}")
        $job1 = "$ISPInstallPath\ISSetupPrerequisites\{270b0954-35ca-4324-bbc6-ba5db9072dad}\$vcredistX86"
        $job2 = "$ISPInstallPath\ISSetupPrerequisites\{BF2F04CD-3D1F-444e-8960-D08EBD285C3F}\$vcredistX86"
        $job3 = "$ISPInstallPath\ISSetupPrerequisites\{7f66a156-bc3b-479d-9703-65db354235cc}\$vcredistX64"
        $job4 = "$ISPInstallPath\ISSetupPrerequisites\{3A3AF437-A9CD-472f-9BC9-8EEDD7505A02}\$vcredistX64"
        $Arguments = "/install /quiet /norestart /log vcredist.log"

        Start-Process $job1 -Argumentlist $Arguments -Wait
        Start-Process $job2 -Argumentlist $Arguments -Wait
        Start-Process $job3 -Argumentlist $Arguments -Wait
        Start-Process $job4 -Argumentlist $Arguments -Wait

        echo "Installing $ISP $BAC"
        echo "Please Wait ..."
        echo ""
        $DataStamp = Get-Date -Format yyyyMMDDTHHmmss
        @ISPShortName = "isp-ba-client
        $logFile = '{0}-{1}.log' -f $ISPShortFile,$DataStamp               
        $MSIArguments = @(
            "/i"
            ('"{0}"' -f $ISPInstallFile)
            'RebootYesNo="No"'
            'REBOOT="Suppress"'
            "ALLUSERS=1"
            'ADDLOCAL="BackupArchiveGUI,BackupArchiveWeb,Api64Runtime"'
            "TRANSFORMS=1033.mst"
            "/qn"
            "/l*v"
            $logFile
        )
        echo "$MSIArguments"
        cd $ISPInstallPath
        Start-Process -FilePath "msiexec.exe" -ArgumentList "$MSIArguments" -Wait
    }
}

Function Get-ExchangeExist {
    $ExchServer = $null
    # Locate configuration naming context for the forest
    $ConfigNC = Get-ADRootDSE | Select-Object -ExpandProperty configurationNamingContext
    # Search for registered Exchange servers
    $ExchServer  = Get-ADObject -Filter {objectClass -eq "msExchExchangeServer" -and objectClass -ne "msExchClientAccessArray"} -SearchBase $ConfigNC | Select Name
    if ([ExchServer]::IsNullorEmpty()) {
        $ExchangeExist = $False
        echo "Microsoft Exchange is not installed on this server"
    }
    else {
        echo "$Servers"
    }

}

# Get all information before the installation start
Get-InstallConfig
echo "$ISPContinue"
if ($ISPContinue -eq "$True") { Get-OSVersion }
echo "$ISPContinue"
if ($ISPContinue -eq "$True") { Get-ISPClientExist }
echo "$ISPContinue"
if ($ISPContinue -eq "$True") { Get-ISPInstallPath }

# Start Installing
echo "$ISPContinue"
if ($ISPContinue -eq "$True") { Install-ISPClient }


# Get-ExchangeExist