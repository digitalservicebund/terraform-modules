# Write outputs to OBS

Sometimes it's necessary to share data between terraform configurations, such as VPC IDs or other identifiers.

This module allows storing arbitrary data in an encrypted OBS object.

Example usage:

```hcl
module "write_outputs" {
  source         = "../terraform-modules/write-outputs-to-obs"
  resource_group = "my-resource-group"
  outputs        = {
    my_value = "abc"
  }
}
```
