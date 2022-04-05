# Deploy Key

**Caution: the Terraform state contains the private deploy SSH key in cleartext.**

When saving state in an S3 backend make sure to use encryption at rest. When saving state in GitHub itself use [git-crypt](https://www.agwa.name/projects/git-crypt/) or similar.
