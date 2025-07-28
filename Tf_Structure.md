
```sh
lumifi-backend/
└── backend-infra/
    ├── backend.tf
    ├── iam.tf
    ├── locals.tf
    ├── providers.tf
    ├── rds.tf
    ├── s3.tf
    ├── secrets.tf
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