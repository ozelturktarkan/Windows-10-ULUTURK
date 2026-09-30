param([ValidateSet('Start','Enable','Disable')][string]$Mode='Start')
$ErrorActionPreference='Stop'
$profile=Get-ItemProperty 'HKLM:\SOFTWARE\ULUTURK' -ErrorAction Stop
if($profile.ProfileId -ne 'ULUTURK-22H2-x64-r1' -or $profile.MachineComplete -ne 1){throw 'ULUTURK kurulumu gerekli.'}
$expected=Join-Path $env:SystemRoot 'Setup\ULUTURK'
if($PSScriptRoot -ine $expected){throw 'ULUTURK hedef klasoru gerekli.'}
$base=Join-Path $env:LOCALAPPDATA 'ULUTURK'
$dock=Join-Path $base 'MyDock'
$exe=Join-Path $dock 'Dock_64.exe'
$powershell=Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$runKey='HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$enabledKey='HKCU:\Software\ULUTURK'
New-Item -ItemType Directory -Path $base -Force|Out-Null
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class UluturkTaskbar {
 [StructLayout(LayoutKind.Sequential)] public struct Rect { public int l,t,r,b; }
 [StructLayout(LayoutKind.Sequential)] public struct Data { public uint size; public IntPtr hwnd; public uint callback,edge; public Rect rect; public IntPtr param; }
 [DllImport("shell32.dll")] static extern UIntPtr SHAppBarMessage(uint message,ref Data data);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] static extern IntPtr FindWindow(string cls,string title);
 public static bool AutoHide(bool enabled){
  Data d=new Data();d.size=(uint)Marshal.SizeOf(typeof(Data));d.hwnd=FindWindow("Shell_TrayWnd",null);
  if(d.hwnd==IntPtr.Zero)return false;
  uint state=(uint)SHAppBarMessage(4,ref d).ToUInt64();
  d.param=new IntPtr(enabled?(state|1):(state&~1u));SHAppBarMessage(10,ref d);
  return (((uint)SHAppBarMessage(4,ref d).ToUInt64()&1)!=0)==enabled;
 }
}
'@
function Set-Enabled([int]$value){
 if(-not(Test-Path -LiteralPath $enabledKey)){New-Item -Path $enabledKey -Force|Out-Null}
 New-ItemProperty -LiteralPath $enabledKey -Name DockEnabled -Value $value -PropertyType DWord -Force|Out-Null
}
function Own-DockProcesses {
 Get-Process -Name Dock_64,Dock,Dockmod,dockmod64,trayico,MyDock -ErrorAction SilentlyContinue | Where-Object {
  try{[IO.Path]::GetDirectoryName($_.Path) -ieq $dock}catch{$false}
 }
}
try {
 if($Mode -eq 'Disable'){
  Set-Enabled 0
  Remove-ItemProperty -LiteralPath $runKey -Name ULUTURKDock -ErrorAction SilentlyContinue
  $processes=@(Own-DockProcesses)
  foreach($p in $processes){[void]$p.CloseMainWindow()}
  Start-Sleep -Milliseconds 500
  foreach($p in $processes){if(-not $p.HasExited){Stop-Process -Id $p.Id -ErrorAction SilentlyContinue}}
  if(-not[UluturkTaskbar]::AutoHide($false)){throw 'Windows gorev cubugu geri getirilemedi.'}
  @{Time=(Get-Date).ToString('o');Mode=$Mode;TaskbarAutoHide=$false}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $base 'Dock-State.json') -Encoding UTF8
  exit 0
 }
 if($Mode -eq 'Enable'){
  if(-not(Test-Path -LiteralPath $exe)){
   $package=Join-Path $env:ProgramData 'ULUTURK\Dock\MyDock'
   if(-not(Test-Path -LiteralPath (Join-Path $package 'Dock_64.exe'))){throw 'Dock dosyalari eksik.'}
   New-Item -ItemType Directory -Path $dock -Force|Out-Null
   Copy-Item -Path (Join-Path $package '*') -Destination $dock -Recurse -Force
  }
  Set-Enabled 1
  if(-not(Test-Path -LiteralPath $runKey)){New-Item -Path $runKey -Force|Out-Null}
  $command='"'+$powershell+'" -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File "'+$PSCommandPath+'" -Mode Start'
  New-ItemProperty -LiteralPath $runKey -Name ULUTURKDock -Value $command -PropertyType String -Force|Out-Null
 }
 if((Get-ItemProperty -LiteralPath $enabledKey -ErrorAction SilentlyContinue).DockEnabled -ne 1){exit 0}
 if(-not(Test-Path -LiteralPath $exe)){throw 'Dock calistirilabilir dosyasi eksik.'}
 $existing=@(Own-DockProcesses|Where-Object{$_.ProcessName -eq 'Dock_64'})
 if($existing.Count -eq 0){
  # A normal per-user desktop process; no service, elevation or security exclusion.
  $process=Start-Process -FilePath $exe -WorkingDirectory $dock -WindowStyle Normal -PassThru
  try{[void]$process.WaitForInputIdle(10000)}catch{}
  Start-Sleep -Milliseconds 1000
  if($process.HasExited){throw ('Dock acilamadi. Cikis kodu: '+$process.ExitCode)}
 }
 if(-not[UluturkTaskbar]::AutoHide($true)){throw 'Gorev cubugu otomatik gizleme uygulanamadi.'}
 @{Time=(Get-Date).ToString('o');Mode=$Mode;TaskbarAutoHide=$true;Startup='HKCU Run';DockPath=$exe}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $base 'Dock-State.json') -Encoding UTF8
} catch {
 [void][UluturkTaskbar]::AutoHide($false)
 $_|Out-String|Set-Content -LiteralPath (Join-Path $base 'Dock-Error.txt') -Encoding UTF8
 throw
}
