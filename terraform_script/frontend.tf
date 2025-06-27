resource "aws_ecs_task_definition" "frontend" {
  container_definitions = jsonencode([
    {
      name  = "frontend"
      image = "123456789012.dkr.ecr.ap-south-1.amazonaws.com/frontend:<REPLACE_TAG>"
      ...
    }
  ])
}
