output "proxy_endpoint" {
  description = "Endpoint of the created proxy"
  value       = aws_db_proxy.proxy.endpoint
}
