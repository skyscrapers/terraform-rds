output "proxy_endpoint" {
  description = "Endpoint of the created proxy"
  value       = aws_db_proxy.proxy.endpoint
}
output "proxy_reader_endpoint" {
  description = "Reader endpoint of the created proxy"
  value       = length(aws_db_proxy_endpoint.proxy_reader_endpoint) > 0 ? aws_db_proxy_endpoint.proxy_reader_endpoint[0].endpoint : ""
}
