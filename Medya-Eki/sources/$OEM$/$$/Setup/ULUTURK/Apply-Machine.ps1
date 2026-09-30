$ErrorActionPreference='Stop'
Set-StrictMode -Version 2
$expected=Join-Path $env:SystemRoot 'Setup\ULUTURK'
if ($PSScriptRoot -ine $expected) { throw 'ULUTURK: hedef kurulum klasoru gerekli.' }
$os=Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
if ((-not [Environment]::Is64BitOperatingSystem) -or $os.CurrentBuildNumber -ne '19045' -or $os.EditionID -ne 'Professional') { throw 'ULUTURK: beklenmeyen Windows.' }
if ([Security.Principal.WindowsIdentity]::GetCurrent().User.Value -ne 'S-1-5-18' -or (Get-ItemProperty 'HKLM:\SYSTEM\Setup').SystemSetupInProgress -ne 1) { throw 'Windows Setup SYSTEM baglami gerekli.' }
function Put($Key,$Name,$Value,$Kind='DWord') {
 if (-not(Test-Path -LiteralPath $Key)) { New-Item -Path $Key -Force|Out-Null }
 New-ItemProperty -LiteralPath $Key -Name $Name -Value $Value -PropertyType $Kind -Force|Out-Null
}
$loaded=$false
Start-Transcript -Path (Join-Path $PSScriptRoot 'Machine.log') -Append|Out-Null
try {
 # Preserve the native 22H2 AppX registrations.
 Put 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'NoAutoUpdate' 1
 Put 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowCortana' 0
 Put 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' 'AllowGameDVR' 0
 Put 'HKLM:\SYSTEM\CurrentControlSet\Services\DiagTrack' 'Start' 4
 # Pro supports the NoAutoUpdate policy. Preserve service startup defaults so
 # AppX, DISM, .NET/language installation and manual Windows Update remain available.
 $default=[Environment]::ExpandEnvironmentVariables((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList').Default)
 & "$env:SystemRoot\System32\reg.exe" load 'HKU\ULUTURK_Default' (Join-Path $default 'NTUSER.DAT')
 if($LASTEXITCODE -ne 0){throw 'Default kullanici kaydi acilamadi.'};$loaded=$true
 $root='Registry::HKEY_USERS\ULUTURK_Default'
 $run='"'+$env:SystemRoot+'\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File "'+$expected+'\Initialize-User.ps1"'
 Put ($root+'\Software\Microsoft\Windows\CurrentVersion\RunOnce') '!ULUTURKFirstLogon' $run 'String'
 Put ($root+'\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize') 'EnableTransparency' 0
 Put ($root+'\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced') 'TaskbarAnimations' 0
 Put ($root+'\Software\Microsoft\Windows\CurrentVersion\Search') 'SearchboxTaskbarMode' 1
 foreach($name in @('SilentInstalledAppsEnabled','SoftLandingEnabled','SystemPaneSuggestionsEnabled','PreInstalledAppsEnabled','OemPreInstalledAppsEnabled')){Put ($root+'\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager') $name 0}
 [GC]::Collect();[GC]::WaitForPendingFinalizers()
 & "$env:SystemRoot\System32\reg.exe" unload 'HKU\ULUTURK_Default'
 if($LASTEXITCODE -ne 0){throw 'Default kullanici kaydi kaydedilemedi.'};$loaded=$false
 Put 'HKLM:\SOFTWARE\ULUTURK' 'ProfileId' 'ULUTURK-22H2-x64-r1' 'String'
 Put 'HKLM:\SOFTWARE\ULUTURK' 'DisplayName' 'Windows 10 ULUTÜRK' 'String'

 # Signed VC runtime installers supplied with the user's dock package.
 $runtimeResults=@()
 foreach($arch in @('x64','x86')){
  $installer=Join-Path $env:ProgramData ('ULUTURK\Dock\Runtimes\VC_2015-2022.'+$arch+'.exe')
  $expectedHash=(Get-Content -LiteralPath ($installer+'.sha256') -Raw).Trim()
  if((Get-FileHash -LiteralPath $installer -Algorithm SHA256).Hash -ine $expectedHash){throw 'Dock runtime hash mismatch.'}
  $log=Join-Path $PSScriptRoot ('Dock-VC-'+$arch+'.log')
  $proc=Start-Process -FilePath $installer -ArgumentList ('/install /quiet /norestart /log "'+$log+'"') -WindowStyle Hidden -Wait -PassThru
  $runtimeResults+=@{Architecture=$arch;ExitCode=$proc.ExitCode;Accepted=($proc.ExitCode -in @(0,1638,3010))}
 }
 $runtimeResults|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $PSScriptRoot 'Dock-Runtimes.json') -Encoding UTF8
 if(@($runtimeResults|Where-Object{-not $_.Accepted}).Count -gt 0){Write-Warning 'Dock runtime installation needs review; Windows profile remains usable.'}

 Put 'HKLM:\SOFTWARE\ULUTURK' 'MachineComplete' 1
 Write-Output 'ULUTURK makine ayarlari tamamlandi.'
} catch {
 Write-Output ('ULUTURK HATA: '+($_|Out-String))
 throw
} finally {
 if($loaded){[GC]::Collect();[GC]::WaitForPendingFinalizers();& "$env:SystemRoot\System32\reg.exe" unload 'HKU\ULUTURK_Default'}
 Stop-Transcript|Out-Null
}
