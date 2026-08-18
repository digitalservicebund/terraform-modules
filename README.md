# terraform-modules

This repository contains a collection of Terraform modules we use in our infrastructure.

# Commit Messages

Please use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for commit messages and PR titles — our versioning is derived from them.

```
fix(stackit-object-storage): correct bucket policy attachment   -> patch
feat(stackit-postgres-db): add configurable backup schedule     -> minor
feat(stackit-state-bucket)!: rename bucket_name variable        -> major
```

Use the module directory as scope. 

It's recommended to squash and merge. Therefore, the PR title must follow the convention as well.

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
