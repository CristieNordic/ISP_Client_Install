##################################################################################
##  Silent Installation Script for IBM Spectrum Protect Client for Windows      ##
##  Made by Cristie Nordic AB                                                   ##
##  Goes under MIT License Terms & Conditions                                   ##
##################################################################################

Param([parameter()]$parameter)

$FullPathIncFileName = $MyInvocation.MyCommand.Definition
$CurrentScriptName = $MyInvocation.MyCommand.Name
$CurrentExecutingPath = $fullPathIncFileName.Replace($currentScriptName, "")

Function Get-InstallConfig {
    # This is only Standard Global Variables that the script is calling

    Write-Output ""
    Write-Output ""

    ####### IBM Spectrum Protect Server Settings #######
    $Global:TcpServerAddressDefault = "tsm.corp.com"
    $Global:TcpPortDefault = "1500"
    $Global:NodePassword = "PASSWORD"

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
    Write-Output "Check what version of Operating Systems you are running..."

    $Global:osversion = (Get-WmiObject -class Win32_OperatingSystem).Caption
    $Global:true64bit = (Get-WmiObject Win32_OperatingSystem).OSArchitecture
    $Global:NodeNameDefault = (Get-WmiObject Win32_OperatingSystem).CSName

    Write-Output "Your Server $NodeNameDefault are running version: $osversion on $true64bit"
    Write-Output ""
    Write-Output ""

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

    if (-not ($NodeNameDefault)) {
        $Global:ExitErroMsg = "Can't find the hostname of this client"
        $Global:ExitCode = "CRI0001E"
        Exit-Error
        }

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
    Set-Location $CurrentExecutingPath
    pause
    exit $ExitCode
}

function Get-JsonConfig {
    $json = (Get-Content -Raw -Path .\settings.json | ConvertFrom-Json)
}

function Get-Help {
    Get-JsonConfig
    $ScriptVersion = ($json.Version)
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
    & .\baclient.ps1 check
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
    #Write-Output "Will now run install of TSM"
    }

if ($InstallDpExchange -eq $True) {
    & .\exchange.ps1 Install
    }

if ($InstallDpSql -eq $True) {
    & .\mssql.ps1 Install
    }
