module "network" {
  source            = "./network"
  resource_group    = var.resource_group
  vpc_cidr          = var.vpc_cidr
  high_availability = var.high_availability
}

module "cluster" {
  source         = "./cce_cluster"
  resource_group = var.resource_group

  vpc_id    = module.network.vpc_id
  subnet_id = module.network.subnet_id

  kubernetes_version = var.kubernetes_version
  high_availability  = var.high_availability
  min_node_count     = var.min_node_count
  max_node_count     = var.max_node_count
}

module "dns" {
  source               = "./cluster_dns"
  ingress_dns_names    = var.ingress_dns_names
  loadbalancer_address = module.network.loadbalancer_address
}