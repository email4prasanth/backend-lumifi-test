- Test the current region 
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