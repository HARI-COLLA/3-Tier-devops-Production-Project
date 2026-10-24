output "jenkins_server_public_ip" {
  description = "Public IP of the Jenkins EC2 Instance"
  value       = aws_instance.ec2.public_ip
}

output "jenkins_url" {
  description = "Jenkins Web UI URL"
  value       = "http://${aws_instance.ec2.public_ip}:8080"
}

output "sonarqube_url" {
  description = "SonarQube Web UI URL"
  value       = "http://${aws_instance.ec2.public_ip}:9000"
}
