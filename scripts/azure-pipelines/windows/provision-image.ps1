# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

<#
.SYNOPSIS
Sets up a machine to be an image for a scale set.

.DESCRIPTION
provision-image.ps1 runs on an existing, freshly provisioned virtual machine,
and sets that virtual machine up as a vcpkg build machine. After this is done,
(outside of this script), we take that machine and make it an image to be copied
for setting up new VMs in the scale set.

This script must either be run as admin, or one must pass AdminUserPassword;
if the script is run with AdminUserPassword, it runs itself again as an
administrator.

.PARAMETER AdminUserPassword
The administrator user's password; if this is $null, or not passed, then the
script assumes it's running on an administrator account.

.PARAMETER StorageAccountName
The name of the storage account. Stored in the environment variable %StorageAccountName%.
Used by the CI system to access the global storage.

.PARAMETER StorageAccountKey
The key of the storage account. Stored in the environment variable %StorageAccountKey%.
Used by the CI system to access the global storage.
#>
param(
  [string]$AdminUserPassword = $null,
  [string]$StorageAccountName = $null,
  [string]$StorageAccountKey = $null
)

$ErrorActionPreference = 'Stop'

<#
.SYNOPSIS
Gets a random file path in the temp directory.

.DESCRIPTION
Get-TempFilePath takes an extension, and returns a path with a random
filename component in the temporary directory with that extension.

.PARAMETER Extension
The extension to use for the path.
#>
Function Get-TempFilePath {
  Param(
    [String]$Extension
  )

  if ([String]::IsNullOrWhiteSpace($Extension)) {
    throw 'Missing Extension'
  }

  $tempPath = [System.IO.Path]::GetTempPath()
  $tempName = [System.IO.Path]::GetRandomFileName() + '.' + $Extension
  return Join-Path $tempPath $tempName
}

if (-not [string]::IsNullOrEmpty($AdminUserPassword)) {
  Write-Host "AdminUser password supplied; switching to AdminUser"
  $PsExecPath = Get-TempFilePath -Extension 'exe'
  Write-Host "Downloading psexec to $PsExecPath"
  & curl.exe -L -o $PsExecPath -s -S https://live.sysinternals.com/PsExec64.exe
  $PsExecArgs = @(
    '-u',
    'AdminUser',
    '-p',
    $AdminUserPassword,
    '-accepteula',
    '-h',
    'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe',
    '-ExecutionPolicy',
    'Unrestricted',
    '-File',
    $PSCommandPath
  )

  if (-Not ([string]::IsNullOrWhiteSpace($StorageAccountName))) {
    $PsExecArgs += '-StorageAccountName'
    $PsExecArgs += $StorageAccountName
  }

  if (-Not ([string]::IsNullOrWhiteSpace($StorageAccountKey))) {
    $PsExecArgs += '-StorageAccountKey'
    $PsExecArgs += $StorageAccountKey
  }

  Write-Host "Executing $PsExecPath " + @PsExecArgs

  $proc = Start-Process -FilePath $PsExecPath -ArgumentList $PsExecArgs -Wait -PassThru
  Write-Host 'Cleaning up...'
  Remove-Item $PsExecPath
  exit $proc.ExitCode
}

$VisualStudioBootstrapperUrl = 'https://aka.ms/vs/16/release/vs_enterprise.exe'
$Workloads = @(
  'Microsoft.VisualStudio.Workload.NativeDesktop',
  'Microsoft.VisualStudio.Workload.Universal',
  'Microsoft.VisualStudio.Component.VC.Tools.x86.x64',
  'Microsoft.VisualStudio.Component.VC.Tools.ARM',
  'Microsoft.VisualStudio.Component.VC.Tools.ARM64',
  'Microsoft.VisualStudio.Component.VC.ATL',
  'Microsoft.VisualStudio.Component.VC.ATLMFC',
  'Microsoft.VisualStudio.Component.VC.v141.x86.x64.Spectre',
  'Microsoft.VisualStudio.Component.Windows10SDK.18362',
  'Microsoft.Net.Component.4.8.SDK',
  'Microsoft.Component.NetFX.Native'
)

$MpiUrl = 'https://download.microsoft.com/download/A/E/0/AE002626-9D9D-448D-8197-1EA510E297CE/msmpisetup.exe'

$CudaUrl = 'https://developer.download.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda_10.1.243_426.00_win10.exe'
$CudaFeatures = 'nvcc_10.1 cuobjdump_10.1 nvprune_10.1 cupti_10.1 gpu_library_advisor_10.1 memcheck_10.1 ' + `
  'nvdisasm_10.1 nvprof_10.1 visual_profiler_10.1 visual_studio_integration_10.1 cublas_10.1 cublas_dev_10.1 ' + `
  'cudart_10.1 cufft_10.1 cufft_dev_10.1 curand_10.1 curand_dev_10.1 cusolver_10.1 cusolver_dev_10.1 cusparse_10.1 ' + `
  'cusparse_dev_10.1 nvgraph_10.1 nvgraph_dev_10.1 npp_10.1 npp_dev_10.1 nvrtc_10.1 nvrtc_dev_10.1 nvml_dev_10.1 ' + `
  'occupancy_calculator_10.1 fortran_examples_10.1'

$BinSkimUrl = 'https://www.nuget.org/api/v2/package/Microsoft.CodeAnalysis.BinSkim/1.6.0'

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

<#
.SYNOPSIS
Writes a message to the screen depending on ExitCode.

.DESCRIPTION
Since msiexec can return either 0 or 3010 successfully, in both cases
we write that installation succeeded, and which exit code it exited with.
If msiexec returns anything else, we write an error.

.PARAMETER ExitCode
The exit code that msiexec returned.
#>
Function PrintMsiExitCodeMessage {
  Param(
    $ExitCode
  )

  # 3010 is probably ERROR_SUCCESS_REBOOT_REQUIRED
  if ($ExitCode -eq 0 -or $ExitCode -eq 3010) {
    Write-Host "Installation successful! Exited with $ExitCode."
  }
  else {
    Write-Error "Installation failed! Exited with $ExitCode."
  }
}

<#
.SYNOPSIS
Install Visual Studio.

.DESCRIPTION
InstallVisualStudio takes the $Workloads array, and installs it with the
installer that's pointed at by $BootstrapperUrl.

.PARAMETER Workloads
The set of VS workloads to install.

.PARAMETER BootstrapperUrl
The URL of the Visual Studio installer, i.e. one of vs_*.exe.

.PARAMETER InstallPath
The path to install Visual Studio at.

.PARAMETER Nickname
The nickname to give the installation.
#>
Function InstallVisualStudio {
  Param(
    [String[]]$Workloads,
    [String]$BootstrapperUrl,
    [String]$InstallPath = $null,
    [String]$Nickname = $null
  )

  try {
    Write-Host 'Downloading Visual Studio...'
    [string]$bootstrapperExe = Get-TempFilePath -Extension 'exe'
    curl.exe -L -o $bootstrapperExe -s -S $BootstrapperUrl
    Write-Host "Installing Visual Studio..."
    $args = @('/c', $bootstrapperExe, '--quiet', '--norestart', '--wait', '--nocache')
    foreach ($workload in $Workloads) {
      $args += '--add'
      $args += $workload
    }

    if (-not ([String]::IsNullOrWhiteSpace($InstallPath))) {
      $args += '--installpath'
      $args += $InstallPath
    }

    if (-not ([String]::IsNullOrWhiteSpace($Nickname))) {
      $args += '--nickname'
      $args += $Nickname
    }

    $proc = Start-Process -FilePath cmd.exe -ArgumentList $args -Wait -PassThru
    PrintMsiExitCodeMessage $proc.ExitCode
  }
  catch {
    Write-Error "Failed to install Visual Studio! $($_.Exception.Message)"
  }
}

<#
.SYNOPSIS
Install a .msi file.

.DESCRIPTION
InstallMSI takes a url where an .msi lives, and installs that .msi to the system.

.PARAMETER Name
The name of the thing to install.

.PARAMETER Url
The URL at which the .msi lives.
#>
Function InstallMSI {
  Param(
    [String]$Name,
    [String]$Url
  )

  try {
    Write-Host "Downloading $Name..."
    [string]$msiPath = Get-TempFilePath -Extension 'msi'
    curl.exe -L -o $msiPath -s -S $Url
    Write-Host "Installing $Name..."
    $args = @('/i', $msiPath, '/norestart', '/quiet', '/qn')
    $proc = Start-Process -FilePath 'msiexec.exe' -ArgumentList $args -Wait -PassThru
    PrintMsiExitCodeMessage $proc.ExitCode
  }
  catch {
    Write-Error "Failed to install $Name! $($_.Exception.Message)"
  }
}

<#
.SYNOPSIS
Unpacks a zip file to $Dir.

.DESCRIPTION
InstallZip takes a URL of a zip file, and unpacks the zip file to the directory
$Dir.

.PARAMETER Name
The name of the tool being installed.

.PARAMETER Url
The URL of the zip file to unpack.

.PARAMETER Dir
The directory to unpack the zip file to.
#>
Function InstallZip {
  Param(
    [String]$Name,
    [String]$Url,
    [String]$Dir
  )

  try {
    Write-Host "Downloading $Name..."
    [string]$zipPath = Get-TempFilePath -Extension 'zip'
    curl.exe -L -o $zipPath -s -S $Url
    Write-Host "Installing $Name..."
    Expand-Archive -Path $zipPath -DestinationPath $Dir -Force
  }
  catch {
    Write-Error "Failed to install $Name! $($_.Exception.Message)"
  }
}

Function InstallWindowsVSIXWDK {
    Write-Host 'Installing Windows VSIX WDK...'
    $vsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Enterprise"
    $proc = Start-Process "$vsPath\Common7\IDE\VSIXInstaller.exe" "/a /q /f /sp `"${env:ProgramFiles(x86)}\Windows Kits\10\Vsix\VS2019\WDK.vsix`"" -PassThru
    $exitCode = $proc.ExitCode
    if ($exitCode -eq 0 -or $exitCode -eq 1001) {
      Write-Host 'Installation VSIX WDK successful!'
    }
    else {
      Write-Error "Installation failed! Exited with $exitCode."
    }
  }
  catch {
    Write-Error "Failed to install Windows VSIX WDK! $($_.Exception.Message)"
  }
}

Function InstallWindowsVSIXWDKv2 {
    Write-Host 'Installing Windows VSIX WDK...'
    $vsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Enterprise"
    $wdkPath = "${env:ProgramFiles(x86)}\Windows Kits\10"
    $proc = Expand-Archive -Path "$wdkPath\Vsix\VS2019\WDK.vsix" -DestinationPath "C:\temp" -Force -PassThru
    $proc = Copy-Item -Path 'C:\temp\$MSBuild' -Destination $vsPath\MSBuild -Force -Recurse -PassThru
    $exitCode = $proc.ExitCode
    if ($exitCode -eq 0) {
      Write-Host 'Installation successful!'
    }
    else {
      Write-Error "Installation failed! Exited with $exitCode."
    }
  }
  catch {
    Write-Error "Failed to install Windows WDK! $($_.Exception.Message)"
  }
}

<#
.SYNOPSIS
Installs MPI

.DESCRIPTION
Downloads the MPI installer located at $Url, and installs it with the
correct flags.

.PARAMETER Url
The URL of the installer.
#>
Function InstallMpi {
  Param(
    [String]$Url
  )

  try {
    Write-Host 'Downloading MPI...'
    [string]$installerPath = Get-TempFilePath -Extension 'exe'
    curl.exe -L -o $installerPath -s -S $Url
    Write-Host 'Installing MPI...'
    $proc = Start-Process -FilePath $installerPath -ArgumentList @('-force', '-unattend') -Wait -PassThru
    $exitCode = $proc.ExitCode
    if ($exitCode -eq 0) {
      Write-Host 'Installation successful!'
    }
    else {
      Write-Error "Installation failed! Exited with $exitCode."
    }
  }
  catch {
    Write-Error "Failed to install MPI! $($_.Exception.Message)"
  }
}

<#
.SYNOPSIS
Installs NVIDIA's CUDA Toolkit.

.DESCRIPTION
InstallCuda installs the CUDA Toolkit with the features specified as a
space separated list of strings in $Features.

.PARAMETER Url
The URL of the CUDA installer.

.PARAMETER Features
A space-separated list of features to install.
#>
Function InstallCuda {
  Param(
    [String]$Url,
    [String]$Features
  )
  try {
    Write-Host 'Downloading CUDA...'
    [string]$installerPath = Get-TempFilePath -Extension 'exe'
    curl.exe -L -o $installerPath -s -S $Url
    Write-Host 'Installing CUDA...'
    $proc = Start-Process -FilePath $installerPath -ArgumentList @('-s ' + $Features) -Wait -PassThru
    $exitCode = $proc.ExitCode
    if ($exitCode -eq 0) {
      Write-Host 'Installation successful!'
    }
    else {
      Write-Error "Installation failed! Exited with $exitCode."
    }
  }
  catch {
    Write-Error "Failed to install CUDA! $($_.Exception.Message)"
  }
}

<#
.SYNOPSIS
Partitions a new physical disk.

.DESCRIPTION
Takes the disk $DiskNumber, turns it on, then partitions it for use with label
$Label and drive letter $Letter.

.PARAMETER DiskNumber
The number of the disk to set up.

.PARAMETER Letter
The drive letter at which to mount the disk.

.PARAMETER Label
The label to give the disk.
#>
Function New-PhysicalDisk {
  Param(
    [int]$DiskNumber,
    [string]$Letter,
    [string]$Label
  )

  if ($Letter.Length -ne 1) {
    throw "Bad drive letter $Letter, expected only one letter. (Did you accidentially add a : ?)"
  }

  try {
    Write-Host "Attempting to online physical disk $DiskNumber"
    [string]$diskpartScriptPath = Get-TempFilePath -Extension 'txt'
    [string]$diskpartScriptContent =
    "SELECT DISK $DiskNumber`r`n" +
    "ONLINE DISK`r`n"

    Write-Host "Writing diskpart script to $diskpartScriptPath with content:"
    Write-Host $diskpartScriptContent
    Set-Content -Path $diskpartScriptPath -Value $diskpartScriptContent
    Write-Host 'Invoking DISKPART...'
    & diskpart.exe /s $diskpartScriptPath

    Write-Host "Provisioning physical disk $DiskNumber as drive $Letter"
    [string]$diskpartScriptContent =
    "SELECT DISK $DiskNumber`r`n" +
    "ATTRIBUTES DISK CLEAR READONLY`r`n" +
    "CREATE PARTITION PRIMARY`r`n" +
    "FORMAT FS=NTFS LABEL=`"$Label`" QUICK`r`n" +
    "ASSIGN LETTER=$Letter`r`n"
    Write-Host "Writing diskpart script to $diskpartScriptPath with content:"
    Write-Host $diskpartScriptContent
    Set-Content -Path $diskpartScriptPath -Value $diskpartScriptContent
    Write-Host 'Invoking DISKPART...'
    & diskpart.exe /s $diskpartScriptPath
  }
  catch {
    Write-Error "Failed to provision physical disk $DiskNumber as drive $Letter! $($_.Exception.Message)"
  }
}

Write-Host "AdminUser password not supplied; assuming already running as AdminUser"

New-PhysicalDisk -DiskNumber 2 -Letter 'E' -Label 'install disk'

Write-Host 'Disabling pagefile...'
wmic computersystem set AutomaticManagedPagefile=False
wmic pagefileset delete

Write-Host 'Configuring AntiVirus exclusions...'
Add-MPPreference -ExclusionPath C:\
Add-MPPreference -ExclusionPath D:\
Add-MPPreference -ExclusionPath E:\
Add-MPPreference -ExclusionProcess ninja.exe
Add-MPPreference -ExclusionProcess clang-cl.exe
Add-MPPreference -ExclusionProcess cl.exe
Add-MPPreference -ExclusionProcess link.exe
Add-MPPreference -ExclusionProcess python.exe

InstallVisualStudio -Workloads $Workloads -BootstrapperUrl $VisualStudioBootstrapperUrl -Nickname 'Stable'
#InstallWindowsVSIXWDK 
#InstallWindowsVSIXWDKv2 
InstallMpi -Url $MpiUrl
InstallCuda -Url $CudaUrl -Features $CudaFeatures
InstallZip -Url $BinSkimUrl -Name 'BinSkim' -Dir 'C:\BinSkim'
if (-Not ([string]::IsNullOrWhiteSpace($StorageAccountName))) {
  Write-Host 'Storing storage account name to environment'
  Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' `
    -Name StorageAccountName `
    -Value $StorageAccountName
}
if (-Not ([string]::IsNullOrWhiteSpace($StorageAccountKey))) {
  Write-Host 'Storing storage account key to environment'
  Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' `
    -Name StorageAccountKey `
    -Value $StorageAccountKey
}
