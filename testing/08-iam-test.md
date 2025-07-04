- IAM
```sh
aws iam list-roles `
  --query "Roles[*].RoleName" `
  --output table `
  --profile lumifitest
aws iam get-role --role-name lumifi-dev-lambda-exec-role --profile lumifitest
```