output "source_region_sns_topic_arn" {
  description = "SNS topic ARN for the lambdas in the source region"
  value       = aws_sns_topic.source_region_topic.arn
}

output "target_region_sns_topic_arn" {
  description = "SNS topic ARN for the lambdas in the target region"
  value       = aws_sns_topic.target_region_topic.arn
}
