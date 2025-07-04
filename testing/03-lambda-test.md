- Test Lambda Execution
```sh
# List all Lambda functions in us-east-1
aws lambda list-functions --region us-east-1 --query 'Functions[].FunctionName' --profile lumifitest
```
### Option-1 Let AWS CLI Handle Encoding (Recommended)
```sh
aws lambda invoke `
  --profile lumifitest `
  --region us-east-1 `
  --function-name dev-lumifi-processor `
  --cli-binary-format raw-in-base64-out `
  --payload '{"test": "event"}' `
  response.json
```
### Option-2 Use a File Instead of Inline Payload
```sh
echo '{"test": "event"}' > payload.json
Test-Path .\payload.json
Get-Content .\payload.json
aws lambda invoke `
  --profile lumifitest `
  --region us-east-1 `
  --function-name dev-lumifi-processor `
  --payload fileb://payload.json `
  response.json
```
#### output Delete the file
```sh
Remove-Item .\payload.json
```

- - Run the following command
`aws apigatewayv2 get-apis --profile lumifitest`
- Copy the ApiEndpoint
```sh
https://t2do2br6b3.execute-api.us-east-1.amazonaws.com
```

# Test Lambda-1 endpoint
$url1 = "https://t2do2br6b3.execute-api.us-east-1.amazonaws.com/test"
Invoke-RestMethod -Uri $url1 -Method Get
Remove-Variable url1

