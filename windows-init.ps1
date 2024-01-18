# This script installs Everest build dependencies (including Cygwin)
# and GitHub CLI. It is meant to run on a Windows 11 machine.

$Global:cygwinRoot = "C:\cygwin64"

function global:Invoke-BashCmd
{
    # This function invokes a Bash command via Cygwin bash.
    $Error.Clear()

    Write-Host "Args:" $args

    # Exec command
    $cygwinRoot = $Global:cygwinRoot
    $cygpathExe = "$cygwinRoot\bin\cygpath.exe"
    $cygpath = & $cygpathExe -u ${pwd}
    $bashExe = "$cygwinRoot\bin\bash.exe"
    & $bashExe --login -c "cd $cygpath && $args"

    if (-not $?) {
        Write-Host "*** Error:"
        $Error
        exit 1
    }
}

$Error.Clear()
$LastExitCode = 0

$ProgressPreference = 'SilentlyContinue'

# powershell defaults to TLS 1.0, which many sites don't support.  Switch to 1.2.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Switch to this script's directory
Push-Location -ErrorAction Stop -LiteralPath $PSScriptRoot

$Error.Clear()
Write-Host "Install WinGet"
Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_WinGet.msixbundle
Add-AppxPackage Microsoft.DesktopAppInstaller_WinGet.msixbundle
if (-not $?) {
    $Error
    exit 1
}

$Error.Clear()
Write-Host "Install GitHub CLI"
winget.exe install --id GitHub.cli
if (-not $?) {
    $Error
    exit 1
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
Write-Host "Install and build Everest dependencies"
$everestCmd = "./everest --yes check"
Invoke-BashCmd $everestCmd
if (-not $?) {
    $Error
    exit 1
}

Pop-Location
Write-Host "Everest dependencies are now installed."
