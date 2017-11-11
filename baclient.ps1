##################################################################################
##  Silent Installation Script for IBM Spectrum Protect Backup-Archive Client   ##
##  Made by Cristie Nordic AB                                                   ##
##  Goes under MIT License Terms & Conditions                                   ##
##################################################################################

Param([parameter(Mandatory=$True)]$parameter)

Function Get-BaClientExist {
    Write-Output "Check if $ISP $BAC exist"
    Write-Output ""

    $ISPClientExistVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\IBM\ADSM\CurrentVersion\BackupClient" -Name PtfLevel).PtfLevel
    if (test-path "HKLM:\SOFTWARE\IBM\ADSM\CurrentVersion\BackupClient") {
        Write-Output " "
        Write-Output "You have already a $ISP Client Installed version: $ISPClientExistVersion"
        Write-Output "Please uninstall the $ISP Client before continue and"
        Write-Output "delete the key HKLM:\SOFTWARE\IBM\ADSM\CurrentVersion\BackupClient"
        $Global:InstallBaClient = $False
        $Global:UpgradeBaClient = $True
        $Global:ExitErrorMsg = "$ISP $BAC already exist, Upgrade is not supported yet"
        $Global:ExitCode = "CRI9999E"

        }

    else {
        Write-Output ""
        Write-Output ""
        Write-Output "$ISP $BAC will now be installed..."
        $Global:InstallBaClient = $True
        $Global:UpgradeBaClient = $False
        $Global:ExitCode = "0"
        }

    Write-Output ""
    Write-Output ""
}

Function Set-BaSetup {
    $Global:TcpServerAddress = Read-Host "Please enter ISP Server Address (Default: $TcpServerAddressDefault)"
    if (!$TcpServerAddress) {
        $Global:TcpServerAddress = $TcpServerAddressDefault
        }
    $Global:TcpPort = Read-Host "Please enter ISP Server Port (Default: $TcpPortDefault)"
    if (!$TcpPort) {
        $Global:TcpPort = $TcpPortDefault
        }
    $Global:NodeName = Read-Host "Please enter your hostname (Default: $NodeNameDefault)"
    if (!$NodeName) {
        $Global:NodeName = $NodeNameDefault
        }
    Get-NetIPAddress |fl IPAddress
    $Global:TcpClientAddress = Read-Host "Please enter your Local IP Address"
    #$Password = Read-Host -assecurestring "Please enter your password"
    Write-Output "*****************************************************************"
    Write-Output "***************** Please run following commands *****************"
    Write-Output "*****************       or run the WebUI        *****************"
    Write-Output "*****************************************************************"
    Write-Output " "
    Write-Output "To register the node in IBM Spectrum Protect Server"
    Write-Output "TSM> Register node $NodeName $NodePassword domain=<DOMAIN NAME>"
    pause
    Write-Output " "
    Write-Output "Please assign the node to a Scheduler before continue"
    Write-Output "TSM> define association <DOMAIN NAME> <SCHEDULE NAME> $NodeName "
    pause
}

Function Upgrade-Baclient {
       #You find Services here
       #HKLM:\SOFTWARE\IBM\ADSM\CurrentVersion\BackupClient\Scheduler Service\

        $DataStamp = Get-Date -Format yyyyMMDDTHHmmss
        $ISPShortName = "isp-ba-client"
        $logFile = '{0}-{1}.log' -f $ISPShortName,$DataStamp
        $MSIArguments = @(
            '/i'
            ('"{0}"' -f $BaInstallFile)
            'RebootYesNo="No"'
            'REBOOT="Suppress"'
            "/qn"
            "/l*v"
            $logFile
        )
        Set-Location .\TSMClient
        Start-Process -FilePath "msiexec.exe" -ArgumentList "$MSIArguments" -Wait
        Set-Location ..

}

Function Get-BaInstallPath {
    if (-not (test-path -path "$BaInstPath\$BaInstFile")) {
        Write-Output " "
        Write-Output "Future release will we automatic download the installation client for you..."

        $Global:BaInstFiles = $False
        #$Global:Download = $BaClientDownloadUrl
        $Global:ExitErrorMsg = "Can't find the installations files for $ISP $BAC in $BaInstPath"
        $Global:ExitCode = "CRI9999E"
        Exit-Error
    }

    else {
        Write-Output "Found the $ISP $BAC Installations files under directory $BaInstPath"
        if (-not (test-path -path "$DsmPath\$BaDsmFile")) {
            $Global:ExitCode = "CRI0004E"
            $Global:ExitErrorMsg = "Does not found default $BaDsmFile file under directory $DsmPath"
            Exit-Error
        }
    }
    Write-Output ""
    Write-Output ""
}

Function Install-BaClient {
    if ($BaClientExist -eq $False) {
        Write-Output "Installing Microsoft Windows 64-Bit C++ Runtime"
        Write-Output "Please Wait ..."
        Write-Output ""
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

        Write-Output "Installing $ISP $BAC"
        Write-Output "Please Wait ..."
        Write-Output ""
        $DataStamp = Get-Date -Format yyyyMMDDTHHmmss
        $ISPShortName = "isp-ba-client"
        $logFile = '{0}-{1}.log' -f $ISPShortName,$DataStamp
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
        Set-Location $BaInstPath
        Start-Process -FilePath "msiexec.exe" -ArgumentList "$MSIArguments" -Wait
        Set-Location ..
        }
}

Function Register-Node {
    Write-Output " "
    Write-Output " "
    # This will be fix in a letar version with direct access to the Rest Interface.
}

Function Config-BAClient {
    $BaClientInstallPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\IBM\ADSM\CurrentVersion" -Name TSMClientPath).TSMClientPath
    $baclientdir = "$BaClientInstallPath" + "baclient"
    $dsmopt = "$BaClientInstallPath" + "baclient\dsm.opt"
    $errorlogname = "$BaClientInstallPath" + "baclient\dsmerror.log"
    $schedlogname = "$BaClientInstallPath" + "baclient\dsmsched.log"

    Copy-Item $DsmPath\$BaDsmFile "$dsmopt"
    (Get-Content "$dsmopt").replace('NODENAME', "$NodeName") | Set-Content "$dsmopt"
    (Get-Content "$dsmopt").replace('TCPPORTNO', "$TcpPort") | Set-Content "$dsmopt"
    (Get-Content "$dsmopt").replace('SERVERADDRESS', "$TcpServerAddress") | Set-Content "$dsmopt"
    (Get-Content "$dsmopt").replace('LOCALIPADDRESS', "$TcpClientAddress") | Set-Content "$dsmopt"
    (Get-Content "$dsmopt").replace('PATHTOERRORLOG', "$errorlogname") | Set-Content "$dsmopt"
    (Get-Content "$dsmopt").replace('PATHTOSCHEDLOG', "$schedlogname") | Set-Content "$dsmopt"

    Set-Location $baclientdir

    $Argument1 = @(
        "install",
        "Scheduler",
        "/name:""$BaSched""",
        "/optfile:""$dsmopt""",
        "/node:$NodeName",
        "/password:$NodePassword",
        "/autostart:no"
        "/startnow:no"
    )

    $Argument2 = @(
        "install",
        "CAD",
        "/name:""$BaCad""",
        "/optfile:""$dsmopt""",
        "/node:$NodeName",
        "/password:$NodePassword",
        "/validate:yes",
        "/autostart:yes",
        "/startnow:no",
        "/CadSchedName:""$BaSched"""
        )
    $Argument3 = @(
        "install",
        "remoteagent"
        "/name:""$BaRemote""",
        "/optfile:""$dsmopt""",
        "/node:$NodeName",
        "/password:$NodePassword",
        "/validate:yes",
        "/startnow:no",
        "/partnername:""$BaCad"""
        )
    
    Write-Output "Creating $BaSched Service"
    Start-Process -FilePath "dsmcutil.exe" -ArgumentList "$Argument1" -Wait

    Write-Output "Creating $BaCad Service"
    Start-Process -FilePath "dsmcutil.exe" -ArgumentList "$Argument2" -Wait

    Write-Output "Creating $BaRemote Service"
    Start-Process -FilePath "dsmcutil.exe" -ArgumentList "$Argument3" -Wait
}

Function Test-BaClient {
    $BaClientInstallPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\IBM\ADSM\CurrentVersion" -Name TSMClientPath).TSMClientPath
    $baclientdir = "$BaClientInstallPath" + "baclient"
    Set-Location "$BaClientdir"

    $Argument = @(
            "set",
            "password",
            "$NodeName",
            "$NodePassword",
            "$NodePassword"
            )
    Start-Process -FilePath "dsmc.exe" -ArgumentList "$Argument" -Wait
}


########################################## GENERIC FUNCTIONS ##########################################
function Exit-Error {
    Write-Output " "
    Write-Output " "
    Write-Output "*******************************************************************************"
    Write-Output "************************************ ERROR ************************************"
    Write-Output "*******************************************************************************"
    Write-Output " "
    Write-Output "$ExitCode - $ExitErrorMsg"
    Write-Output " "
    Write-Output "*******************************************************************************"
    Write-Output "************************************ ERROR ************************************"
    Write-Output "*******************************************************************************"
    Set-Location $PSCommandPath
    pause
    exit $ExitCode
}

if ($parameter -eq "Check") {
    Get-BaClientExist
    Get-BaInstallPath
    }

if ($parameter -eq "Install") {
    Set-BaSetup
    Install-BaClient
    Register-Node
    Config-BaClient
    Test-BaClient
    }

if (!$parameter) {
    Write-Output "Invalid Command."
    Write-Output "Please run ""Get-Help .\ispinstall.ps1"" to get more information" }

