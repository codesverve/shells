function ssh-jump {
 ssh zxxxg@4x.xxx.xx.xx7
}

function tunnel-to-iserver {
 ssh -Nf -L 12001:172.xx.xx.xxx:22 zxxxg@4x.xxx.xx.xx7
}

function ssh-server-by-tunnel {
 ssh -p 12000 zxxxg@127.0.0.1
}

function tunnel-to-mysql {
 ssh -Nf -L 23306:rm-wxxxxxxxxxxxx0.mysql.rds.aliyuncs.com:3306 -p 12000 zxxxg@127.0.0.1
}