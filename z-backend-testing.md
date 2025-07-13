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
  --function-name dev-lumifi-processor --profile lumifitest
```
