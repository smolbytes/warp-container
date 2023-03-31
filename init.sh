#!/bin/bash
#
#warp-cli installer inside container
apt -q update
#install dependencies
apt -yq install --no-install-recommends coreutils curl grep ca-certificates gpg lsb-release iproute2 iptables
#apt -yq install systemd systemd-sysv dbus dbus-user-session #not needed with warp-svc
#add cloudflare repo and install warp-cli
curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list
apt -q update
apt -yq install cloudflare-warp  #no systemd in container, failures in apt log are normal
#setup options
nohup warp-svc &
#warp-svc 1>/dev/null 2>/dev/null &
sleep 10
warp-cli --accept-tos register
warp-cli --accept-tos set-mode proxy
warp-cli --accept-tos set-proxy-port 9000
warp-cli --accept-tos enable-always-on
#warp-cli --accept-tos connect #let Dockerfile handle

#add routing rules to network interface
#nic_name=$(ip -br l | awk '$1 !~ "lo>|vir|wl" { print $1}')  #TODO make this work in docker also
nic_name='eth0'
#echo ${nic_name}
#sysctl -w net.ipv4.conf.${nic_name}.route_localnet=1   #needs to be done in docker compose file instead
iptables -t nat -A PREROUTING -i ${nic_name} -p tcp --dport 9000 -j DNAT --to-destination 127.0.0.1:9000

#refs
#https://unix.stackexchange.com/questions/111433/iptables-redirect-outside-requests-to-127-0-0-1
#https://serverfault.com/questions/842964/bash-script-to-retrieve-name-of-ethernet-network-interface
#https://stackoverflow.com/questions/66205286/enable-systemctl-in-docker-container
#https://stackify.com/docker-build-a-beginners-guide-to-building-docker-images