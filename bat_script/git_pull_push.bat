@REM 当前目录下面有很多子目录, 每个目录都是一个 git repository  
@REM 手工的逐一偏移到子目录并执行 git 命令是很枯燥繁琐的, 遂有此脚本  
@REM 常见于 %USERPROFILE%\go\src\github.com\zx9229  

@MODE CON COLS=120 LINES=300
@ECHO OFF  
REM 开启变量延迟的设置.  
SETLOCAL enabledelayedexpansion  

SET TIMTOUT_SECONDS=0
ECHO TIMTOUT_SECONDS=%TIMTOUT_SECONDS%  
SET OPERATION_DIR=".\*"  

:: 参数 /R "某目录"  表示需要遍历子文件夹,去掉表示不遍历子文件夹  
:: 参数 /D 表示  匹配指定位置上的文件夹  
:: %%a 是一个变量,类似于迭代器,但是这个变量只能由一个字母组成,前面带上%%  
:: 括号中是通配符,可以指定后缀名,*.* 表示所有文件  
FOR /D %%a IN ( %OPERATION_DIR% ) DO (  
REM  
TIMEOUT /T %TIMTOUT_SECONDS% /NOBREAK > NUL
PUSHD %%a && CHDIR && ECHO git_pull && git pull --rebase && POPD  
IF NOT "!ERRORLEVEL!" == "0" (  
ECHO return_value ^( git pull ^) is !ERRORLEVEL!  
GOTO :label_end  
)  
REM  
TIMEOUT /T %TIMTOUT_SECONDS% /NOBREAK > NUL
PUSHD %%a && CHDIR && ECHO git_push && git push          && POPD  
IF NOT "!ERRORLEVEL!" == "0" (  
ECHO return_value ^( git push ^) is !ERRORLEVEL!  
GOTO :label_end  
)  
REM
ECHO -------------------------------------------  
)  

:label_end  
@ECHO ON  
PAUSE  

@REM 列出指定凭据: ( git:https://github.com )
@REM cmdkey    /list:git:https://github.com
@REM 删除现有凭据:
@REM cmdkey  /delete:git:https://github.com
@REM 创建普通凭据:
@REM cmdkey /generic:git:https://github.com /user:zx9229 /pass
