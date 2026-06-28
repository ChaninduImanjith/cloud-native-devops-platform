resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for the EKS cluster control plane"
  vpc_id      = aws_vpc.main.id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-cluster-sg"
  }
}

resource "aws_security_group_rule" "cluster_inbound" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  to_port                  = 443
  type                     = "ingress"
}

# The worker node security group is automatically created by EKS, 
# but if custom rules are needed (e.g., NodePort access from specific IPs), 
# they can be attached to the auto-generated security group using aws_security_group_rule 
# referencing aws_eks_cluster.main.vpc_config[0].cluster_security_group_id.
