resource "aws_lambda_function" "data_processor" {
  function_name = "${terraform.workspace}-lumifi-processor"
  role          = var.lambda_role_arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  # filename      = "${path.module}/lambda-1.zip"
  filename      = "${path.module}/lambda-1.zip"
  # source_code_hash = filebase64sha256("${path.root}/lambda-1.zip") # Add this line

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }

  environment {
    variables = {
      S3_BUCKET = var.backend_bucket
      ENVIRONMENT = terraform.workspace
      SERVICE_NAME = "data-processor"
    }
  }

  tags = local.tags
}

# # API Gateway Integration
# resource "aws_apigatewayv2_integration" "lambda1_integration" {
#   api_id           = var.api_gateway_id
#   integration_type = "AWS_PROXY"
#   integration_uri  = aws_lambda_function.data_processor.invoke_arn
# }

# resource "aws_apigatewayv2_route" "lambda1_route" {
#   api_id    = var.api_gateway_id
#   route_key = "ANY /{proxy+}"
#   target    = "integrations/${aws_apigatewayv2_integration.lambda1_integration.id}"
# }

exports.handler = async (event) => {
  console.log('Received event:', JSON.stringify(event, null, 2));
  
  // Use event.rawPath instead of event.requestContext.http.path
  if (event.rawPath.startsWith('/test')) {
    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
        "Cache-Control": "no-cache, no-store, must-revalidate"
      },
      body: JSON.stringify({ message: "Testing Lumifi Backend!!!!!" }),
    };
  }

  return {
    statusCode: 404,
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ error: "Endpoint not found" }),
  };
};