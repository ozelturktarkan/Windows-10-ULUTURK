$ErrorActionPreference='Stop'
Set-StrictMode -Version 2
if($PSScriptRoot -ine (Join-Path $env:SystemRoot 'Setup\ULUTURK')){throw 'ULUTURK hedef klasoru gerekli.'}
$profile=Get-ItemProperty 'HKLM:\SOFTWARE\ULUTURK'
if($profile.ProfileId -ne 'ULUTURK-22H2-x64-r1' -or $profile.MachineComplete -ne 1){throw 'ULUTURK kurulumu tamamlanmadi.'}
if(Test-Path 'HKCU:\Software\ULUTURK\Initialized'){exit 0}
function Put($Key,$Name,$Value,$Kind='DWord'){
 if(-not(Test-Path -LiteralPath $Key)){New-Item -Path $Key -Force|Out-Null}
 New-ItemProperty -LiteralPath $Key -Name $Name -Value $Value -PropertyType $Kind -Force|Out-Null
}
$out=Join-Path $env:LOCALAPPDATA 'ULUTURK';New-Item -ItemType Directory -Path $out -Force|Out-Null
Start-Transcript -Path (Join-Path $out 'FirstLogon.log') -Append|Out-Null
try {
 $base='HKCU:\Software\Microsoft\Windows\CurrentVersion'
 Put ($base+'\Explorer\Advanced') 'HideFileExt' 0
 Put ($base+'\Search') 'SearchboxTaskbarMode' 1
 Put ($base+'\Search') 'BingSearchEnabled' 0
 Put ($base+'\Search') 'CortanaConsent' 0
 Put ($base+'\AdvertisingInfo') 'Enabled' 0
 foreach($name in @('SilentInstalledAppsEnabled','SoftLandingEnabled','SystemPaneSuggestionsEnabled','PreInstalledAppsEnabled','OemPreInstalledAppsEnabled')){Put ($base+'\ContentDeliveryManager') $name 0}
 Put ($base+'\GameDVR') 'AppCaptureEnabled' 0
 Put 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled' 0
 $wallpaper=Join-Path $env:SystemRoot 'Web\Wallpaper\ULUTURK\ULUTURK.jpg'
 $cursor=Join-Path $env:SystemRoot 'Cursors\ULUTURK\turk.ani'
 foreach($file in @($wallpaper,$cursor)){if(-not(Test-Path -LiteralPath $file)){throw ('Eksik gorsel dosya: '+$file)}}
 Put 'HKCU:\Control Panel\Cursors' 'Arrow' $cursor 'String'
 Put 'HKCU:\Control Panel\Desktop' 'Wallpaper' $wallpaper 'String'
 Put 'HKCU:\Control Panel\Desktop' 'WallpaperStyle' '2' 'String'
 Put 'HKCU:\Control Panel\Desktop' 'TileWallpaper' '0' 'String'
 Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class UluturkDesktop {
 [DllImport("user32.dll",CharSet=CharSet.Unicode,SetLastError=true)]
 [return:MarshalAs(UnmanagedType.Bool)]
 public static extern bool SystemParametersInfo(uint action,uint param,string value,uint flags);
 [DllImport("user32.dll",EntryPoint="SystemParametersInfoW",SetLastError=true)]
 [return:MarshalAs(UnmanagedType.Bool)]
 static extern bool SpiPointer(uint action,uint param,IntPtr value,uint flags);
 public static bool ReloadCursors(){return SpiPointer(87,0,IntPtr.Zero,0);}
}
'@
 if(-not[UluturkDesktop]::SystemParametersInfo(20,0,$wallpaper,3)){throw 'Arkaplan uygulanamadi.'}
 if(-not[UluturkDesktop]::ReloadCursors()){throw 'Imlec uygulanamadi.'}
 & (Join-Path $PSScriptRoot 'Set-VisualEffects.ps1')

 # Per-user shortcuts provide an immediate way back to the Windows taskbar.
 $shell=New-Object -ComObject WScript.Shell
 $menu=Join-Path ([Environment]::GetFolderPath('Programs')) 'ULUTURK'
 New-Item -ItemType Directory -Path $menu -Force|Out-Null
 foreach($action in @(@('Dock ac','Enable'),@('Dock kapat - Windows cubugunu goster','Disable'))){
  $link=$shell.CreateShortcut((Join-Path $menu ($action[0]+'.lnk')))
  $link.TargetPath=Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
  $link.Arguments='-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "'+$PSScriptRoot+'\Dock-Control.ps1" -Mode '+$action[1]
  $link.WorkingDirectory=$PSScriptRoot;$link.WindowStyle=7;$link.Save()
 }
 Copy-Item -LiteralPath (Join-Path $menu 'Dock kapat - Windows cubugunu goster.lnk') -Destination ([Environment]::GetFolderPath('Desktop')) -Force
 try{& (Join-Path $PSScriptRoot 'Dock-Control.ps1') -Mode Enable}catch{Write-Warning ('Dock baslatma kontrolu gerekli: '+$_)}

 New-Item 'HKCU:\Software\ULUTURK\Initialized' -Force|Out-Null
 Write-Output 'ULUTURK ilk oturum tamamlandi. Sonraki oturumlarda tercihleriniz korunur.'
} catch {Write-Output ($_|Out-String);throw} finally {Stop-Transcript|Out-Null}
