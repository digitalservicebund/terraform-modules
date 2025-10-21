mock_provider "stackit" {
  mock_resource "stackit_postgresflex_instance" {
    defaults = {
      instance_id = "87778dd7-a506-45e8-9cd8-134585230603"
    }
  }

  mock_resource "stackit_postgresflex_user" {
    defaults = {
      password = "password"
    }
  }

  mock_resource "stackit_postgresflex_database" {
  }
}

# Test 1: Basic instance creation with required variables
run "basic_instance_creation" {
  command = apply

  variables {
    name           = "test-postgres"
    project_id     = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
    cpu            = 2
    memory         = 4
    engine_version = "17"
    disk_size      = 10
    acls           = ["10.0.0.0/16"]
  }

  assert {
    condition     = stackit_postgresflex_instance.this.name == "test-postgres"
    error_message = "Instance name should be 'test-postgres'"
  }

  assert {
    condition     = stackit_postgresflex_instance.this.project_id == "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
    error_message = "Project ID should match input"
  }

  assert {
    condition     = stackit_postgresflex_instance.this.flavor.cpu == 2
    error_message = "flavor CPU should match input"
  }

  assert {
    condition     = stackit_postgresflex_instance.this.flavor.ram == 4
    error_message = "flavor RAM should match input"
  }

  assert {
    condition     = stackit_postgresflex_instance.this.version == "17"
    error_message = "Version should be '17'"
  }

  assert {
    condition     = stackit_postgresflex_instance.this.storage.size == 10
    error_message = "Storage size should be 10"
  }

  assert {
    condition     = length(stackit_postgresflex_instance.this.acl) == 1
    error_message = "ACL length should match input"
  }
  assert {
    condition     = stackit_postgresflex_instance.this.acl[0] == "10.0.0.0/16"
    error_message = "ACLs should match input"
  }

  assert {
    condition     = output.address != "https"
    error_message = "The address output should be set correctly"
  }

  assert {
    condition     = nonsensitive(output.password) == "password"
    error_message = "The password should be available as output"
  }

  assert {
    condition     = output.username == "test-postgres"
    error_message = "The username should be similar to the instance name"
  }

  assert {
    condition     = stackit_postgresflex_database.database.name == "test-postgres"
    error_message = "The database name should be similar to the instance name"
  }

  assert {
    condition     = stackit_postgresflex_database.database.owner == stackit_postgresflex_user.user.username
    error_message = "The database owner should be the user created by this module "
  }
}
