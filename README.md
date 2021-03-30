# ecs-container-agent
ECS container agent for CentOS/RHEL


Also this script install last revision of Docker for ECS agent.

> Refer to *https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-install.html*



```bash
./ecs-agent.sh my-cluster
```

If you need change you logging driver, look at here:
```bash
ECS_AVAILABLE_LOGGING_DRIVERS=["json-file","awslogs"]
```
