output "private_subnet_azs" {
  description = "The availability zones of the public subnets of the VPC"
  value       = aws_subnet.private[*].availability_zone
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets of the VPC"
  value       = aws_subnet.private[*].id
}

output "public_subnet_azs" {
  description = "The availability zones of the public subnets of the VPC"
  value       = aws_subnet.public[*].availability_zone
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets of the VPC"
  value       = aws_subnet.public[*].id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.this.arn
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "zurich_vpc_id" {
  description = "The ID of the Zurich (eu-central-2) DR VPC"
  value       = aws_vpc.zurich.id
}

output "zurich_vpc_arn" {
  description = "The ARN of the Zurich (eu-central-2) DR VPC"
  value       = aws_vpc.zurich.arn
}

output "zurich_public_subnet_ids" {
  description = "The IDs of the public subnets in the Zurich DR VPC"
  value       = aws_subnet.zurich_public[*].id
}

output "zurich_public_subnet_azs" {
  description = "The availability zones of the public subnets in the Zurich DR VPC"
  value       = aws_subnet.zurich_public[*].availability_zone
}

output "zurich_private_subnet_ids" {
  description = "The IDs of the private subnets in the Zurich DR VPC"
  value       = aws_subnet.zurich_private[*].id
}

output "zurich_private_subnet_azs" {
  description = "The availability zones of the private subnets in the Zurich DR VPC"
  value       = aws_subnet.zurich_private[*].availability_zone
}
