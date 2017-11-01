########################################## MICROSOFT EXCHANGE ##########################################

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