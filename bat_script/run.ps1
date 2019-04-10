# 此为powershell脚本.
# 因为Windows的命令行, 我们是GBK, 所以脚本中尽量不要出现中文提示.
# 无法加载文件 xyz.ps1，因为在此系统上禁止运行脚本。有关详细信息，请参阅 ...
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

$PROGRAM_NAME = "MDServer.exe"                                                         # <=== 请视情况修改.

$SCRIPTS_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition
cd "$SCRIPTS_DIR"
if ($? -ne $true) { Write-Warning "Operation is abnormal!"; exit 1; }

$PROGRAM_NAME_FULL = Join-Path "$SCRIPTS_DIR" "$PROGRAM_NAME"

Function program_start() {
    start "$PROGRAM_NAME_FULL"                                                         # <=== 请视情况修改.
}

Function program_status() {
    cmd /c "WMIC PROCESS WHERE Name='$PROGRAM_NAME' GET ExecutablePath,ProcessId,Name" 2>$null
}

Function kill_all_pid_same_exe_path([string]$exe_full_name) {
    $AllLine=(cmd /c "WMIC PROCESS WHERE Name='$PROGRAM_NAME' GET ExecutablePath,ProcessId" 2>$null)
    foreach ($curLine in $AllLine)
    {
        if ( "$curLine".StartsWith($exe_full_name) ) {
            $curPid = "$curLine".Replace($exe_full_name, "").Trim()
            if ( !($curPid -match "^\d+$") ) { continue }
            Write-Warning ("will kill pid={0}, exe={1}" -f $curPid, $exe_full_name)
            TASKKILL /F /PID $curPid
        }
    }
}

Function program_stop(){
    kill_all_pid_same_exe_path "$PROGRAM_NAME_FULL"
}

Function program_run( [string]$program, [string]$command ) {
    switch -casesensitive ($command)
    {
        {"start","restart" -contains $_} {
            Write-Warning "program_stop   ==>"
            program_stop
            Write-Warning "program_start  ==>"
            program_start
            Write-Warning "program_status ==>"
            program_status
            break
        }
        "stop"{
            program_stop
            break
        }
        "status"{
            program_status
            break
        }
        Default{
            Write-Warning "[${PROGRAM_NAME}], Usage: ${program} { restart | start | stop | status }"
            break
        }
    }
}

if ($args.Count -eq 0)
{
    While ($true) {
        Write-Host "please input { restart | start | stop | status }:"
        $command=Read-Host
        program_run  $MyInvocation.MyCommand.Name  $command
    }
}
else
{
    program_run  $MyInvocation.MyCommand.Name  $args[0]
}
