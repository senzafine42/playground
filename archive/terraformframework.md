	• Security group - how restrictive?
		○ least privilege was mentioned but sounds like we might be leaning towards a more open sg?
		○ Are there groups of applications that could be grouped together?
			§ web
			§ app
			§ db
		○ outbound requirements
	• Subnets?
		○ public
		○ private
	• Instance Types
		○ Start with some T3 Large and customize as they install applications?
		○ AWS Migration Evaluator could assist with this
	• What AMI's? 
		○ Are we building golden images are using AWS provided?
			§ Linux
			§ Versions?
			§ Unknown servers
			§ baked in software
				□ SSM
				□ CloudWatch
		○ Windows
			§ Server 2022?
			§ Unknown Servers?
			§ baked in software
				□ SSM
				□ CloudWatch
	• IAM Roles
	• Instance disk size
		○ Can/should we optimize?
	• Domain join
		○ Use SSM Automation AWS-JoinDirectoryServiceDomain (Managed AD/AD Connector) or domain join in Image Builder. Keep OU path and domain join creds in SecureString.
	• Key pair
		○ Is it required?
		○ same or divided between applications
		○ Password rotation via AWS?
		○ Will these server be managed by multiple groups or need individual Key Pairs or stick to SSM
	• Networking
	• Tagging
		○ Environment
		○ Sector
		○ Silo
		○ Application stack
		○ Tier
			§ Example
			§ Key	Value
				
			Project	Control Tower
			Environment	Development
			CostCenter	DevOps
			Module	terraform-aws-vpc
			managed_by	AFT
			Name	network-vpc-nat-1
			

aws-ec2-basic/
|── main.tf
|── variables.tf
|── outputs.tf
|── provider.tf
|── version.tf
└── terraform.tfvars

#####
terraform/
├── modules/
│   ├── ec2-instance/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── vpc/
│   ├── s3/
│   └── iam-role/
│
├── envs/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── qa/
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   └── prod/
│       ├── main.tf
│       ├── terraform.tfvars
│       └── backend.tf
│
└── global/
    ├── provider.tf
    └── versions.tf


