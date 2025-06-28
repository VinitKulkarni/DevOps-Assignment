//default environment values
availability_zone_1 = "ap-south-1a"
availability_zone_2 = "ap-south-1b"

frontend_image = "905418074680.dkr.ecr.ap-south-1.amazonaws.com/node-frontend:b710ab2e4c9722ed1ee4fbe0632e4808ae7a65b6"
backend_image = "905418074680.dkr.ecr.ap-south-1.amazonaws.com/flask-backend:b710ab2e4c9722ed1ee4fbe0632e4808ae7a65b6"

vpc_cidr_block            = "10.0.0.0/16"
publicSubnet1a_cidr_block = "10.0.1.0/24"
publicSubnet1b_cidr_block = "10.0.2.0/24"
