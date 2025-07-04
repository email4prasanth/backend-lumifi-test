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


```