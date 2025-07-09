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
-  Expected output
{
    "StatusCode": 200,
    "ExecutedVersion": "$LATEST"
}

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

- Run the following command
`aws apigatewayv2 get-apis --profile lumifitest`
- Copy the ApiEndpoint
```sh
https://furhn3ptzg.execute-api.us-east-1.amazonaws.com
```

# Test Lambda-1 endpoint
$url1 = "https://furhn3ptzg.execute-api.us-east-1.amazonaws.com"
Invoke-RestMethod -Uri $url1 -Method Get
- message
-------
Hello from Lambda-1!

Remove-Variable url1

### create zip file
Compress-Archive -Path "services\lambda-1\*" -DestinationPath "services\lambda-1\lambda-1.zip" -Force


