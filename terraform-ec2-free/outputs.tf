output "live_application_url" {
  description = "The public URL to access the React Frontend"
  value       = "http://${aws_instance.app_server.public_ip}:3000"
}

output "backend_api_url" {
  description = "The public URL to access the Node.js Backend API"
  value       = "http://${aws_instance.app_server.public_ip}:5000"
}

output "ssh_command" {
  description = "Command to SSH into the server"
  value       = "ssh -i cloud-native-free-key.pem ubuntu@${aws_instance.app_server.public_ip}"
}
