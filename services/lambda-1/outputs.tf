output "lambda_function_invoke_arn" {
  value = aws_lambda_function.data_processor.invoke_arn
}

output "lambda_function_name" {
  value = aws_lambda_function.data_processor.function_name
}
