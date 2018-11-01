#! /bin/bash
#======================================================================#
# 注意: 脚本需要以 UTF-8 编码, 并以 LF 结尾.
#======================================================================#
AppDir="/root/tb_tun"
IFNAME="tb-tun"
Server_IPv4_Address="74.82.46.6"
Client_IPv4_Address="1.119.141.146"
Client_IPv6_Address="2001:470:23:11ca::2/64"



function fun_check(){
    wget --help  > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "[ERROR]:${LINENO}, Please install wget software." 1>&2
        exit 1
    fi

    gcc --version > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "[ERROR]:${LINENO}, Please install gcc software." 1>&2
        exit 1
    fi

    if [[ $EUID -ne 0 ]]; then
        echo "[ERROR]:${LINENO}, You must run the script with root privileges." 1>&2
        exit 1
    fi
}


function fun_stop() {
    echo "action [stop] BEG..."

    ip link set ${IFNAME} down
    if [ $? -ne 0 ]; then echo "[ERROR]:${LINENO}"; return 1; fi

    # 猜测: 找到默认路由的名字 (D_I => DefaultInterface ?) (0/0 => 0.0.0.0/0 ?)
    D_I=$(ip route show exact 0/0 | sort -k 7 | head -n 1 | sed -n 's/^default.* dev \([^ ]*\).*/\1/p')
    if [ "${D_I}" == "" ]; then echo "[ERROR]:${LINENO}"; return 1; fi

    ip -6 route add ::/0 dev ${D_I}
    if [ $? -ne 0 ]; then echo "[ERROR]:${LINENO}"; return 1; fi

    ip -6 route del ::/0 dev ${IFNAME}
    if [ $? -ne 0 ]; then echo "[ERROR]:${LINENO}"; return 1; fi

    killall -9 tb_userspace

    echo "action [stop] END."
    return 0
}


function fun_start() {
    echo "action [start] BEG..."

    setsid ${AppDir}/tb_userspace ${IFNAME} ${Server_IPv4_Address} ${Client_IPv4_Address} sit > /dev/null 2>&1 &
    if [ $? -ne 0 ]; then echo "[ERROR]:${LINENO}"; return 1; fi

    sleep 1s

    # 给名为${IFNAME}的设备设置一个IP地址
    ip -6 address add ${Client_IPv6_Address} dev ${IFNAME}
    if [ $? -ne 0 ]; then echo "[ERROR]:${LINENO}"; return 1; fi

    # 启动名为${IFNAME}的设备
    ip link set ${IFNAME} up
    if [ $? -ne 0 ]; then echo "[ERROR]:${LINENO}"; return 1; fi

    # 设置网卡最大传输单元
    ip link set ${IFNAME} mtu 1480
    
    # 设置::/0网段的数据走${IFNAME}
    ip -6 route add ::/0 dev ${IFNAME}

    D_I=$(ip route show exact 0/0 | sort -k 7 | head -n 1 | sed -n 's/^default.* dev \([^ ]*\).*/\1/p')
    if [ "${D_I}" == "" ]; then echo "[ERROR]:${LINENO}"; return 1; fi

    ip -6 route del ::/0 dev ${D_I}
    if [ $? -ne 0 ]; then echo "[ERROR]:${LINENO}"; return 1; fi
    
    echo "action [start] END."
    return 0
}


function fun_install() {
    echo "action [install] BEG..."
    
    mkdir -p ${AppDir}
    if [ $? -ne 0 ]; then echo "[ERROR]:${LINENO}"; return 1; fi
    
    wget --directory-prefix=${AppDir} https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/tb-tun/tb-tun_r18.tar.gz  > /dev/null 2>&1
    if [ $? -ne 0 ]; then echo "[ERROR]:${LINENO}"; return 1; fi
    
    cd ${AppDir}
    if [ $? -ne 0 ]; then echo "[ERROR]:${LINENO}"; return 1; fi
    
    tar -xf tb-tun_r18.tar.gz
    if [ $? -ne 0 ]; then echo "[ERROR]:${LINENO}"; return 1; fi
    
    gcc tb_userspace.c -l pthread -o tb_userspace
    if [ $? -ne 0 ]; then echo "[ERROR]:${LINENO}"; return 1; fi
    
    chmod 0777 ./tb_userspace
    if [ $? -ne 0 ]; then echo "[ERROR]:${LINENO}"; return 1; fi

    echo "action [install] END."
    return 0
}


function func_run() {
    local   program=$1
    local   command=$2
    case "${command}" in
    'start')
        fun_stop  &&  fun_start
        ;;
    'stop')
        fun_stop
        ;;
    'restart')
        fun_stop  &&  fun_start
        ;;
    'install')
        fun_stop  &&  fun_install
        ;;
    *)
        echo "Usage: ${program} { start | stop | restart | install }"
        ;;
    esac
}


fun_check
func_run $0 $1

retval=$?
echo "execute [$1] with retval=${retval}"
exit ${retval}
