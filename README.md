# ecs-container-agent
ECS container agent for CentOS/RHEL


Also this script install last revision of Docker for ECS agent.

> Refer to *https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-install.html*



```bash
./ecs-agent.sh my-cluster
```


I chose json and awslogs format as the main log driver.
```bash
ECS_AVAILABLE_LOGGING_DRIVERS=["json-file","awslogs"]
```
If using **awslogs**, remember to use the following policies for your ECS container instance.

```json
{
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:log-group:*"
            ],
            "Effect": "Allow",
            "Sid": "AllowCWLogsForEc2Instances"
}
```