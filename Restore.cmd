@echo off
@setlocal

set RoslynRoot=%~dp0
set NuGetExe="%RoslynRoot%\NuGet.exe"
set NuGetAdditionalCommandLineArgs=-verbosity quiet -configfile "%RoslynRoot%\nuget.config" -Project2ProjectTimeOut 1200

:ParseArguments
if /I "%1" == "/?" goto :Usage
if /I "%1" == "/clean" set RestoreClean=true&&shift&& goto :ParseArguments
goto :DoneParsing

call :Usage && exit /b 1
:DoneParsing


REM If someone passed in a different Roslyn solution, use that.
REM We make use of this when Roslyn is an sub-module for some 
REM internal repositories.
set RoslynSolution=%1
if "%RoslynSolution%" == "" set RoslynSolution=%RoslynRoot%\Roslyn.sln

if "%RestoreClean%" == "true" (
    echo Clearing the NuGet caches
    call %NugetExe% locals all -clear || goto :CleanFailed
)

echo Deleting project.lock.json files
pushd "%RoslynRoot%\src"
echo "Dummy lock file to avoid error when there is no project.lock.json file" > project.lock.json
del /s /q project.lock.json
popd

echo Restoring packages: Toolsets
call %NugetExe% restore "%RoslynRoot%\build\ToolsetPackages\project.json" %NuGetAdditionalCommandLineArgs% || goto :RestoreFailed

echo Restoring packages: Toolsets (Dev14 VS SDK build tools)
call %NugetExe% restore "%RoslynRoot%\build\ToolsetPackages\dev14.project.json" %NuGetAdditionalCommandLineArgs% || goto :RestoreFailed

echo Restoring packages: Toolsets (Dev15 VS SDK build tools)
call %NugetExe% restore "%RoslynRoot%\build\ToolsetPackages\dev15.project.json" %NuGetAdditionalCommandLineArgs% || goto :RestoreFailed

echo Restoring packages: Samples
call %NugetExe% restore "%RoslynRoot%\src\Samples\Samples.sln" %NuGetAdditionalCommandLineArgs% || goto :RestoreFailed

echo Restoring packages: Roslyn (this may take some time)
call %NugetExe% restore "%RoslynSolution%" %NuGetAdditionalCommandLineArgs% || goto :RestoreFailed

exit /b 0

:CleanFailed
echo Clean failed with ERRORLEVEL %ERRORLEVEL%
exit /b 1

:RestoreFailed
echo Restore failed with ERRORLEVEL %ERRORLEVEL%
exit /b 1

:Usage
@echo Usage: Restore.cmd /clean [Solution File]
exit /b 1
