
```sh
```sh
test-backend-lumifi/
└── backend-infra/
    ├── backend.tf
    ├── iam.tf
    ├── kms.tf
    ├── locals.tf
    ├── outputs.tf
    ├── providers.tf
    ├── public_rds.tf
    ├── public_secrets.tf
    ├── public_sg.tf
    ├── pvt_rds.tf
    ├── pvt_secrets.tf
    ├── pvt_sg.tf
    ├── pvt_subnet.tf
    ├── rds_password.tf
    ├── s3.tf
    ├── security_groups.tf
    ├── ses.tf
    ├── vpc_endpoints.tf
    ├── vpc_subnet.tf
└── src/                    # Application source code
│   ├── test/               # Test source code
│   ├── lib/                # Database & shared logic
│   ├── middlewares/        # Middlewares
│   ├── models/             # Sequelize models
│   ├── schemas/            # Zod schemas
│   ├── services/           # Business logic
│   ├── types/              # TypeScript interfaces
│   ├── handler/            # Route handlers
│   └── types/              # TypeScript interfaces

├── serverless.yml          # Serverless deployment configuration
├── package.json            # Project metadata & scripts
├── tsconfig.json           # TypeScript compiler options
├── README.md               # Project documentation
└── other config files...   # Other configuration files
```
aws secretsmanager delete-secret `
    --secret-id dev-lumifitest-rds-credentials-be `
    --force-delete-without-recovery `
    --region us-east-1

aws secretsmanager delete-secret `
    --secret-id prod-lumifitest-rds-credentials-be-pvt `
    --force-delete-without-recovery `
    --region us-east-1

- branch `feature/sls-dbconnect` is not connected to rds it contains both public and pvt subnets
- check ammie, chatgpt ngix server
https://chatgpt.com/c/68ef6e3c-8090-8323-8e12-02dcabae6b75
