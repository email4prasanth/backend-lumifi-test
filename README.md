
```sh
Test-backend-lumifi/
└── backend-infra/
    ├── acm.tf
    ├── api_gateway.tf
    ├── backend.tf
    ├── iam.tf
    ├── lambda1.tf             # Module declaration
    ├── locals.tf
    ├── output.tf
    ├── providers.tf
    ├── rds.tf
    ├── route53.tf
    ├── s3.tf
    ├── secrets.tf
    ├── security_groups.tf
    ├── ses.tf
    ├── vpc_endpoints.tf
    ├── vpc_subnet.tf
└── services/
    └── lambda-1/
        ├── variables.tf
        ├── locals.tf
        └── lambda-1.tf    # Lambda resources

```