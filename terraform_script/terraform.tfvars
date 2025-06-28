//default environment values
availability_zone_1 = "ap-south-1a"
availability_zone_2 = "ap-south-1b"

frontend_image = "905418074680.dkr.ecr.ap-south-1.amazonaws.com/node-frontend:79ed9def2a5f6f91864a9ed738906c6a1341f190"
backend_image = "905418074680.dkr.ecr.ap-south-1.amazonaws.com/flask-backend:79ed9def2a5f6f91864a9ed738906c6a1341f190"

vpc_cidr_block            = "10.0.0.0/16"
publicSubnet1a_cidr_block = "10.0.1.0/24"
publicSubnet1b_cidr_block = "10.0.2.0/24"
