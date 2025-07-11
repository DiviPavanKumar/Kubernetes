# -----------------------------------------
# Terraform Script to Launch a Single EC2 Instance on AWS
# with a Security Group that Allows All Traffic
# -----------------------------------------

# -----------------------------------------
# EC2 Instance Configuration
# -----------------------------------------

resource "aws_instance" "Normal_Creation_OneEC2" {
  # Amazon Machine Image ID for the EC2 instance
  # This is a static value (you can make it a variable for flexibility)
  ami = "ami-09c813fb71547fc4f"

  # Instance type defines the hardware configuration (CPU, memory)
  instance_type = "t2.medium"

  # Tags help identify and manage AWS resources
  tags = {
    Name = "Minikube"  # Name tag for easy identification in the AWS Console
  }
}

# -----------------------------------------
# Security Group Configuration (no VPC block defined)
# -----------------------------------------

resource "aws_security_group" "defaultSGnoVPC" {
  name        = "allow_all"                        # Security group name
  description = "Allow all inbound and outbound traffic"

  # Inbound rule - allows all TCP traffic from any IP address
  ingress {
    description = "Allow all inbound traffic"
    from_port   = 0                                # Allows all ports (0 means any)
    to_port     = 0
    protocol    = "tcp"                            # TCP protocol only
    cidr_blocks = ["0.0.0.0/0"]                    # Open to all IP addresses (use cautiously)
  }

  # Outbound rule - allows all traffic using all protocols
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"                             # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]                    # Open to all IPs for outbound
  }

  tags = {
    Name = "allow_all_traffic"                     # Tag for the security group
  }
}