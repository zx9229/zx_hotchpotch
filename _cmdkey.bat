@echo off

cmdkey   /list:git:https://github.com

set /p INPUT=Ҫɾ����ƾ֤��[y/N]: 

if /i "%INPUT%"=="y" (
cmdkey /delete:git:https://github.com
echo.
) else (
echo.
echo δɾ��
echo\
)

pause
