@setlocal

@REM ��ָ������˿ں�(����˿ں�һ����1080).
@set ProxyPort=1080

@set                 http_proxy=http://127.0.0.1:%ProxyPort%
@git config --global http.proxy http://127.0.0.1:%ProxyPort%

@echo ������ exit �˳�������ڣ������ű��ſ���ִ�����������
@call %comspec% /K

@set http_proxy=
@git config --global --unset http.proxy
@git config --get-regexp        .*proxy

@echo.
@echo ��λgit��http.proxy���.
@echo.

@pause
