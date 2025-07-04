- Test S3 Access
```sh
echo "test" > test.txt
aws s3 cp test.txt s3://lumifi-dev-backend/ --profile lumifitest
aws s3 ls s3://lumifi-dev-backend/ --profile lumifitest
aws s3 rm s3://lumifi-dev-backend/ --recursive --region us-east-1 --profile lumifitest