@REM ��ǰĿ¼�����кܶ���Ŀ¼, ÿ��Ŀ¼����һ�� git repository  
@REM �ֹ�����һƫ�Ƶ���Ŀ¼��ִ�� git �����Ǻܿ��ﷱ����, ���д˽ű�  
@REM ������ %USERPROFILE%\go\src\github.com\zx9229  

@ECHO OFF  
REM ���������ӳٵ�����.  
SETLOCAL enabledelayedexpansion  

SET OPERATION_DIR=".\*"  

:: ���� /R "ĳĿ¼"  ��ʾ��Ҫ�������ļ���,ȥ����ʾ���������ļ���  
:: ���� /D ��ʾ  ƥ��ָ��λ���ϵ��ļ���  
:: %%a ��һ������,�����ڵ�����,�����������ֻ����һ����ĸ���,ǰ�����%%  
:: ��������ͨ���,����ָ����׺��,*.* ��ʾ�����ļ�  
FOR /D %%a IN ( %OPERATION_DIR% ) DO (  
REM  
PUSHD %%a && CHDIR && ECHO git_status && git status && POPD  
IF NOT "!ERRORLEVEL!" == "0" (  
ECHO return_value ^( git status ^) is !ERRORLEVEL!  
GOTO :label_end  
)  
REM  
ECHO -------------------------------------------  
)  

:label_end  
@ECHO ON  
PAUSE  
