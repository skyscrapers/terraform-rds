resource "aws_sns_topic" "source_region_topic" {
  provider = aws.source
  name     = local.setup_name
}

resource "aws_sns_topic" "target_region_topic" {
  provider = aws.intermediate
  name     = local.setup_name
}

module "step_1_lambda_monitoring" {
  source          = "github.com/skyscrapers/terraform-cloudwatch//lambda_function?ref=2.0.0"
  lambda_function = aws_lambda_function.step_1.function_name
  sns_topic_arn   = aws_sns_topic.source_region_topic.arn

  providers = {
    aws = aws.source
  }
}

module "step_2_lambda_monitoring" {
  source          = "github.com/skyscrapers/terraform-cloudwatch//lambda_function?ref=2.0.0"
  lambda_function = aws_lambda_function.step_2.function_name
  sns_topic_arn   = aws_sns_topic.source_region_topic.arn

  providers = {
    aws = aws.source
  }
}

module "step_3_lambda_monitoring" {
  source          = "github.com/skyscrapers/terraform-cloudwatch//lambda_function?ref=2.0.0"
  lambda_function = aws_lambda_function.step_3.function_name
  sns_topic_arn   = aws_sns_topic.target_region_topic.arn

  providers = {
    aws = aws.intermediate
  }
}

module "step_4_lambda_monitoring" {
  source          = "github.com/skyscrapers/terraform-cloudwatch//lambda_function?ref=2.0.0"
  lambda_function = aws_lambda_function.step_4.function_name
  sns_topic_arn   = aws_sns_topic.target_region_topic.arn

  providers = {
    aws = aws.target
  }
}

module "cleanup_snapshots_lambda_monitoring" {
  source          = "github.com/skyscrapers/terraform-cloudwatch//lambda_function?ref=2.0.0"
  lambda_function = aws_lambda_function.cleanup_snapshots.function_name
  sns_topic_arn   = aws_sns_topic.target_region_topic.arn

  providers = {
    aws = aws.target
  }
}
