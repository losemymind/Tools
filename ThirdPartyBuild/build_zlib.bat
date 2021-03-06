@echo off
rem ***************************************************************************
rem *                                  _   _ ____  _
rem *  Project                     ___| | | |  _ \| |
rem *                             / __| | | | |_) | |
rem *                            | (__| |_| |  _ <| |___
rem *                             \___|\___/|_| \_\_____|
rem *
rem * Copyright (C) 2012 - 2016, Steve Holme, <steve_holme@hotmail.com>.
rem *
rem * This software is licensed as described in the file COPYING, which
rem * you should have received as part of this distribution. The terms
rem * are also available at https://curl.haxx.se/docs/copyright.html.
rem *
rem * You may opt to use, copy, modify, merge, publish, distribute and/or sell
rem * copies of the Software, and permit persons to whom the Software is
rem * furnished to do so, under the terms of the COPYING file.
rem *
rem * This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY
rem * KIND, either express or implied.
rem *
rem ***************************************************************************

:begin
  rem Check we are running on a Windows NT derived OS
  if not "%OS%" == "Windows_NT" goto nodos

  rem Set our variables
  setlocal
  set VC_VER=
  set BUILD_PLATFORM=
  set LIBRARY_TYPE=

  rem Ensure we have the required arguments
  if /i "%~1" == "" goto syntax

:parseArgs
  if "%~1" == "" goto prerequisites

  if /i "%~1" == "vc6" (
    set VC_VER=6.0
    set VC_DESC=VC6
    set "VC_PATH=Microsoft Visual Studio\VC98"
  ) else if /i "%~1" == "vc7" (
    set VC_VER=7.0
    set VC_DESC=VC7
    set "VC_PATH=Microsoft Visual Studio .NET\Vc7"
  ) else if /i "%~1" == "vc7.1" (
    set VC_VER=7.1
    set VC_DESC=VC7.1
    set VC_NAME="Visual Studio 7 .NET 2003"
    set "VC_PATH=Microsoft Visual Studio .NET 2003\Vc7"
  ) else if /i "%~1" == "vc8" (
    set VC_VER=8.0
    set VC_DESC=VC8
    set VC_NAME="Visual Studio 8 2005"
    set "VC_PATH=Microsoft Visual Studio 8\VC"
  ) else if /i "%~1" == "vc9" (
    set VC_VER=9.0
    set VC_DESC=VC9
    set VC_NAME="Visual Studio 9 2008"
    set "VC_PATH=Microsoft Visual Studio 9.0\VC"
  ) else if /i "%~1" == "vc10" (
    set VC_VER=10.0
    set VC_DESC=VC10
    set VC_NAME="Visual Studio 10 2010"
    set "VC_PATH=Microsoft Visual Studio 10.0\VC"
  ) else if /i "%~1" == "vc11" (
    set VC_VER=11.0
    set VC_DESC=VC11
    set VC_NAME="Visual Studio 11 2012"
    set "VC_PATH=Microsoft Visual Studio 11.0\VC"
  ) else if /i "%~1" == "vc12" (
    set VC_VER=12.0
    set VC_DESC=VC12
    set VC_NAME="Visual Studio 12 2013"
    set "VC_PATH=Microsoft Visual Studio 12.0\VC"
  ) else if /i "%~1" == "vc14" (
    set VC_VER=14.0
    set VC_DESC=VC14
    set VC_NAME="Visual Studio 14 2015"
    set "VC_PATH=Microsoft Visual Studio 14.0\VC"
  ) else if /i "%~1%" == "x86" (
    set BUILD_PLATFORM=x86
  ) else if /i "%~1%" == "x64" (
    set BUILD_PLATFORM=x64
  ) else if /i "%~1%" == "debug" (
    set BUILD_CONFIG=debug
  ) else if /i "%~1%" == "release" (
    set BUILD_CONFIG=release
  ) else if /i "%~1%" == "lib" (
    set LIBRARY_TYPE==lib
  ) else if /i "%~1%" == "dll" (
    set LIBRARY_TYPE==dll
  ) else if /i "%~1" == "clean" (
    goto clean
  ) else if /i "%~1" == "-?" (
    goto syntax
  ) else if /i "%~1" == "-h" (
    goto syntax
  ) else if /i "%~1" == "-help" (
    goto syntax
  ) else (
    if not defined START_DIR (
      set START_DIR=%~1%
    ) else (
      goto unknown
    )
  )

  shift & goto parseArgs

:prerequisites
  rem Compiler and platform are required parameters.
  if not defined VC_VER goto syntax
  if not defined BUILD_PLATFORM goto syntax
  if not defined VC_NAME goto syntax
 
  rem Default the start directory if one isn't specified
  if not defined START_DIR set START_DIR=..\..\openssl

  if not defined LIBRARY_TYPE set LIBRARY_TYPE=lib

  rem Calculate the program files directory
  if defined PROGRAMFILES (
    set "PF=%PROGRAMFILES%"
    set OS_PLATFORM=x86
  )
  if defined PROGRAMFILES(x86) (
    set "PF=%PROGRAMFILES(x86)%"
    set OS_PLATFORM=x64
  )

  rem Check we have a program files directory
  if not defined PF goto nopf

  rem Check we have Visual Studio installed
  if not exist "%PF%\%VC_PATH%" goto novc

  rem Check we have Perl in our path
  echo %PATH% | findstr /I /C:"\Perl" 1>nul
  if errorlevel 1 (
    rem It isn't so check we have it installed and set the path if it is
    if exist "%SystemDrive%\Perl" (
      set "PATH=%SystemDrive%\Perl\bin;%PATH%"
    ) else (
      if exist "%SystemDrive%\Perl64" (
        set "PATH=%SystemDrive%\Perl64\bin;%PATH%"
      ) else (
        goto noperl
      )
    )
  )

  rem Check the start directory exists
  if not exist "%START_DIR%" goto noopenssl

:configure
  if "%BUILD_PLATFORM%" == "" (
    if "%VC_VER%" == "6.0" (
      set BUILD_PLATFORM=x86
    ) else if "%VC_VER%" == "7.0" (
      set BUILD_PLATFORM=x86
    ) else if "%VC_VER%" == "7.1" (
      set BUILD_PLATFORM=x86
    ) else (
      set BUILD_PLATFORM=%OS_PLATFORM%
    )
  )

  if "%BUILD_PLATFORM%" == "x86" (
    set VCVARS_PLATFORM=x86
  ) else if "%BUILD_PLATFORM%" == "x64" (
    if "%VC_VER%" == "6.0" goto nox64
    if "%VC_VER%" == "7.0" goto nox64
    if "%VC_VER%" == "7.1" goto nox64
    if "%VC_VER%" == "8.0" set VCVARS_PLATFORM=x86_amd64
    if "%VC_VER%" == "9.0" set VCVARS_PLATFORM=%BUILD_PLATFORM%
    if "%VC_VER%" == "10.0" set VCVARS_PLATFORM=%BUILD_PLATFORM%
    if "%VC_VER%" == "11.0" set VCVARS_PLATFORM=amd64
    if "%VC_VER%" == "12.0" set VCVARS_PLATFORM=amd64
    if "%VC_VER%" == "14.0" set VCVARS_PLATFORM=amd64
  )

:start
  echo.
  if "%VC_VER%" == "6.0" (
    call "%PF%\%VC_PATH%\bin\vcvars32"
  ) else if "%VC_VER%" == "7.0" (
    call "%PF%\%VC_PATH%\bin\vcvars32"
  ) else if "%VC_VER%" == "7.1" (
    call "%PF%\%VC_PATH%\bin\vcvars32"
  ) else (
    call "%PF%\%VC_PATH%\vcvarsall" %VCVARS_PLATFORM%
  )

  echo.
  set SAVED_PATH=%CD%
  if defined START_DIR CD %START_DIR%
  mkdir build
  ::cd build
  goto %BUILD_PLATFORM%

:x64
  rem Calculate our output directory
  set OUTDIR=build\Win64\%VC_DESC%
  if not exist %OUTDIR% md %OUTDIR%

  if "%BUILD_CONFIG%" == "release" goto x64release

:x64debug
  rem Configuring 64-bit Debug Build
  cmake . -G %VC_NAME% Win64 -DCMAKE_INSTALL_PREFIX:PATH="%START_DIR%\build"
  cmake --build . --config Debug --target INSTALL

  if "%BUILD_CONFIG%" == "debug" goto success
  
:x64release
  rem Configuring 64-bit Release Build
  cmake . -G %VC_NAME% Win64 -DCMAKE_INSTALL_PREFIX:PATH="%START_DIR%\build"
  cmake --build . --config Release --target INSTALL
  goto success
  
:x86
  rem Calculate our output directory
  set OUTDIR=build\Win32\%VC_DESC%
  if not exist %OUTDIR% md %OUTDIR%

  if "%BUILD_CONFIG%" == "release" goto x86release
  
:x86debug
  rem Configuring 32-bit Debug Build
  cmake . -G %VC_NAME% -DCMAKE_INSTALL_PREFIX:PATH="%START_DIR%\build"
  cmake --build . --config Debug --target INSTALL

  if "%BUILD_CONFIG%" == "debug" goto success
  
:x86release
  rem Configuring 32-bit Release Build
  cmake . -G %VC_NAME% -DCMAKE_INSTALL_PREFIX:PATH="%START_DIR%\build"
  cmake --build . --config Release --target INSTALL
  
  goto success

:clean
  cmake clean

:syntax
  rem Display the help
  echo.
  echo Usage: build-openssl ^<compiler^> ^<platform^> [configuration] [LibraryType] [directory]
  echo.
  echo Compiler:
  echo.
  echo vc6       - Use Visual Studio 6
  echo vc7       - Use Visual Studio .NET
  echo vc7.1     - Use Visual Studio .NET 2003
  echo vc8       - Use Visual Studio 2005
  echo vc9       - Use Visual Studio 2008
  echo vc10      - Use Visual Studio 2010
  echo vc11      - Use Visual Studio 2012
  echo vc12      - Use Visual Studio 2013
  echo vc14      - Use Visual Studio 2015
  echo.
  echo Platform:
  echo.
  echo x86       - Perform a 32-bit build
  echo x64       - Perform a 64-bit build
  echo.
  echo Configuration:
  echo.
  echo debug     - Perform a debug build
  echo release   - Perform a release build
  echo.
  echo. LibraryType
  echo.
  echo lib       - build static library
  echo dll       - build dynamic library
  echo.
  echo Other:
  echo.
  echo directory - Specifies the OpenSSL source directory
  goto error

:unknown
  echo.
  echo Error: Unknown argument '%1'
  goto error

:nodos
  echo.
  echo Error: Only a Windows NT based Operating System is supported
  goto error

:nopf
  echo.
  echo Error: Cannot obtain the directory for Program Files
  goto error

:novc
  echo.
  echo Error: %VC_DESC% is not installed
  goto error

:noperl
  echo.
  echo Error: Perl is not installed
  goto error

:nox64
  echo.
  echo Error: %VC_DESC% does not support 64-bit builds
  goto error

:noopenssl
  echo.
  echo Error: Cannot locate OpenSSL source directory
  goto error

:error
  if "%OS%" == "Windows_NT" endlocal
  exit /B 1

:success
  cd %SAVED_PATH%
  endlocal
  exit /B 0




