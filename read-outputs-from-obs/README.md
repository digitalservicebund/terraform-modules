# Read outputs from OBS

Sometimes it's necessary to share data between terraform configurations, such as VPC IDs or other identifiers.

This module allows reading data stored with the "write-outputs-to-obs" module.

Example usage:

```hcl
module "read_outputs" {
  source         = "github.com/digitalservice4germany/terraform-modules//read-outputs-from-obs?ref=fd7ec8e566448210b7e970d6640a5f436598af66"
  resource_group = "my-resource-group"
}

output "value" {
  description = "Value read from OBS bucket"
  value       = module.read.outputs.my_value
}
```
