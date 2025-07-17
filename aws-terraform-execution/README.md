# Terraform Execution Module

Module to set up the trust relationship between GitHub Actions and AWS, allowing Terraform to execute in the AWS
environment. To ensure you are running terraform locally and in GitHub Actions with the same permissions, you add the
`assume_role` block to your aws provider configuration.
The role created is allowed to be assumed by itself and by the SSO role specified in the `sso_role_arn` input.

Additionally, the role has an explicit deny policy that prevents it from adjusting its own permissions.

Example Usage:

```hcl
data "aws_iam_roles" "admin" {
  name_regex  = "AWSReservedSSO_AWSAdministratorAccess.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

module "terraform_execution" {
  source                     = "github.com/digitalservicebund/terraform-modules//aws-terraform-execution?ref=b3c63d88deb0a46502a1990ddb1c5bc35d9da514"
  github_repository_name     = "digitalservicebund/<your-repo-name>"
  terraform_execution_policy = data.aws_iam_policy_document.terraform_policy_document.json
  sso_role_arn               = tolist(data.aws_iam_roles.admin.arns)[0]
}

data "aws_iam_policy_document" "terraform_policy_document" {

  # Add all permissions that are needed to execute terraform. E.g.:
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = ["*"]
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.97 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.97 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.github_oidc_provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.terraform_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.terraform_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.terraform_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.combined_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.combined_trust_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.github_trust_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.self_control](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trust_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_repository_name"></a> [github\_repository\_name](#input\_github\_repository\_name) | Name of the repository, including the organization identifier. E.g. digitalservicebund/terraform-modules | `string` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of the IAM role that is used to execute terraform in Github Actions. | `string` | `"terraform-execution"` | no |
| <a name="input_sso_role_arn"></a> [sso\_role\_arn](#input\_sso\_role\_arn) | The ARN of the AWS SSO role that should be allowed to assume this role. | `string` | `null` | no |
| <a name="input_terraform_execution_policy"></a> [terraform\_execution\_policy](#input\_terraform\_execution\_policy) | IAM policy to execute terraform in json format | `string` | n/a | yes |
<!-- END_TF_DOCS -->
