 <#
    .Synopsis
       Easy Deployment tool for IBM and Cristie Software.
    .DESCRIPTION
       This script will help you to easy deploy IBM Spectrum Protect Clients such
       * Backup-Archive Client
       * Data Protection for Microsoft Exchange
       * Data Protection for Microsoft SQL Server
       * Cristie TBMR

    .CONFIGURATION
       For configure the default values go though the settings.json file with a standard text editor such Notepad.
       Change each value that fits you such following lines where you can change isp.corp.com to your ISP Server Address.
        "IspServerSettings" : [
         {
            "tcpServerAddress" : "isp.corp.com",
            "tcpPort" : "1500",
            "sslEncryption" : "No",
            "sslPort" : "1543"
         },

       And for Nodename you can change section if you want to use Default hostname, do you want to add a suffix to your nodename,
       Do you want to generate a password or sett it on your own. And you can also add the suffix for Exchange nodes and SQL nodes.

       "NodeSettings" : [
        {
            "useOnlyHostname" : "No",
            "nodeExtension" : "-DOMAIN",
            "extensionBeforeAfter" : "After",
            "generatePassword" : "Yes",
            "staticPassword" : "Passw0rdCl3rT3xt"
        },
        {
            "exchExtension" : "_EXC",
            "sqlExtension" : "_SQL"
        }

    .EXAMPLE
       ispinstall.ps1 auto

       Will try automatic to find out if any client is installed and can be upgraded, or do a fresh install and
       automatic install and configure Backup-Archive Client, Data Protection for SQL Server, Data Protection for Exchange
       and Cristie TBMR.

    .EXAMPLE
       ispinstall.ps1 Only-File

       Will only install the IBM Spectrum Protect Backup-Archive Client for you.

    .EXAMPLE
       ispinstall.ps1 Only-Exchange

       Will only install the IBM Spectrum Protect Data Protection for Exchange
    .NOTES
       Written by Christian Petersson
       I take no responsibility for any issues caused by this script.
    .FUNCTIONALITY
       Automatic Install IBM Spectrum Protect Client, DP for SQL, DP for Exchange and Cristie TBMR.
    .LINK
       https://www.cristie.se

#>

Param([parameter()]$parameter)

$FullPathIncFileName = $MyInvocation.MyCommand.Definition
$CurrentScriptName = $MyInvocation.MyCommand.Name
$CurrentExecutingPath = $fullPathIncFileName.Replace($currentScriptName, "")

Function Get-InstallConfig {
    # This is only Standard Global Variables that the script is calling

    Write-Output ""
    Write-Output ""

    ####### IBM Spectrum Protect Server Settings #######
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
    $Global:BaRemote = "TSM Remote Client Agent"
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
}

Function Get-OSInformation {
    $Global:osversion = (Get-WmiObject -class Win32_OperatingSystem).Caption
    $Global:true64bit = (Get-WmiObject Win32_OperatingSystem).OSArchitecture
    $Global:LocalHostName = (Get-WmiObject Win32_OperatingSystem).CSName

    if (-not ($osversion)) {
        $Global:ExitErrorMsg = "Can't find the Operating System Version"
        $Global:ExitCode = "CRI0003E"
        Exit-Error
        }

    if (-not ($true64bit -eq "64-Bit")) {
        $Global:ExitErrorMsg = "This script is not supporting 32-Bits Operating Systems"
        $Global:ExitCode = "CRI0002E"
        Exit-Error
        }

    if (-not ($LocalHostName)) {
        $Global:ExitErrorMsg = "Can't find the hostname of this client"
        $Global:ExitCode = "CRI0001E"
        Exit-Error
        }

}

Function Set-IspSettings {
    $IspSettings = (Get-JsonConfig IspServerSettings)
    $Global:TcpServerAddressDefault = ($IspSettings.tcpServerAddress)
    $Global:TcpPortDefault = ($IspSettings.tcpPort)
}

Function Set-NodeSettings {
    $NodeSettings = (Get-JsonConfig NodeSettings)
    if ($NodeSettings.useOnlyHostName -eq "Yes") {
        $Global:NodeNameDefault = (Get-WmiObject Win32_OperatingSystem).CSName
    }
    else {
        $NodeExtension = ($NodeSettings.nodeExtension)
        if ($NodeSettings.extensionBeforeAfter -eq "After") {
            $HostName = (Get-WmiObject Win32_OperatingSystem).CSName
            $TempNodeName = (Write-Output $HostName | Foreach{ $_ + $NodeExtension })
            $Global:NodeNameDefault = $TempNodeName
        }
        else {
            $HostName = (Get-WmiObject Win32_OperatingSystem).CSName
            $TempNodeName = (Write-Output $NodeExtension | Foreach{ $_ + $HostName })
            $Global:NodeNameDefault = $TempNodeName[0]
        }
    }

    if ($NodeSettings.generatePassword -eq "Yes") {
        $alphabet=$NULL;For ($a=65;$a -le 90;$a++) {$alphabet+=,[char][byte]$a }
        $Global:NodePassword = (Get-NodePassword -length 24 -sourcedata $alphabet)
    }
    else {
        $Global:NodePassword = ($NodeSettings.staticPassword)
    }
}

########################################## GENERIC FUNCTIONS ##########################################
Function Show-Status  {
    Write-Output "Hostname: $LocalHostName"
    Write-Output "Operating System: $osversion"
    Write-Output "Bit Version: $true64bit"
    Write-Output " "
    Write-Output "ISP Address: $TcpServerAddressDefault"
    Write-Output "ISP Port: $TcpPortDefault"
    Write-Output "ISP Nodename: $NodeNameDefault"
    Write-Output "ISP Password: $NodePassword"
    Write-Output " "
    }

Function CleanUp-Install  {
    Remove-Variable LocalHostName -EA 0
    Remove-Variable osversion -EA 0
    Remove-Variable true64bit -EA 0
    Remove-Variable TcpServerAddress -EA 0
    Remove-Variable TcpPort -EA 0
    Remove-Variable NodeNameDefault -EA 0
    Remove-Variable NodePassword -EA 0
    }

Function Get-NodePassword() {
    Param(
        [int]$length=10,
        [string[]]$sourcedata
        )

    For ($loop=1; $loop -le $length; $loop++) {
        $TempPassword+=($sourcedata | GET-RANDOM)
        }

    return $TempPassword
}

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
    Set-Location $CurrentExecutingPath
    pause
    exit $ExitCode
}

Function Get-JsonConfig() {
    param([parameter()]$jsonvalue)

    $f = (Get-Content -Raw -Path settings.json | ConvertFrom-Json)
    $json = $f.$jsonvalue
    Return $json
    }

function Get-Help {
    $ScriptVersion = (Get-JsonConfig Version)
    Write-Output "*******************************************************************************"
    Write-Output "********************************** HELP MENU **********************************"
    Write-Output "*******************************************************************************"
    Write-Output "Version: $ScriptVersion "
    Write-Output "Usage: $CurrentScriptName Auto (Default)"
    Write-Output "       $CurrentScriptName Check"
    Write-Output "       $CurrentScriptName Only-File"
    Write-Output "       $CurrentScriptName Only-Exchange"
    Write-Output "       $CurrentScriptName Only-SQL"
    Write-Output "       $CurrentScriptName help (This help)"
    Write-Output " "
    Write-Output "For more help please use Get-Help $CurrentScriptName"
    Write-Output " "
    Write-Output "Thanks for using this script..."
    Write-Output "https://www.cristie.se"
    Write-Output " "

    Set-Location $CurrentExecutingPath
    pause
    exit $ExitCode
}



########################################## MAIN INSTALL ##########################################
if ($parameter -eq "help") { Get-Help }

Write-Output "*******************************************************************************"
Write-Output "*******************     Welcome To IBM Spectrum Protect     *******************"
Write-Output "*******************           Installation Script           *******************"
Write-Output "******************* OpenSource Project by Cristie Nordic AB *******************"
Write-Output "*******************************************************************************"
Get-InstallConfig
Get-OSInformation

if (!$parameter) {
    Set-IspSettings
    Set-NodeSettings
    & .\baclient.ps1 check
    Show-Status
    # & .\exchange.ps1 check
    # & .\mssql.ps1 check
 }

if ($parameter -eq "Check") {
    & .\baclient.ps1 check
    # & .\exchange.ps1 check
    # & .\mssql.ps1 check
    }

if ($parameter -eq "Only-File") {
    & .\baclient.ps1 check
    $InstallDpExchange = $False
    $InstallSql = $False
    }

if ($parameter -eq "Only-Exchange") {
    & .\exchange.ps1 check
    $InstallBaClient = $False
    $InstallSql = $False
    }

if ($parameter -eq "Only-SQL") {
    & .\mssql.ps1 check
    $InstallBaClient = $False
    $InstallDpExchange = $False
    }

if ($InstallBaClient -eq $True) {
    & .\baclient.ps1 Install
    }

if ($InstallDpExchange -eq $True) {
    & .\exchange.ps1 Install
    }

if ($InstallDpSql -eq $True) {
    & .\mssql.ps1 Install
    }

CleanUp-Install