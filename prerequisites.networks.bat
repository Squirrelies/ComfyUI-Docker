docker network create --driver bridge --subnet=172.50.1.0/24 --ip-range=172.50.1.0/24 --gateway=172.50.1.1 --ipv6=false ai-public-net
docker network create --driver bridge --subnet=172.50.2.0/24 --ip-range=172.50.2.0/24 --gateway=172.50.2.1 --ipv6=false --internal ai-internal-net
