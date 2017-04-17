Import-Module WebAdministration
Write-Host Stopping IIS
iisreset /stop
Write-Host Starting IIS
iisreset /start
Write-Host Recycle iMIS Application Pools
Restart-WebAppPool "DefaultAppPool"
Restart-WebAppPool "AsiSchedulerPool"
Restart-WebAppPool "iMISApp"
Write-Host Complete Recycling IIS
$IE=new-object -com internetexplorer.application
$IE.navigate2("http://localhost/Asi.Scheduler_iMIS")
$IE.visible=$true
pause
