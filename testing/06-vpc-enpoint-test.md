6. VPC Endpoint Validation
```sh
aws ec2 describe-vpc-endpoints `
  --query 'VpcEndpoints[].ServiceName' --profile lumifitest
```
- Check: Both s3 and secretsmanager endpoints show as available