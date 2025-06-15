### Create bucket to store Terraform files
aws s3api create-bucket --bucket lumifitfstore --region us-east-1 --profile lumifitest

### Delete bucket
aws s3 ls --profile lumifitest
aws s3 rm s3://lumifitfstore --recursive --region us-east-1 --profile lumifitest
aws s3api delete-bucket --bucket lumifitfstore --region us-east-1 --profile lumifitest

## Terraform workspace create
```sh
terraform init 
terraform workspace new dev
terraform fmt
terraform validate
terraform plan
terraform apply --auto-approve
terraform state list
terraform output
terraform destroy --auto-approve

0. Test the current region 
```sh
aws configure get region --profile lumifitest
aws sts get-caller-identity --profile lumifitest
# Validate Subnets
aws ec2 describe-subnets `
  --query "Subnets[*].{SubnetId:SubnetId, VpcId:VpcId, AZ:AvailabilityZone, CIDR:CidrBlock, Public:MapPublicIpOnLaunch}" `
  --output table `
  --profile lumifitest `
  --region us-east-1
```
1. Check API Gateway Connectivity
```sh
# Verify API is deployed
aws apigatewayv2 get-apis `
  --profile lumifitest `
  --query "Items[*].{Name:Name, ApiId:ApiId, ProtocolType:ProtocolType}" `
  --output table

aws apigatewayv2 get-apis --query "Items[?Name=='lumifi-dev-processor-api']" --profile lumifitest
curl -I https://api.aitechlearn.xyz
```
- Expected: 200 OK or 5xx error (since Lambda is dummy)
- Validate:
    - TLS certificate validity
    - DNS resolution
    - API Gateway integration
2. Test Lambda Execution
```sh
# List all Lambda functions in us-east-1
aws lambda list-functions --region us-east-1 --query 'Functions[].FunctionName' --profile lumifitest
```
### Option-1 Let AWS CLI Handle Encoding (Recommended)
```sh
aws lambda invoke `
  --profile lumifitest `
  --region us-east-1 `
  --function-name lumifi-dev-processor `
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
  --function-name lumifi-dev-processor `
  --payload fileb://payload.json `
  response.json
```
#### output Delete the file
```sh
Remove-Item .\payload.json
```
3. Check Secret Manager Access
```sh
# List Secrets
aws secretsmanager list-secrets --query 'SecretList[*].Name' --output table --profile lumifitest --region us-east-1
```
### Get Secret Value (JSON output)
```sh
aws secretsmanager get-secret-value `
   --secret-id dev-lumifi-rds_credentials-backend-v1 `
   --query SecretString `
   --output text --profile lumifitest `
   --region us-east-1
```
#### output (copy endpoint and save it)
{"db_name":"dev_lumifi","endpoint":"dev-lumifi-db.cl6kqegew8vq.ap-south-1.rds.amazonaws.com:5432","engine":"postgres","password":"hiBAP5CG9lOqhNh1","port":5432,"username":"dbadmin"}
- Validate:
    - Secret exists
    - Contains expected keys (username, password, etc.)
    - IAM permissions are correct
### Force deleting secret manager
```sh
aws secretsmanager list-secrets --query 'SecretList[*].Name' --output table --profile lumifitest --region us-east-1
aws secretsmanager delete-secret --secret-id dev-lumifi-rds_credentials-backend-v1 --force-delete-without-recovery --profile lumifitest
```
4. Verify Database Connectivity
```sh
# Check DB deployment AZ, Class, DBInstanceIdentifier,	Engine,	Status,	MultiAZ
aws rds describe-db-instances `
  --query "DBInstances[*].{DBInstanceIdentifier:DBInstanceIdentifier, Engine:Engine, Status:DBInstanceStatus, MultiAZ:MultiAZ, Class:DBInstanceClass, AZ:AvailabilityZone}" `
  --output table `
  --profile lumifitest `
  --region us-east-1
```
#### output
-------------------------------------------
|           DescribeDBInstances           |
+-----------------------+-----------------+
|  AZ                   |  us-east-1b     |
|  Class                |  db.t3.micro    |
|  DBInstanceIdentifier |  dev-lumifi-db  |
|  Engine               |  postgres       |
|  MultiAZ              |  False          |
|  Status               |  available      |
+-----------------------+-----------------+
# Get RDS endpoint form Secrets > dev-lumifi-rds_credentials-backend-v1 Test connectivity
```
Test-NetConnection dev-lumifi-db.cxkiky6us81t.us-east-1.rds.amazonaws.com -Port 5432
```
#### output
- Connection succeeded message
    - ComputerName     : dev-lumifi-db.cl6kqegew8vq.ap-south-1.rds.amazonaws.com
    - RemoteAddress    : 3.111.20.16
    - RemotePort       : 5432
    - InterfaceAlias   : Wi-Fi
    - SourceAddress    : 192.168.1.3
    - TcpTestSucceeded : True

5. Test S3 Access
```sh
echo "test" > test.txt
aws s3 cp test.txt s3://lumifi-dev-backend/ --profile lumifitest
aws s3 ls s3://lumifi-dev-backend/ --profile lumifitest
aws s3 rm s3://lumifi-dev-backend/ --recursive --region us-east-1 --profile lumifitest
```
- Validate: File appears in bucket
6. VPC Endpoint Validation
```sh
aws ec2 describe-vpc-endpoints `
  --query 'VpcEndpoints[].ServiceName' --profile lumifitest
```
- Check: Both s3 and secretsmanager endpoints show as available
7. Security Group Tests
```sh
aws ec2 describe-security-groups `
  --region us-east-1 `
  --profile lumifitest `
  --query "SecurityGroups[*].{GroupName:GroupName, GroupId:GroupId}" `
  --output table

# Check Lambda SG egress CIDR, From, GroupID, Protocol, RuleID, To, Type 
aws ec2 describe-security-group-rules `
  --region us-east-1 `
  --profile lumifitest `
  --output table `
  --query "SecurityGroupRules[*].{RuleID:SecurityGroupRuleId,GroupID:GroupId,Type:Type,Protocol:IpProtocol,From:FromPort,To:ToPort,CIDR:CIDR}"


aws ec2 describe-security-group-rules `
  --filter Name="group-name",Values="dev-lambda-sg" `
  --query "SecurityGroupRules[?IsEgress == \`true\`]" --profile lumifitest
```
8. IAM
```sh
aws iam list-roles `
  --query "Roles[*].RoleName" `
  --output table `
  --profile lumifitest
aws iam get-role --role-name lumifi-dev-lambda-exec-role --profile lumifitest
```

### Troubleshooting Checklist
1. Certificate Issues: (not working)
```sh
    aws acm describe-certificate `
    --certificate-arn $(terraform output -raw api_cert_arn) `
    --query "Certificate.Status" --profile lumifitest
```
2. Lambda Permissions:
```sh
aws lambda get-policy `
  --function-name lumifi-dev-processor --profile lumifitest
```
