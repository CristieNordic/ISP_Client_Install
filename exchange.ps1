##################################################################################
##  Silent Installation Script for IBM Spectrum Protect for Microsoft Exchange  ##
##  Made by Cristie Nordic AB                                                   ##
##  Goes under MIT License Terms & Conditions                                   ##
##################################################################################

Param([parameter(Mandatory=$True)]$parameter)

Function Get-ExchangeExist {
    $Global:ExchServer = $null
    if (test-path "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\MSExchangeIS\ImagePath") {
        echo "Microsoft Exchange is installed on this server"
        $Global:ExchServer = $True
    }
    else {
        echo ""
        echo "####################################"
        echo ""
        echo "Microsoft Exchange Doesn't exist, will not install DP for Exchange"
        $Global:ExchServer = $False
    }
}

Function Install-Dp4Exch {

}

Function Config-Dp4Exch {

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