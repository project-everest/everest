# This script installs Everest build dependencies (including Cygwin)
# and GitHub CLI. It is meant to run on a Windows 11 machine. It is
# meant to be downloaded alone, without a full copy of everest.

param ($branch = "_taramana_windows")

$Global:cygwinRoot = "C:\cygwin64"

$Global:BashCmdError = $false

function global:Invoke-BashCmd
{
    # This function invokes a Bash command via Cygwin bash.
    $Error.Clear()
    $Global:BashCmdError = $false

    Write-Host "Args:" $args

    # Exec command
    $cygwinRoot = $Global:cygwinRoot
    $cygpathExe = "$cygwinRoot\bin\cygpath.exe"
    $cygpath = & $cygpathExe -u ${pwd}
    $bashExe = "$cygwinRoot\bin\bash.exe"
    & $bashExe --login -c "cd $cygpath && { $args ; }"

    if (-not $?) {
        Write-Host "*** Error:"
        $Error
	$Global:BashCmdError = $true
    }
}

$Error.Clear()
$LastExitCode = 0

$ProgressPreference = 'SilentlyContinue'

# powershell defaults to TLS 1.0, which many sites don't support.  Switch to 1.2.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Switch to this script's directory
Push-Location -ErrorAction Stop -LiteralPath $PSScriptRoot

Write-Host "Refresh PATH"
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
Write-Host "PATH = $env:Path"

$Error.Clear()
Write-Host "Install WinGet"
Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_WinGet.msixbundle
Add-AppxPackage Microsoft.DesktopAppInstaller_WinGet.msixbundle
if (-not $?) {
    $Error
    exit 1
}

$Error.Clear()
Write-Host "Looking for GitHub CLI"
gh --version
if (-not $?) {
  $Error.Clear()
  Write-Host "Install GitHub CLI"
  winget.exe install --id GitHub.cli
  if (-not $?) {
    $Error
    exit 1
  }
}

$Error.Clear()
Write-Host "Install Cygwin with git"
Invoke-WebRequest "https://www.cygwin.com/setup-x86_64.exe" -outfile "cygwinsetup.exe"
cmd.exe /c start /wait .\cygwinsetup.exe --root $Global:cygwinRoot -P git,wget --no-desktop --no-shortcuts --no-startmenu --wait --quiet-mode --site https://mirrors.kernel.org/sourceware/cygwin/
if (-not $?) {
    $Error
    exit 1
}
Remove-Item "cygwinsetup.exe"

$Error.Clear()
Write-Host "Clone everest"
$everestCmd = 'test -d $HOME/everest || git clone --branch ' + $branch + ' https://github.com/project-everest/everest.git $HOME/everest'
Invoke-BashCmd $everestCmd
if ($Global:BashCmdError) {
    exit 1
}

$everestCmd = '$HOME/everest/everest --yes check'
$nbRuns = 4
$nbSuccesses = 0
Do {
   $Error.Clear()
   Write-Host "Refresh PATH"
   $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
   Write-Host "PATH = $env:Path"
   Write-Host "Install and build Everest dependencies, $nbRuns run(s) remaining"
   Invoke-BashCmd $everestCmd
   if (-not $Global:BashCmdError) {
      $nbSuccesses++
   } else {
      $nbSuccesses = 0
      $nbRuns--
   }
} Until (($nbRuns -eq 0) -or ($nbSuccesses -eq 2))
Pop-Location
if ($Global:BashCmdError) {
    Write-Host "FAILURE"
    exit 1
}
$Error.Clear()
Write-Host "Everest dependencies are now installed."
