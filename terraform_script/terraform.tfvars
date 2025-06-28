//default environment values
availability_zone_1 = "ap-south-1a"
availability_zone_2 = "ap-south-1b"

frontend_image = "905418074680.dkr.ecr.ap-south-1.amazonaws.com/node-frontend:571a8dbd3c6a2230a6055dc31e10adb0ee568499"
backend_image = "905418074680.dkr.ecr.ap-south-1.amazonaws.com/flask-backend:571a8dbd3c6a2230a6055dc31e10adb0ee568499"

vpc_cidr_block            = "10.0.0.0/16"
publicSubnet1a_cidr_block = "10.0.1.0/24"
publicSubnet1b_cidr_block = "10.0.2.0/24"
