#!/bin/bash
cluster=$1;

#Install last version docker
yum install -y yum-utils
yum remove -y docker \
docker-client \
docker-client-latest \
docker-common \
docker-latest \
docker-latest-logrotate \
docker-logrotate \
docker-engine
curl -sk https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
systemctl start docker
systemctl enable docker
docker version

#Install ECS agent
curl -o ecs-agent.tar https://s3.amazonaws.com/amazon-ecs-agent-us-east-1/ecs-agent-latest.tar
docker load < ecs-agent.tar
rm -rf ecs-agent.tar
docker images

#Configuring instance for ECS
sh -c "echo 'net.ipv4.conf.all.route_localnet = 1' >> /etc/sysctl.conf"
sysctl -p /etc/sysctl.conf
iptables -t nat -A PREROUTING -p tcp -d 169.254.170.2 --dport 80 -j DNAT --to-destination 127.0.0.1:51679
iptables -t nat -A OUTPUT -d 169.254.170.2 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 51679
iptables -A INPUT -i eth0 -p tcp --dport 51678 -j DROP
sh -c 'iptables-save > /etc/sysconfig/iptables'
mkdir -p /var/log/ecs /var/lib/ecs/data
mkdir -p /etc/ecs && touch /etc/ecs/ecs.config
ECS_DATADIR=/data >> /etc/ecs/ecs.config
ECS_ENABLE_TASK_IAM_ROLE=true >> /etc/ecs/ecs.config
ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true >> /etc/ecs/ecs.config
ECS_LOGFILE=/log/ecs-agent.log >> /etc/ecs/ecs.config
ECS_AVAILABLE_LOGGING_DRIVERS=["json-file","awslogs"] >> /etc/ecs/ecs.config
ECS_LOGLEVEL=info >> /etc/ecs/ecs.config
ECS_CLUSTER=$cluster >> /etc/ecs/ecs.config

#Run agent
docker run --name ecs-agent \
--detach=true \
--restart=always \
--volume=/var/run:/var/run \
--volume=/var/log/ecs/:/log \
--volume=/var/lib/ecs/data:/data \
--volume=/etc/ecs:/etc/ecs \
--net=host \
--env-file=/etc/ecs/ecs.config \
amazon/amazon-ecs-agent:latest