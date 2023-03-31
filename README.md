# Cloudflare WARP Containerized 

Cloudflare offers a free VPN-style service to route your traffic through. 

Problem: Maintaining separate instances of Cloudflare registration is difficult. Segmenting traffic (some over your ISP, some over your own VPN, some over WARP) can be difficult with standard Cloudflare WARP desktop installations. By dockerizing WARP, we can stand up as many separate proxy silos as we need - with no OPSEC clean-up (in terms of networking infrastructure) after the fact. 

Recommendation: Always use a "first mile" VPN on the host VM or network running your container. This provides further separation between your traffic and the destination/target. Cloudflare will attempt to give each connection a semi-persistent IP address based on the geolocation of your source. Rotating regions/countries between tasks *may* be advisable. Many paid and free(not recommended) VPN services have this functionality. WARP allows you to bypass the roadblocks of providers that deny access to VPN/proxy/tor users. Your first mile can have a poor IP reputation score or be blocklisted, and CF will give you a "better" one.    
  
  
## Usage Instructions: 

1. Install [Docker and Docker Compose](https://docs.docker.com/compose/install/) from their official repository

2. Deploy the container:  
```
git clone https://github.com/smolbytes/warp-container  
cd warp-container  
sudo chmod +x init.sh  
sudo docker compose up -d warp-container  
#wait approx 60 seconds  
sudo docker ps -a   #check the health/status of your containers  #optional  
sudo ss -antup  #ensure port is listening  #optional  
```
  
3. Configure your web browser or device to use the proxy:  
SOCKS5 proxy config:  [IP_address]:9000  
Enjoy!    
  
To Terminate:  
```
sudo docker compose down  
```
  
  
Limitations/Considerations: Proxied data between your browser and the container will not necessarily be encrypted. Take caution before deploying on a VPS, cloud instance, or over a publicly accessible network. Packets between the container and CF are encrypted via the cipher suites in WireGuard. Recommend proxying DNS via SOCKS5 along with web requests. warp-cli does not support SOCKS/HTTP authentication, and I have not yet coded a "go between" to enable that functionality. Please open an issue or dicussion post to report any bugs or odd behavior.  
  
Dependencies: Docker, Docker Compose, Ubuntu container base (latest version from Dockerhub)  
