Here’s a tidy, reusable Terraform module that:

- lets you choose the AWS region (via a provider you pass in),
- builds the bucket name as: <base>-<region>-<6-digit number>,
- zero-pads the random number and makes the minimum 000042.

Module layout
modules/
└── s3/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
