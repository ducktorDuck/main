#!/bin/bash

cd

exec >stackscript.log 2>&1

apt update && apt install iptables ipset wget less -y

wait

sleep 1

sysctl -w net.ipv6.conf.all.disable_ipv6=1

sysctl -w net.ipv6.conf.default.disable_ipv6=1

sysctl -w net.ipv6.conf.lo.disable_ipv6=1

iptables -t mangle -A PREROUTING -i eth0 -s 3.9.13.234 -j DROP

iptables -t mangle -A PREROUTING -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT

wait

iptables -t mangle -A PREROUTING -i eth0 -j DROP

wait

cat <<TKRY >haloload.sh

halo() {

    echo "\$*" >> ~/input.txt

}

halo antispam 2

sleep 0.3

halo sv_log_enabled 1

sleep 0.3

halo no_lead 1

sleep 0.3

halo sv_maxplayers 16

sleep 0.3

halo chat_console_echo 1

TKRY

chmod +x haloload.sh

cat <<FIRE >fire.sh

ip link set eth0 mtu 9000

wait

sleep 1

sysctl -w net.ipv6.conf.all.disable_ipv6=1

sysctl -w net.ipv6.conf.default.disable_ipv6=1

sysctl -w net.ipv6.conf.lo.disable_ipv6=1

sysctl -w net.ipv4.ipfrag_low_thresh=0

sysctl -w net.ipv4.ipfrag_high_thresh=0

sysctl -w net.ipv4.ipfrag_time=0

# sysctl -w net.ipv4.ip_forward=1

sysctl -w net.core.netdev_max_backlog=4000

ipset create LEGIT hash:ip,port timeout 20

ipset create TEST1 hash:ip timeout 80

ipset create BLOCK hash:ip timeout 300

ipset create BAN hash:ip

ipset create MDNS hash:ip

wait

ipset add MDNS 54.82.252.156

ipset add MDNS 34.197.71.170

ipset add MDNS api.linode.com

ipset create TESTS list:set

ipset add TESTS TEST1

ipset add TESTS MDNS

ipset add BAN 181.65.32.0/19

wait

iptables -t raw -N pcheck

iptables -t mangle -N ctest2

iptables -t mangle -N reconnect

# iptables -t raw -A PREROUTING -j NOTRACK

iptables -t raw -A PREROUTING -i eth0 -m set --match-set TESTS src -j ACCEPT

iptables -t raw -A PREROUTING -i eth0 -m length --length 48 -j pcheck

iptables -t raw -A PREROUTING -i eth0 -m length ! --length 67 -j DROP

iptables -t raw -A PREROUTING -i eth0 -m u32 --u32 "28=0xfefe0100" -j pcheck

iptables -t raw -A PREROUTING -i eth0 -j DROP

iptables -t raw -A pcheck -p udp --sport 53 -j DROP

iptables -t raw -A pcheck -m set --match-set BLOCK src -j DROP

iptables -t raw -A pcheck -p udp --sport 0 -j SET --exist --add-set BLOCK src

iptables -t raw -A pcheck -m set --match-set BLOCK src -j DROP

iptables -t raw -A pcheck ! -p udp -j SET --exist --add-set BLOCK src

iptables -t raw -A pcheck -p udp ! --dport 2302:2502 -j SET --exist --add-set BLOCK src

iptables -t raw -A pcheck -m set --match-set BAN src -j DROP

iptables -t raw -A pcheck -m length --length 48 -m u32 --u32 "42=0x1333360c" -j SET --exist --add-set TEST1 src

iptables -t raw -A pcheck -m length --length 67 -m u32 --u32 "28=0xfefe0100" -j SET --exist --add-set TEST1 src

iptables -t raw -A pcheck -m set --match-set TEST1 src -j ACCEPT

iptables -t raw -A pcheck -j DROP

iptables -t mangle -A PREROUTING -i eth0 -j SET --exist --add-set TEST1 src

iptables -t mangle -A PREROUTING -i eth0 -m recent --name badguy4 --set

iptables -t mangle -A PREROUTING -i eth0 -m recent --update --name badguy4 --seconds 1 --hitcount 255 -j reconnect

iptables -t mangle -A PREROUTING -i eth0 -m set --match-set LEGIT src,src -j SET --exist --add-set LEGIT src,src

iptables -t mangle -A PREROUTING -i eth0 -m set --match-set LEGIT src,src -j ACCEPT

iptables -t mangle -A PREROUTING -i eth0 -m set --match-set BAN src -j DROP

iptables -t mangle -A PREROUTING -i eth0 -m set --match-set MDNS src -j ACCEPT

iptables -t mangle -A PREROUTING -i eth0 -m set --match-set TEST1 src -j ctest2

iptables -t mangle -A PREROUTING -i eth0 -j DROP

iptables -t mangle -A ctest2 -m recent --name badguy3 --set

iptables -t mangle -A ctest2 -m recent --update --name badguy3 --seconds 1 --hitcount 15 -j SET --exist --add-set BLOCK src

iptables -t mangle -A ctest2 -m connlimit --connlimit-above 4 --connlimit-mask 32 -j SET --exist --add-set BLOCK src

iptables -t mangle -A ctest2 -p udp --sport 0 -j SET --exist --add-set BLOCK src

iptables -t mangle -A ctest2 ! -p udp -j SET --exist --add-set BLOCK src

iptables -t mangle -A ctest2 -p udp ! --dport 2302:2502 -j SET --exist --add-set BLOCK src

iptables -t mangle -A ctest2 -p udp --sport 53 -j SET --exist --add-set BLOCK src

iptables -t mangle -A ctest2 -m set --match-set BLOCK src -j DROP

iptables -t mangle -A ctest2 -m length --length 31 -m u32 --u32 "27&0x00FFFFFF=0x00fefe68" -j ACCEPT

iptables -t mangle -A ctest2 -m u32 --u32 "28=0xfefe0100" -j SET --exist --add-set LEGIT src,src

iptables -t mangle -A ctest2 -m set --match-set LEGIT src,src -j ACCEPT

iptables -t mangle -A ctest2 -m length --length 34 -m u32 --u32 "28=0x5C717565" -j ACCEPT

iptables -t mangle -A ctest2 -m length --length 48 -m u32 --u32 "42=0x1333360c" -j ACCEPT

iptables -t mangle -A ctest2 -m u32 --u32 "34&0xFFFFFF=0xFFFFFF" -j ACCEPT

iptables -t mangle -A reconnect -j SET --del-set TEST1 src

iptables -t mangle -A reconnect -j SET --del-set LEGIT src,src

iptables -t mangle -A reconnect -j SET --exist --add-set BAN src

iptables -t mangle -A ctest2 -j DROP

systemctl stop systemd-timesyncd && systemctl stop systemd-resolved

FIRE

chmod +x fire.sh

wait

cat <<FLUSH >flush.sh

iptables -F

iptables -X

iptables -t nat -F

iptables -t nat -X

iptables -t mangle -F

iptables -t mangle -X

iptables -t raw -F

iptables -t raw -X

ipset destroy TESTS

ipset destroy LEGIT

ipset destroy TEST1

ipset destroy BAN

ipset destroy BLOCK

ipset destroy MDNS

systemctl start systemd-resolved && systemctl start systemd-timesyncd

# ip link set dev eth0 xdp off

FLUSH

chmod +x flush.sh

cat <<UPAPI >update.sh

TOKEN=\$(cat t.txt)

ipset list LEGIT | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sed 's/^/"/; s/$/\/32",/' |tr '\n' ' ' | sed 's/.$//' > legit.txt

ipset list MDNS | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sed 's/^/"/; s/$/\/32",/' |tr '\n' ' ' | sed 's/.$//' | sed 's/.$//' > mdns.txt

MDNS=\$(cat mdns.txt)

IP2=\$(cat legit.txt)

IPs=\$(printf "\$IP1 \$IP2 \$MDNS")

curl -H "Content-Type: application/json" \\

    -H "Authorization: Bearer \$TOKEN" \\

    -X PUT -d '{

	"inbound_policy": "DROP",

        "inbound": [

          {

            "protocol": "UDP",

            "ports": "2302",

            "addresses": {

              "ipv4": [

               '"\$IPs"'

              ]

           },

         "action": "ACCEPT"

         }

 	],

	"outbound_policy": "ACCEPT"

    }' \\

    https://api.linode.com/v4beta/networking/firewalls/2502/rules &>/dev/null

UPAPI

chmod +x update.sh

cat <<DISAPI >disable.sh

TOKEN=\$(cat t.txt)

curl -H "Content-Type: application/json"     -H "Authorization: Bearer \$TOKEN"     -X PUT -d '{

	"inbound_policy": "DROP",

        "inbound": [

                 {

            "ports":"53",

            "protocol": "UDP",

            "addresses":{

              "ipv4":[

                "0.0.0.0/0"

              ],

              "ipv6":[

                "::/0"

              ]

           },

         "action": "DROP"

    	 },

    	 {

            "ports":"1-65535",

            "protocol":"TCP",

            "addresses":{

              "ipv4":[

                "0.0.0.0/0"

              ],

              "ipv6":[

                "::/0"

              ]

           },

         "action":"DROP"

    	 },

    	 {

            "protocol":"ICMP",

            "addresses":{

              "ipv4":[

               "0.0.0.0/0"

              ],

              "ipv6":[

                "::/0"

              ]

           },

         "action":"DROP"

    	 },

    	 {

            "ports":"2302",

            "protocol":"UDP",

            "addresses":{

              "ipv4":[

                "0.0.0.0/0"

              ]

           },

         "action":"ACCEPT"

         }

 	],

	"outbound_policy":"ACCEPT"

    }' \\

    https://api.linode.com/v4beta/networking/firewalls/2502/rules &>/dev/null

DISAPI

chmod +x disable.sh

cat <<TISAPI >disable3.sh

TOKEN=\$(cat t.txt)

curl -H "Content-Type: application/json"     -H "Authorization: Bearer \$TOKEN"     -X PUT -d '{

	"inbound_policy": "DROP",

        "inbound": [

                 {

            "ports":"53",

            "protocol": "UDP",

            "addresses":{

              "ipv4":[

                "0.0.0.0/0"

              ],

              "ipv6":[

                "::/0"

              ]

           },

         "action": "DROP"

    	 },

    	 {

            "ports":"9000",

            "protocol":"TCP",

            "addresses":{

              "ipv4":[

                "0.0.0.0/0"

              ]

           },

         "action":"ACCEPT"

    	 },

    	 {

            "ports":"1-65535",

            "protocol":"TCP",

            "addresses":{

              "ipv4":[

                "0.0.0.0/0"

              ],

              "ipv6":[

                "::/0"

              ]

           },

         "action":"DROP"

    	 },

    	 {

            "protocol":"ICMP",

            "addresses":{

              "ipv4":[

               "0.0.0.0/0"

              ],

              "ipv6":[

                "::/0"

              ]

           },

         "action":"DROP"

    	 },

    	 {

            "ports":"2302",

            "protocol":"UDP",

            "addresses":{

              "ipv4":[

                "0.0.0.0/0"

              ]

           },

         "action":"ACCEPT"

         }

 	],

	"outbound_policy":"ACCEPT"

    }' \\

    https://api.linode.com/v4beta/networking/firewalls/2502/rules &>/dev/null

TISAPI

chmod +x disable3.sh

cat <<QISAPI >disable2.sh

TOKEN=\$(cat t.txt)

wait

IPs=\$(cat netblock.txt | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\/[0-9][0-9]$\b" | sed 's/^/"/; s/$/\",/' |tr '\n' ' ' | sed 's/.$//' | sed 's/.$//')

wait

curl -H "Content-Type: application/json" \

    -H "Authorization: Bearer \$TOKEN" \

    -X PUT -d '{

	"inbound_policy": "DROP",

        "inbound": [

                 {

            "ports":"53",

            "protocol": "UDP",

            "addresses":{

              "ipv4":[

                "0.0.0.0/0"

              ],

              "ipv6":[

                "::/0"

              ]

           },

         "action": "DROP"

    	 },

    	 {

            "ports":"53",

            "protocol":"TCP",

            "addresses":{

              "ipv4":[

                "0.0.0.0/0"

              ],

              "ipv6":[

                "::/0"

              ]

           },

         "action":"DROP"

    	 },

    	 {

            "ports":"1-65535",

            "protocol":"UDP",

            "addresses":{

              "ipv4":[

               '"\$IPs"'

              ]

           },

         "action":"DROP"

    	 },

    	 {

            "ports":"2302",

            "protocol":"UDP",

            "addresses":{

              "ipv4":[

                "0.0.0.0/0"

              ]

           },

         "action":"ACCEPT"

         }

 	],

	"outbound_policy":"ACCEPT"

    }' \\

    https://api.linode.com/v4beta/networking/firewalls/2502/rules &>/dev/null

QISAPI

chmod +x disable2.sh

cat <<NLOCK >netblock.txt

1.0.0.0/8

104.16.0.0/12

154.24.0.0/13

162.158.80.0/20

162.158.56.0/21

162.158.80.0/20

162.254.196.0/22

103.21.244.0/22

103.22.200.0/22

103.31.4.0/22

104.16.0.0/13

104.24.0.0/14

108.162.192.0/18

131.0.72.0/22

141.101.64.0/18

162.158.0.0/15

172.64.0.0/13

173.245.48.0/20

188.114.96.0/20

190.93.240.0/20

197.234.240.0/22

198.41.128.0/17

NLOCK

cat <<TRIGAPI >trigger.sh

#!/bin/bash

while :

do

   R1=\$(cat /sys/class/net/eth0/statistics/rx_bytes)

   sleep 1

   R2=\$(cat /sys/class/net/eth0/statistics/rx_bytes)

   tot=\$(( R2 - R1 ))

   wait

   if [ "\$tot" -gt "500000" ]; then

      ./update.sh

      wait

      sleep 400

      echo "Flood!"

      ./disable3.sh

      sleep 300

   fi

      sleep 3

done

TRIGAPI

chmod +x trigger.sh

wait

cat <<SPAPI >spark.sh

#!/bin/bash

R1=\$(cat /sys/class/net/eth0/statistics/rx_bytes)

sleep 1

R2=\$(cat /sys/class/net/eth0/statistics/rx_bytes)

tot=\$(( R2 - R1 ))

wait

until [ "\$tot" -gt "600000" ]; do

    sleep 1

    R1=\$(cat /sys/class/net/eth0/statistics/rx_bytes)

    wait

    sleep 1

    R2=\$(cat /sys/class/net/eth0/statistics/rx_bytes)

    wait

    tot=\$(( R2 - R1 ))

done

./update.sh

wait

echo "Flood!"

sleep 300

./disable.sh

wait

./testrig.sh

SPAPI

chmod +x spark.sh

cat <<WALS >wal.sh

iconv -f UTF-16LE -t UTF-8 halopull/haloserver.log -o haloserver.txt && \\

grep wal haloserver.txt && \\

rm haloserver.txt

WALS

chmod +x wal.sh

cat <<SLEAN >cleaner.sh

iconv -f UTF-16LE -t UTF-8 halopull/haloserver.log -o haloserver.txt && \\

grep CHAT haloserver.txt # | \\

# awk '{out=""; for(i=5;i<=NF;i++){out=out" "\$i}; print out}' && \

rm haloserver.txt

SLEAN

chmod +x cleaner.sh

cat <<GFTY >testrig.sh

#!/bin/bash

while :

do

   R3=\$(ipset list LEGIT | grep -oE "\b([0-9]{1,3}.){3}[0-9]{1,3}\b" | wc -l)

   R1=\$(cat /sys/class/net/eth0/statistics/rx_bytes)

   sleep 1

   R2=\$(cat /sys/class/net/eth0/statistics/rx_bytes)

   tot=\$(( R2 - R1 ))

   wait

   if [ "\$tot" -gt "500000" ]; then

      ./update.sh

      wait

      sleep 300

      echo "Flood!"

      ./disable.sh

   else

       if [ "\$R3" -gt 15 ]; then

          ./update.sh

          wait

          sleep 120

          ./disable.sh

       fi

   fi

      sleep 2

done

GFTY

chmod +x testrig.sh

sleep 1

apt update

wait

sleep 1

echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections

wait

apt-get -y install tshark nmap htop nload unzip socat

wait

sleep 2

wget -O halopull.zip https://github.com/antimomentum/halopull/archive/refs/heads/master.zip && unzip halopull.zip && mv halopull-master halopull

wait

sleep 3

touch input.txt

echo "nohup tail -F ~/input.txt 2> /dev/null | nohup wineconsole haloceded.exe -path . > nohup.out & echo \$!" > halopull/start-nohup.sh

chmod +x halopull/start-nohup.sh

apt update

wait

apt-get install -y wget && apt-get install -y && dpkg --add-architecture i386

wait

apt-get update

wait

apt install -y wine32

wait

sleep 2

apt remove -y unattended-upgrades

wait

systemctl disable apt-daily-upgrade.timer

wait

systemctl disable apt-daily.timer

wait

echo "34.197.71.170 hosthpc.com" >> /etc/hosts

echo "34.197.71.170 s1.master.hosthpc.com" >> /etc/hosts

echo "72.14.180.203 api.linode.com" >> /etc/hosts

wait

apt autoremove -y

wait

apt remove sysstat snapd -y

wait

apt install curl -y

wait

sleep 2

cat <<SOKAY >halopull/so.sh

while true; do socat -v -v TCP-LISTEN:9000,crlf,reuseaddr,fork SYSTEM:"echo HTTP/1.0 200; echo Content-Type\: text/plain; echo; tail -n 5 nohup.out" 2>/dev/null; sleep 1; done

SOKAY

cat<<TSAIL >halopull/tailso.sh

socat -v -v TCP-LISTEN:9000,crlf,reuseaddr,fork SYSTEM:"echo HTTP/1.0 200

echo Content-Type\: text/plain

echo

tail -f nohup.out" 2>/dev/null

TSAIL

systemctl disable sshd

wait

chmod +x halopull/so.sh

chmod +x halopull/tailso.sh


