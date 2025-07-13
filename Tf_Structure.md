
```sh
lumifi-backend/
└── backend-infra/
    ├── api_gateway_serverless.tf
    ├── api_gateway.tf
    ├── backend.tf
    ├── iam.tf
    ├── lambda1.tf             # Module declaration
    ├── locals.tf
    ├── providers.tf
    ├── rds.tf
    ├── s3.tf
    ├── secrets.tf
    ├── security_groups.tf
    ├── serverlessLambda.tf
    ├── ses.tf
    ├── vpc_endpoints.tf
    ├── vpc_subnet.tf
└── services/
    └── lambda-1/
        └── lambda-1.tf    # Lambda resources
        ├── locals.tf
        ├── package.json
        ├── variables.tf
└── src
```