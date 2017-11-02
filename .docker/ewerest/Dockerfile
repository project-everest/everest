FROM microsoft/windowsservercore:1709
WORKDIR "C:\ewerest"

WORKDIR "vs2017"
ADD ["https://aka.ms/vs/15/release/vs_community.exe", "vs2017.exe"]
# Windows SDK needed by Vale
# .NET Framework 4.5 (not 4.5.x) needed to rebuild F* with F#
# (everest FStar verify, make -C FStar/src)
RUN .\vs2017.exe --add Microsoft.VisualStudio.Component.FSharp --add Microsoft.Component.MSBuild --add Microsoft.VisualStudio.Component.NuGet --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.VC.CoreIde --add Microsoft.VisualStudio.Component.Windows10SDK.15063.Desktop --add Microsoft.Net.Component.4.5.TargetingPack --quiet --wait
WORKDIR ".."

WORKDIR "python"
ENV PYTHON_VER 2.7.13
ADD ["https://www.python.org/ftp/python/$PYTHON_VER/python-$PYTHON_VER.amd64.msi", "python.msi"]
RUN msiexec /i python.msi /quiet
# ENV does not support quoting PATH for Windows images,
# so take solution adapted from:
# https://stackoverflow.com/questions/42092932/appending-to-path-in-a-windows-docker-container
RUN ["powershell", "-Command", "[Environment]::SetEnvironmentVariable('Path', 'C:\\Python27;C:\\Python27\\Scripts;' + $env:Path, [EnvironmentVariableTarget]::Machine)"]
WORKDIR ".."

ENV EVEREST_BRANCH taramana_ewerest

# NOTE: we need to install cygwin before scons,
# because cygwin provides unzip

WORKDIR "cygwin"
ADD ["http://cygwin.org/setup-x86_64.exe", "setup-x86_64.exe"]
# JP: prefix any command requiring network with:
# powershell -Command "sleep 5" && 
# this sleep command allows the container network to be set up, if the network is configured in transparent mode.
# (NAT mode may not work on all physical networks)
# Also install all Cygwin packages needed by everest
# NOTE: cygwin setup cannot be run from inside powershell,
# so we write the command line into a .bat file that we will separately run
ADD ["https://raw.githubusercontent.com/project-everest/everest/$EVEREST_BRANCH/cygwin-packages", "everest-packages"]
RUN ["powershell", "-Command", "('.\\setup-x86_64.exe --site http://mirrors.metapeer.com/cygwin --no-desktop --no-shortcuts --quiet-mode --verbose --no-startmenu --wait --packages=' + ((cat everest-packages) -join ',') + ',rsync,patch,diffutils,curl,make,unzip,git,m4,perl,mingw64-x86_64-gcc-core,wget') | Out-File runsetup.bat -Encoding ASCII"]
RUN .\runsetup.bat
WORKDIR ".."

WORKDIR "scons"
ENV SCONS_VER 3.0.0
# ADD does not seem to support such redirections as SourceForge's
RUN C:\Cygwin64\bin\wget.exe http://prdownloads.sourceforge.net/scons/scons-%SCONS_VER%.zip
RUN C:\Cygwin64\bin\unzip.exe C:\ewerest\scons\scons-%SCONS_VER%.zip
WORKDIR "scons-"$SCONS_VER
RUN python setup.py install
WORKDIR "..\.."

# FIXME: remove the following temporary workaround.
# VS2017 no longer defines PLATFORM, but
# Vale Sconscript/Sconstruct are still relying on it
# to detect the platform
ENV PLATFORM X64

ADD ["https://raw.githubusercontent.com/project-everest/everest/$EVEREST_BRANCH/.docker/ewerest/install.sh", "install.sh"]
RUN C:\Cygwin64\bin\bash.exe --login C:\ewerest\install.sh
