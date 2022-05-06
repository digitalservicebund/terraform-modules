# Write outputs to OBS

Sometimes it's necessary to share data between terraform configurations, such as VPC IDs or other identifiers.

This module allows storing arbitrary data in an encrypted OBS object.

Example usage:

```hcl
module "write_outputs" {
  source         = "github.com/digitalservice4germany/terraform-modules//write-outputs-to-obs?ref=fd7ec8e566448210b7e970d6640a5f436598af66"
  resource_group = "my-resource-group"
  outputs        = {
    my_value = "abc"
  }
}
```
