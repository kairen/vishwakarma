locals {
  cluster_dns_ip = cidrhost(var.service_network_cidr, 10)
}

module "ignition_docker" {
  source = "../../ignitions/docker"
}

module "ignition_locksmithd" {
  source          = "../../ignitions/locksmithd"
  reboot_strategy = var.reboot_strategy
}

module "ignition_update_ca_certificates" {
  source = "../../ignitions/update-ca-certificates"
}

data "aws_s3_bucket_object" "bootstrapping_kubeconfig" {
  bucket = var.s3_bucket
  key    = "bootstrap-kubelet.conf"
}

module "ignition_bootstrapping_kubeconfig" {
  source = "../../ignitions/kubeconfig"

  config_path = "/etc/kubernetes/bootstrap-kubelet.conf"
  content     = data.aws_s3_bucket_object.bootstrapping_kubeconfig.body
}

module "ignition_kubernetes" {
  source = "../../ignitions/kubernetes"

  control_plane        = false
  binaries             = var.binaries
  containers           = var.containers
  service_network_cidr = var.service_network_cidr
  network_plugin       = var.network_plugin

  kubelet_config = var.kubelet_config

  kubelet_flags = merge(var.kubelet_flags, {
    node-labels          = join(",", var.kubelet_node_labels)
    register-with-taints = join(",", var.kubelet_node_taints)
  })

  cloud_config = {
    provider = "aws"
    path     = ""
  }
}

data "ignition_config" "main" {
  files = compact(concat(
    module.ignition_docker.files,
    module.ignition_locksmithd.files,
    module.ignition_update_ca_certificates.files,
    module.ignition_bootstrapping_kubeconfig.files,
    module.ignition_kubernetes.files,
    module.ignition_kubernetes.cert_files,
    var.extra_ignition_file_ids,
  ))

  systemd = compact(concat(
    module.ignition_docker.systemd_units,
    module.ignition_locksmithd.systemd_units,
    module.ignition_update_ca_certificates.systemd_units,
    module.ignition_kubernetes.systemd_units,
    var.extra_ignition_systemd_unit_ids,
  ))
}

resource "aws_s3_bucket_object" "ignition" {
  bucket  = var.s3_bucket
  key     = "ign-worker-${local.instance_config["name"]}.json"
  content = data.ignition_config.main.rendered
  acl     = "private"

  server_side_encryption = "AES256"

  tags = merge(var.extra_tags, map(
    "Name", "ign-worker-${local.instance_config["name"]}.json",
    "kubernetes.io/cluster/${var.name}", "owned",
    "Role", "k8s-worker"
  ))
}

data "ignition_config" "s3" {
  replace {
    source       = format("s3://%s/%s", var.s3_bucket, aws_s3_bucket_object.ignition.key)
    verification = "sha512-${sha512(data.ignition_config.main.rendered)}"
  }
}
