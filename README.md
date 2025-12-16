# terraform-modules

This repository contains a collection of Terraform modules we use in our infrastructure.

When developing modules for the OpenTelekomCloud, this repository can serve as useful inspiration: https://github.com/iits-consulting/terraform-opentelekomcloud-project-factory/tree/master/modules


# terraform-docs

When developing our modules for STACKIT, please ensure to also use `terraform-docs` to autogenerate additional documentation for each module.

Follow the installation guidelines for [terraform-docs](https://github.com/terraform-docs/terraform-docs), which support `brew`, `docker`, `precommit-hooks` and others. There are also plugins for `asdf` or `mise`.

To run the tooling:

```
terraform-docs markdown table --hide-empty=true --indent 2 --output-file README.md stackit-<module>
```

# Tests

Each STACKIT module now also has basic tests to verify the behaviour of our infrastructure-as-code.
When making changes, ensure the tests are still passing and extend them if necessary.

```
cd <module>
terraform init
terraform test
```