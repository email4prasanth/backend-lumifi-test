- Check API Gateway Connectivity
```sh
# Verify API is deployed
aws apigatewayv2 get-apis `
  --profile lumifitest `
  --query "Items[*].{Name:Name, ApiId:ApiId, ProtocolType:ProtocolType}" `
  --output table

aws apigatewayv2 get-apis --query "Items[?Name=='dev-lumifi-processor-api']" --profile lumifitest
curl -I https://api.aitechlearn.xyz
```
- Expected: 200 OK or 5xx error (since Lambda is dummy)
- Validate:
    - TLS certificate validity
    - DNS resolution
    - API Gateway integration