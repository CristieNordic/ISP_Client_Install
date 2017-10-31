##################################################################################
##  Silent Installation Script for IBM Spectrum Protect Backup-Archive Client   ##
##  Made by Cristie Nordic AB                                                   ##
##################################################################################

Function Get-InstallConfig {
    # This is only Standard Global Variables that the script is calling

    echo ""
    echo ""

    ####### Installations Files #######
    $Global:BaInstPath = ".\TSMClient"
    $Global:BaInstallFile = "IBM Spectrum Protect Client.msi"

    #$Globel:ExchInstPath = ".\DPforExch"
    #$Globel:ExchInstFile = "DP for Exchange.msi"

    #$Globel:SqlInstPath = ".\DPforSql"
    #$Globel:SqlInstFile = "DP for SQL.msi"

    ####### DSM.OPT File Information #######
    $Global:DsmPath = ".\config"
    $Global:BaDsmFile = "ba_dsm.opt"
    #$Global:SqlDsmFile = "sql_dsm.opt"
    #$Global:ExchDsmFile = "exch_dsm.opt"

    ####### Windows Services Names  #######
    $Global:BaCad = "TSM Client Acceptor"
    $Global:BaSched = "TSM Client Scheduler"
    $Global:BaRemote = "TSM Client Remote Agent"
    #$Global:ExchCad = "TSM Exchange Acceptor"
    #$Global:ExchSched = "TSM Exchange Scheduler"
    #$Global:SqlCad = "TSM SQL Acceptor"
    #$Global:SqlSched = "TSM SQL Scheduler"

    ####### Downloads URLs  #######
    $Global:BaClientDownloadUrl = "ftp://ftp.software.ibm.com/storage/tivoli-storage-management/maintenance/client/v8r1/Windows/x64/v812/8.1.2.0-TIV-TSMBAC-WinX64.exe"
    $Global:Dp4ExchDownloadUrl = "ftp://ftp.cristie.se/dp4exch/latest"
    $Global:Dp4SqlDownloadUrl = "ftp://ftp.cristie.se/dp4sql/latest"

    ####### Product Names #######
    $Global:ISP = "IBM Spectrum Protect"
    $Global:BAC = "Backup-Archive Client"
    $Global:DP = "Data Protection for"
    $Global:EXCH = "Microsoft Exchange Server"
    $Global:SQL = "Microsoft SQL Server"

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
        $Global:ExitErrorMsg = "Can't find the Operating System Version"
        $Global:ExitCode = "CRI0003E"
        Exit-Error
    }

    if (-not ($true64bit -eq "64-Bit")) {
        $Global:ISPContinue = $False
        $Global:ExitErrorMsg = "This script is not supporting 32-Bits Operating Systems"
        $Global:ExitCode = "CRI0002E"
        Exit-Error
    }

    if (-not ($nodename)) {
        $Global:ExitErroMsg = "Can't find the hostname of this client"
        $Global:ExitCode = "CRI0001E"
        Exit-Error

    }

}

########################################## IBM SPECTRUM PROTECT BACKUP-ARCHIVE CLIENT ##########################################
Function Get-BaClientExist {
    echo "Check if $ISP $BAC exist"
    echo "Please Wait..."
    echo ""

    $ISPClientExistVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\IBM\ADSM\CurrentVersion\BackupClient" -Name PtfLevel).PtfLevel
    if (test-path "HKLM:\SOFTWARE\IBM\ADSM\CurrentVersion\BackupClient") {
        echo " "
        echo "You have already a $ISP Client Installed version: $ISPClientExistVersion"
        echo "Please uninstall the $ISP Client before continue"
        $Global:BaClientExist = $True
        $Global:ISPContinue = $False
        $Global:ExitErrorMsg = "$ISP $BAC already exist, Upgrade is not supported yet"
        $Global:ExitCode = "CRI9999E"
        Exit-Error
    }
    else {
        echo ""
        echo "Please wait..."
        echo ""
        echo "$ISP $BAC will be install..."
        $Global:BaClientExist = $False

    }
    echo ""
    echo ""
}

Function Get-BaInstallPath {
    echo "Check if you the path to $ISP $BAC Installation Files exist"

    if (-not (test-path -path "$BaInstPath\$BaInstFile")) {
        echo " "
        echo "Future release will we automatic download the installation client for you..."

        $Global:BaInstFiles = $False
        #$Global:Download = $BaClientDownloadUrl
        $Global:ExitErrorMsg = "Can't find the installations files for $ISP $BAC in $BaInstPath"
        $Global:ExitCode = "CRI9999E"
        Exit-Error
    }

    else {
        echo "Found $ISP $BAC Installer"
        echo "Found the installations files under directory $BaInstPath"
        $Global:ISPContinue = $True
        if (-not (test-path -path "$DsmPath\$BaDsmFile")) {

            echo "Does not found default $BaDsmFile file under directory $DsmPath"
            $Global:ISPContinue = $False
        }

    }
    echo ""
    echo ""
}

Function Install-BaClient {
    if ($BaClientExist -eq $False) {
        echo "Installing Microsoft Windows 64-Bit C++ Runtime"
        echo "Please Wait ..."
        echo ""
        $vcredistX86 = "vcredist_x86.exe"
        $vcredistX64 = "vcredist_x64.exe"

        # Future we need to create a for loop here instead to check if files even exist
        # $vcredistPath = @("{270b0954-35ca-4324-bbc6-ba5db9072dad}", "{BF2F04CD-3D1F-444e-8960-D08EBD285C3F}")
        $job1 = "$BaInstPath\ISSetupPrerequisites\{270b0954-35ca-4324-bbc6-ba5db9072dad}\$vcredistX86"
        $job2 = "$BaInstPath\ISSetupPrerequisites\{BF2F04CD-3D1F-444e-8960-D08EBD285C3F}\$vcredistX86"
        $job3 = "$BaInstPath\ISSetupPrerequisites\{7f66a156-bc3b-479d-9703-65db354235cc}\$vcredistX64"
        $job4 = "$BaInstPath\ISSetupPrerequisites\{3A3AF437-A9CD-472f-9BC9-8EEDD7505A02}\$vcredistX64"
        $Arguments = "/install /quiet /norestart /log vcredist.log"

        Start-Process $job1 -Argumentlist $Arguments -Wait
        Start-Process $job2 -Argumentlist $Arguments -Wait
        Start-Process $job3 -Argumentlist $Arguments -Wait
        Start-Process $job4 -Argumentlist $Arguments -Wait

        echo "Installing $ISP $BAC"
        echo "Please Wait ..."
        echo ""
        $DataStamp = Get-Date -Format yyyyMMDDTHHmmss
        $ISPShortName = "isp-ba-client"
        $logFile = '{0}-{1}.log' -f $ISPShortFile,$DataStamp
        $MSIArguments = @(
            '/i'
            ('"{0}"' -f $BaInstallFile)
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
        cd $BaInstPath
        Start-Process -FilePath "msiexec.exe" -ArgumentList "$MSIArguments" -Wait
        cd ..
    }
}

Function Register-Node {
    echo " "
    echo " "
    $msg = "Please view the information on your PowerShell screen"
    Invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList "msg * $msg"
    echo "*****************************************************************"
    echo "***************** Please run following commands *****************"
    echo "*****************       or run the WebUI        *****************"
    echo "*****************************************************************"
    echo " "
    echo "To register the node in IBM Spectrum Protect Server"
    echo "TSM> Register node $NodeName $NodePassword domain=<DOMAIN NAME>"
    pause
    echo " "
    echo "Please assign the node to a Scheduler before continue"
    echo "TSM> define association <DOMAIN NAME> <SCHEDULE NAME> $nodename "
    pause
}

Function Config-BAClient {
    $BaClientInstallPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\IBM\ADSM\CurrentVersion" -Name TSMClientPath).TSMClientPath
    Copy-Item $DsmPath\BaDsmFile "$BaClientInstallPath\baclient\dsm.opt"
    cd /d "$BaClientInstallPath\baclient"

    echo "Creating $BaSched Service"
    $Argument = @(
            "install"
            "Scheduler"
            '/name:"$BaSched"'
            '/optfile:"$BaClientInstallPath\baclient\dsm.opt"'
            "/node:$NodeName"
            "/password:$NodePassword"
            "/autostart:no"
            "/startnow:no"
    )

    Start-Process -FilePath "dsmcutil.exe" -ArgumentList "Argument" -Wait

    echo "Creating $BaCad Service"
    $Argument = @(
            "install"
            "CAD"
            '/name:"$BaCad"'
            '/optfile:"$BaClientInstallPath\baclient\dsm.opt"'
            "/node:$NodeName"
            "/password:$NodePassword"
            "/validate:yes"
            "/autostart:yes"
            "/startnow:no"
            '/CadSchadName:"$BaSched"'
    )

    echo "$Argument"
    Start-Process -FilePath "dsmcutil.exe" -ArgumentList "Argument" -Wait

    echo "Creating $BaRemote Service"
    $Argument = @(
            "install"
            "remoteagent"
            '/name:"$BaRemote"'
            '/optfile:"$BaClientInstallPath\baclient\dsm.opt"'
            "/node:$NodeName"
            "/password:$NodePassword"
            "/validate:yes"
            "/autostart:no"
            "/startnow:no"
            '/partnername:"$BaCad"'
    )

    echo "$Argument"
    Start-Process -FilePath "dsmcutil.exe" -ArgumentList "Argument" -Wait

    ### Go Back to Installation Path
    cd /d $PSCommandPath
}





########################################## GENERIC FUNCTIONS ##########################################
function Exit-Error {
    echo " "
    echo " "
    echo "*******************************************************************************"
    echo "************************************ ERROR ************************************"
    echo "*******************************************************************************"
    echo " "
    echo "$ExitCode - $ExitErrorMsg"
    echo " "
    echo "*******************************************************************************"
    echo "************************************ ERROR ************************************"
    echo "*******************************************************************************"
    pause
    exit $ExitCode
}

Function Download-Client {
        echo "Now will we only Download the 8.1.2.0 version to your clients"
        echo "Please fix this for the next Release"
        wget $Download
}

########################################## MAIN INSTALL ##########################################

# Get all information before the installation start
echo "Collecting information before installing"
Get-InstallConfig
Get-OSVersion
Get-BaClientExist
Get-BaInstallPath

if ($ISPContinue -eq "$True") { Install-BaClient }
if ($ISPContinue -eq "$True") { Register-Node }
if ($ISPContinue -eq "$True") { Config-BaClient }

### Future Stuff ###
#Get-ExchangeExist
# if ($BaInstFiles -eq "$False") {Download-Client } # Future Function will now execute

#if ($ExchExist -eq "True") { Get-Dp4ExchInst } #Future Function will return True
#if ($ExchInstExist -eq "False")
#if ($ExchExist -eq "True") { Install-Dp4Exchange }
#if ($ExchExist -eq "True") { Config-Dp4Exchange }


# Get-ExchangeExist





