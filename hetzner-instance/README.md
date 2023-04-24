# KPI Dashboard Stack on Hetzner

This stack builds up a stack consisting of the following services:

- Metabase (Visualization)
- NocoDB (Data Management)
- N8N (Automation)

## Tooling

- Terraform is used to provision the instance on Hetzner
- Docker will be installed on the instance
- stack credentials come from 1password
- The KPI Stack is deployed with docker compose, the following things are part of the compose file
  - PostegreSQL
  - Autoheal (monitors and restarts containers)
  - Traefik (proxy to the public services)
  - Metabase
  - NocoDB
  - n8n

## Access

In order to use the module, you need to create an API Access token for Hetzner
