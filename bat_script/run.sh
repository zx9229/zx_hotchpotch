#!/bin/bash
# 以UTF8编码,以LF作为换行符.

PROGRAM_NAME="MDServer"                                                                # <=== 请视情况修改.

SCRIPTS_DIR="$( cd "$( dirname "$0" )" && pwd )"  # 当前脚本目录(软链接无法正确取值).
cd "${SCRIPTS_DIR}"
if [ $? -ne 0 ]; then echo "[ERROR] coordinate: [$0][${LINENO}]"; exit 1; fi

PROGRAM_NAME_FULL="${SCRIPTS_DIR}/${PROGRAM_NAME}"

function program_start() {
    # export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${SCRIPTS_DIR}                             # <=== 请视情况修改.
    nohup "${PROGRAM_NAME_FULL}" >/dev/null 2>&1 &                                     # <=== 请视情况修改.
}

function show_all_matched_pid() {
# 显示所有匹配到的进程.
    local exe_full_name=$1
    local exe_base_name=$(basename "${exe_full_name}")
    for pid in $(/sbin/pidof "${exe_base_name}");
    do
        local exe=$(ls -l /proc/${pid}/exe | awk -F"exe -> " '{print $2}')
        if [ "${exe}" == "${exe_full_name}" ]; then
            echo "$(ls -l /proc/${pid}/exe)    [v]"
        else
            ls -l         /proc/${pid}/exe
        fi
    done
}

function program_status() {
    show_all_matched_pid "${PROGRAM_NAME_FULL}"
}

function kill_all_pid_same_exe_path(){
# 强杀(同一个可执行程序创建的)(所有的)进程.
    local exe_full_name=$1
    local exe_base_name=$(basename "${exe_full_name}")
    for pid in $(/sbin/pidof "${exe_base_name}");
    do
        local exe=$(ls -l /proc/${pid}/exe | awk -F"exe -> " '{print $2}')
        if [ "${exe}" == "${exe_full_name}" ]; then
            echo "will kill pid=${pid}, exe=${exe}"
            kill -9 ${pid}
        fi
    done
}

function program_stop() {
    kill_all_pid_same_exe_path "${PROGRAM_NAME_FULL}"
}

function program_run() {
    local   program=$1
    local   command=$2
    case "${command}" in
    'start' | 'restart')
        echo "program_stop   ==>"
        program_stop
        echo "program_start  ==>"
        program_start
        echo "program_status ==>"
        program_status
        ;;
    'stop')
        program_stop
        ;;
    'status')
        program_status
        ;;
    *)
        echo "[${PROGRAM_NAME}], Usage: ${program} { restart | start | stop | status }"
        ;;
    esac
}

program_run $0 $1
