########################################## MICROSOFT SQL SERVER ##########################################

Function Get-MsSqlExist {
    $Global:MsSqlServer = $null
    if (test-path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\InstalledInstances") {
        echo "Microsoft SQL Server is installed on this server"
        $Global:MsSqlServer = $True
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

}

Function Config-Dp4Sql {

}