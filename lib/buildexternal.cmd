@echo off

set U_STATIC_IMPLEMENTATION=1

set /p icu4c="Would you like to building icu.(y/N): " %=%
if "%icu4c%"=="y" (
devenv icu4c\source\allinone\allinone.sln /Clean 
devenv icu4c\source\allinone\allinone.sln /Build "Debug|x64" 
devenv  icu4c\source\allinone\allinone.sln /Build "Release|x64" 
)
set /p boost="Would you like to building boost.(y/N): " %=%
if "%boost%"=="y" ( 
set ICU_PATH=%~dp0%icu4c
echo USING ICU %ICU_PATH%
cd boost
bootstrap.bat
b2 --clean-all
b2.exe define=U_STATIC_IMPLEMENTATION=1  -sICU_PATH=%ICU_PATH% -j10 --toolset=msvc-10.0 architecture=x86 address-model=64 --build-type=complete stage
cd ..
)

rem boost.locale.iconv=off boost.locale.winapi=off boost.locale.std=off
exit /b 1;



REM setx BOOST_INC=..\boost\
setx LOG4CPLUS_INC %CWD%log4cplus\include > NUL
setx OPENSSL_INC %CWD%openssl\include > NUL
setx ZLIB_INC %CWD%zlib\include > NUL

SET INCLUDE=%ZLIB_INC%;%LOG4CPLUS_INC%;%OPENSSL_INC%;%INCLUDE%
echo "%INCLUDE%"
SET LIB=;;%LIB%
SET PATH=%PION_LIBS%\boost-1.37.0\lib;%PION_LIBS%\bzip2-1.0.5\bin;%PION_LIBS%\iconv-1.9.2\bin;%PION_LIBS%\libxml2-2.6.30\bin;%PION_LIBS%\log4cplus-1.0.3\bin;%PION_LIBS%\openssl-0.9.8l\bin;%PION_LIBS%\sqlapi-3.7.24\bin;%PION_LIBS%\yajl-1.0.5\bin;%PION_LIBS%\zlib-1.2.3\bin;%PION_LIBS%\WpdPack-4.0.2\Bin;%PATH%

REM http://stackoverflow.com/questions/158232/how-do-you-compile-openssl-for-x64
set /p openssl="Would you like to build openssl(y/N): " %=%
if "%openssl%"=="y" cd openssl &^
perl Configure VC-WIN64A &^
ms\do_win64a.bat &^
nmake -f ms\ntdll.mak &^
cd ..

set /p pion="Would you like to build pion(y/N): " %=%
if "%pion%"=="y" devenv pion\pion.sln /Build "pion\build\third_party_libs_x64.props|Win32"

REM [submodule "lib\\rpavlik-cmake-modules"]
REM 	path = lib\\rpavlik-cmake-modules
REM 	url = https://github.com/rpavlik/cmake-modules.git
REM [submodule "lib/pion"]
REM 	path = lib/pion
REM 	url = https://github.com/cloudmeter/pion
REM [submodule "lib/log4cplus"]
REM 	path = lib/log4cplus                            
REM 	url = https://github.com/cloudmeter/log4cplus.git
REM [submodule "lib/openssl"]
REM 	path = lib/openssl
REM 	url = https://github.com/cloudmeter/openssl.git
REM [submodule "lib/yajl"]
REM 	path = lib/yajl
REM 	url = https://github.com/lloyd/yajl.git
REM [submodule "lib/zlib"]
REM 	path = lib/zlib
REM 	url = https://github.com/madler/zlib.git
