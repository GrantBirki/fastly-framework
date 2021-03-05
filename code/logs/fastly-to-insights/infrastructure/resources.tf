# Please note, this is a basic example of how to setup this cluster in AWS ECS
# You will need to make small edits to this file and ensure this is
# compliant with your security standards.

resource "aws_ecs_cluster" "fastly_to_insights_fargate_cluster" {
    capacity_providers = [
        "FARGATE",
        "FARGATE_SPOT",
    ]
    name = "fastly_to_insights_fargate_cluster"
    tags = {
        "managed_by" = "terraform"
    }

    setting {
        name  = "containerInsights"
        value = "enabled"
    }
}

resource "aws_ecs_service" "fastly_to_insights_fargate_service" {
    cluster                            = aws_ecs_cluster.fastly_to_insights_fargate_cluster.id
    deployment_maximum_percent         = 200
    deployment_minimum_healthy_percent = 100
    desired_count                      = 1
    enable_ecs_managed_tags            = true
    health_check_grace_period_seconds  = 0
    iam_role                           = "aws-service-role"
    launch_type                        = "FARGATE"
    name                               = "fastly_to_insights_fargate_service"
    platform_version                   = "LATEST"
    scheduling_strategy                = "REPLICA"
    tags                               = {
        "managed_by" = "terraform"
    }
    force_new_deployment               = true

    deployment_controller {
        type = "ECS"
    }

    network_configuration {
        assign_public_ip = false
        security_groups  = [
            "enter sec group here", # Enable all egress and block all ingress - You'll need to create on in AWS
        ]
        subnets          = [
            "enter subnet here", # Add your desired VPC subnet to use here
        ]
    }

    timeouts {}
}

resource "aws_ecs_task_definition" "fastly_to_insights_task_definition" {
    container_definitions    = jsonencode(
        [
            {
                command      = []
                cpu          = 0
                entryPoint   = []
                environment  = [
                    {
                        name  = "ENV"
                        value = "AWS"
                    },
                ]
                essential        = true
                image            = "<accountID>.dkr.ecr.<region>.amazonaws.com/fastly-to-insights:latest"
                links            = []
                logConfiguration = {
                    logDriver = "awslogs"
                    options   = {
                        awslogs-group         = "/ecs/fastly_to_insights_task_definition"
                        awslogs-region        = "<region>"
                        awslogs-stream-prefix = "ecs"
                    }
                }
                mountPoints      = []
                name             = "fastly-to-insights"
                portMappings     = []
                secrets          = [
                    {
                        name      = "ACCOUNT_ID"
                        valueFrom = "arn:aws:secretsmanager:<region>:<accountID>:secret:ACCOUNT_ID-xxxxxx" # create this in AWS secrets manager
                    },
                    {
                        name      = "FASTLY_KEY"
                        valueFrom = "arn:aws:secretsmanager:<region>:<accountID>:secret:FASTLY_KEY-xxxxxx" # create this in AWS secrets manager
                    },
                    {
                        name      = "INSERT_KEY"
                        valueFrom = "arn:aws:secretsmanager:<region>:<accountID>:secret:INSERT_KEY-xxxxxx" # create this in AWS secrets manager
                    },
                ]
                volumesFrom      = []
            },
        ]
    )
    cpu                      = "256"
    execution_role_arn       = aws_iam_role.fastly_to_insights_ecs_task_role.arn
    family                   = "fastly_to_insights_task_definition"
    memory                   = "512"
    network_mode             = "awsvpc"
    requires_compatibilities = [
        "FARGATE",
    ]
    tags                               = {
        "managed_by" = "terraform"
    }
    task_role_arn            = aws_iam_role.fastly_to_insights_ecs_task_role.arn
}

resource "aws_iam_role" "fastly_to_insights_ecs_task_role" {
    assume_role_policy    = jsonencode(
        {
            Statement = [
                {
                    Action    = "sts:AssumeRole"
                    Effect    = "Allow"
                    Principal = {
                        Service = "ecs-tasks.amazonaws.com"
                    }
                    Sid       = ""
                },
            ]
            Version   = "2012-10-17"
        }
    )
    description           = "Allows ECS tasks to call AWS services on your behalf."
    force_detach_policies = false
    max_session_duration  = 3600
    name                  = "fastly_to_insights_ecs_task_role"
    path                  = "/"
    tags                               = {
        "managed_by" = "terraform"
    }
}

resource "aws_ssm_parameter" "fastly_to_insights_services_parameter" {
    data_type   = "text"
    description = "services-parameter for the fastly-to-insights ecs cluster"
    name        = "fastly_to_insights_services_parameter"
    tags                               = {
        "managed_by" = "terraform"
    }
    tier        = "Standard"
    type        = "StringList"
    value       = var.awsParamStore.value
}