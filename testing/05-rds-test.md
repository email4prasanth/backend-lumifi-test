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
