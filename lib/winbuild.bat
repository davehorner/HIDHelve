@ECHO OFF
SET PION_LIBS=C:
SETLOCAL EnableDelayedExpansion
SET PION_HOME=C:
SET INCLUDE=%PION_LIBS%\Boost;%PION_LIBS%\bzip2-1.0.6\include;%PION_LIBS%\dssl-1.6.8\src;%PION_LIBS%\iconv-1.9.2\include;%PION_LIBS%\libxml2-2.9.0\include;%PION_LIBS%\log4cplus-1.0.4.1\include;%PION_LIBS%\openssl-1.0.1c\inc32;%PION_LIBS%\sqlite-3.7.14.1;%PION_LIBS%\yajl-2.0.5\include;%PION_LIBS%\zlib-1.2.7\include;%PION_LIBS%\WpdPack-4.0.2\Include;%INCLUDE%
SET LIB=%PION_LIBS%\Boost\lib;%PION_LIBS%\bzip2-1.0.6\lib;%PION_LIBS%\dssl-1.6.8\release;%PION_LIBS%\iconv-1.9.2\lib;%PION_LIBS%\libxml2-2.9.0\lib;%PION_LIBS%\log4cplus-1.0.4.1\bin;%PION_LIBS%\openssl-1.0.1c\bin;%PION_LIBS%\sqlite-3.7.14.1\lib;%PION_LIBS%\yajl-2.0.5\bin;%PION_LIBS%\zlib-1.2.7\lib;%PION_LIBS%\WpdPack-4.0.2\Lib;%LIB%
SET PATH=%PION_LIBS%\Boost\lib;%PION_LIBS%\bzip2-1.0.6\bin;%PION_LIBS%\iconv-1.9.2\bin;%PION_LIBS%\libxml2-2.9.0\bin;%PION_LIBS%\log4cplus-1.0.4.1\bin;%PION_LIBS%\openssl-1.0.1c\bin;%PION_LIBS%\sqlite-3.7.14.1\bin;%PION_LIBS%\yajl-2.0.5\bin;%PION_LIBS%\zlib-1.2.7\bin;%PION_LIBS%\WpdPack-4.0.2\Bin;%PATH%
SET opts=/nologo /platform:Win32 /logcommands /nohtmllog /M1 /useenv
SET conf=Release_DLL_full
FOR %%I IN (%*) DO (SET opt=%%~I
  IF "!opt:~0,1!"=="/" SET opts=!opts! %%I
  IF "!opt!"=="debug" SET conf=Debug_DLL_full
  IF "!opt!"=="release" SET conf=Release_DLL_full)
FOR %%S in (*.sln) DO devenv %opts% "/logfile:%%~nS[%conf%].log" %%S "%conf%|Win32"
