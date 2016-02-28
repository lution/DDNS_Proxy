# DDNS_Proxy
This is a DDNS proxy service for DNS Provider like Cloudflare and DNSPod. This project is based on Nginx and the [nginx\_lua\_module](https://www.nginx.com/resources/wiki/modules/lua/).

It is designed to work with the built-in DDNS clients of network devices like routers and NAS. These clients usually offer very limited choices of DNS service provider so you may want to use your own. Luckily many big DNS service providers allow updating DNS records through API, and so here comes this tool!

## Capacity
DD-WRT

(Testing on more)

## Todos
* Add Email notification when record is updated
* Correct all the FIXME codes
* Add DNSPod and CloudXNS

## Usage
