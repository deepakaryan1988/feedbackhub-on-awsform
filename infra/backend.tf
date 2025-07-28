# Uncomment and configure the backend for remote state storage
# terraform {
#   backend "s3" {
#     bucket         = "feedbackhub-terraform-state"
#     key            = "infrastructure/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#   }
# }

# To initialize with remote backend:
# terraform init -backend-config="bucket=your-terraform-state-bucket" \
#                -backend-config="key=infrastructure/terraform.tfstate" \
#                -backend-config="region=us-east-1" \
#                -backend-config="encrypt=true" \
#                -backend-config="dynamodb_table=terraform-state-lock" 