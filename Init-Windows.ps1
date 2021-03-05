param($DistroName = "wslubuntu2004")
# Go to https://docs.microsoft.com/en-us/windows/wsl/install-manual for names of the distros
# (hover over the link and enter the name after https://aka.ms/)

Write-Host "Enabling Hyper-V (required for WSL2)"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

Write-Host "Enabling Virtul Machine platform (required for WSL2)"
Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform

Write-Host "Enabling WSL2"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

Write-Host "Downloading WSL2 Kernel Update"
$KernelUpdateMsi = "$env:Temp\wsl_update_x64.msi"
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi","$KernelUpdateMsi")

Write-Host "Installing WSL2 Kernel Update"
$DateStamp = get-date -Format yyyyMMddTHHmmss
$logFile = '{0}-{1}.log' -f $KernelUpdateMsi,$DateStamp
$MSIArguments = @(
    "/i"
    ('"{0}"' -f $KernelUpdateMsi)
    "/qn"
    "/norestart"
    "/L*v"
    $logFile
)
Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait #-NoNewWindow 

Write-Host "Setting WSL2 as the default version"
wsl --set-default-version 2

Write-Host "Downloading Linux Distro ($DistroName)"
$WebClient.DownloadFile("https://aka.ms/$DistroName","$env:Temp\Distro.appx")

Write-Host "Installing Linux Distro ($DistroName)"
Add-AppxPackage "$env:Temp\Distro.appx"

Write-Host "Enabling WinRM (if you don't need it, you can disable it after applying the playbooks)"
winrm quickconfig -transport:http -force

Write-Host "Finished! Now start the Linux Distro (this is unfortunately an interactive process...)"