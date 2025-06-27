resource "aws_ecs_task_definition" "frontend" {
  container_definitions = jsonencode([
    {
      name  = "frontend"
      image = "123456789012.dkr.ecr.ap-south-1.amazonaws.com/frontend:fe4402d347421881545fbb9ba129cbcd5e0023d0"
      ...
    }
  ])
}
