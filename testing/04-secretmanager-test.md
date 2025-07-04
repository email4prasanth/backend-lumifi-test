- Check Secret Manager Access
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