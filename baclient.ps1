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