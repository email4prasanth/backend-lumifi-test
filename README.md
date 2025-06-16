
```sh
Test-backend-lumifi/
├── .github/
│   └── workflows/
│       └── dev-backend.yml
├── acm.tf            # API Gateway cert only
├── api_gateway.tf
└── backend.tf        # Separate state for backend
├── iam.tf
├── lambda-*.tf       # All Lambda files
├── locals.tf         # Backend-specific locals
├── providers.tf
├── rds.tf
├── route53.tf        # API Gateway DNS records
├── s3.tf             # Backend/logs buckets
├── secrets.tf
├── security_groups.tf
├── vpc_endpoints.tf
├── vpc_subnet.tf
```