##################################################################################
##  Silent Installation Script for IBM Spectrum Protect for Microsoft SQL       ##
##  Made by Cristie Nordic AB                                                   ##
##  Goes under MIT License Terms & Conditions                                   ##
##################################################################################

Param([parameter(Mandatory=$True)]$parameter)

Function Get-MsSqlExist {
    $Global:MsSqlServer = $null
    if (test-path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server") {
        echo "Microsoft SQL Server is installed on this server"
        $Global:MsSqlServer = $True
        # "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\InstalledInstances"
    }
    else {
        echo ""
        echo "####################################"
        echo ""
        echo "Microsoft SQL Server Doesn't exist, will not install DP for Microsoft SQL"
        $Global:MsSqlServer = $False
    }
}

Function Install-Dp4Sql {
### INSTALL MMC ###
$Arg = @(
	'/s'
	'/v"INSTALLDIR=\"C:\Program Files\Tivoli\"'
	'ADDLOCAL=\"Client\"'
	'TRANSFORM=1033.mst'
	'REBOOT=ReallySuppress'
	'/qn'
	'/l*v'
	'\".\DpSqlMmcSpinstallLog.txt\"'
	)
Start-Process -FilePath ".\fcm\x64\mmc\8120\enu\spinstall.exe" -ArgumentList "$Arg" -Wait

### INSTALL SQL Agent ####
Arg = @(
	'/s'
	'/v"INSTALLDIR=\"C:\Program Files\Tivoli\tsm\"'
	'ADDLOCAL=\"Client\"'
	'TRANSFORM=1033.mst'
	'REBOOT=ReallySuppress'
	'/qn'
	'/l*v'
	'\".\DpSqlSpinstallLog.txt\"'
	)
Start-Process -FilePath ".\fcm\x64\sql\8120\enu\spinstall.exe" -ArgumentList "$Arg" -Wait

}

Function Config-Dp4Sql {

#### Verify that VSS is installed in BA Client dsm.opt file ####
#### Adding "SNAPSHOTPROVIDERFS VSS" to dsm.opt ####


### dsm.opt for DP ###
NODename NODENAME_SQL
PASSWORDAccess generate
TCPServeraddress tsm.corp.com
TCPPort PORT
HTTPport HTTPPROT

### tdpsql.cfg ###
LOCALDSMAgentnode NODENAME
BACKUPMETHod vss
LASTPRUNEDate     MM/DD/YYYY HH:MM:SS

### Grant Proxy ###
Grant Proxy target=NODENAME_SQL AGENT=NODENAME



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