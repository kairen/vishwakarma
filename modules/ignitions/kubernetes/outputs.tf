output "systemd_units" {
  value = concat(
    [
      data.ignition_systemd_unit.kubeinit_configs.rendered,
      data.ignition_systemd_unit.kubelet.rendered,
    ],
    var.control_plane ? [
      data.ignition_systemd_unit.kubeinit_addons[0].rendered,
    ] : []
  )
}

output "files" {
  value = concat(
    [
      data.ignition_file.cni_plugin_tgz.rendered,
      data.ignition_file.kubernetes_env.rendered,
      data.ignition_file.init_configs_sh.rendered,
      data.ignition_file.get_host_info_sh.rendered,
      data.ignition_file.kubelet_wrapper_sh.rendered,
      data.ignition_file.kubelet_env.rendered,
      data.ignition_file.systemd_kubelet_conf.rendered,
      data.ignition_file.kubelet_config_tpl.rendered,
      data.ignition_file.sysctl_k8s_conf.rendered,
      data.ignition_file.sysctl_max_user_watches_conf.rendered,
    ],
    var.control_plane ? [
      data.ignition_file.init_addons_sh[0].rendered,
      data.ignition_file.kube_apiserver[0].rendered,
      data.ignition_file.kube_controller_manager[0].rendered,
      data.ignition_file.kube_scheduler[0].rendered,
      data.ignition_file.coredns[0].rendered,
      data.ignition_file.kube_proxy[0].rendered,
      data.ignition_file.kube_proxy_cm[0].rendered,
      data.ignition_file.bootstrap_token_secret[0].rendered,
      data.ignition_file.bootstrap_token_rbac[0].rendered,
      data.ignition_file.audit_log_policy[0].rendered,
      data.ignition_file.encryption_config[0].rendered,
    ] : [],
    var.control_plane && var.network_plugin == "amazon-vpc" ? [
      data.ignition_file.aws_vpc_cni_yaml[0].rendered,
      data.ignition_file.aws_cni_calico_yaml[0].rendered,
    ] : [],
    var.control_plane && var.network_plugin == "flannel" ? [
      data.ignition_file.flannel_yaml[0].rendered,
    ] : [],
  )
}

output "cert_files" {
  value = var.control_plane ? [
    data.ignition_file.kubernetes_ca_cert[0].rendered,
    data.ignition_file.kubernetes_ca_key[0].rendered,
    data.ignition_file.etcd_ca_cert[0].rendered,
    data.ignition_file.front_proxy_ca_cert[0].rendered,
    data.ignition_file.front_proxy_ca_key[0].rendered,
    data.ignition_file.apiserver_cert[0].rendered,
    data.ignition_file.apiserver_key[0].rendered,
    data.ignition_file.apiserver_kubelet_client_cert[0].rendered,
    data.ignition_file.apiserver_kubelet_client_key[0].rendered,
    data.ignition_file.apiserver_etcd_client_cert[0].rendered,
    data.ignition_file.apiserver_etcd_client_key[0].rendered,
    data.ignition_file.front_proxy_client_cert[0].rendered,
    data.ignition_file.front_proxy_client_key[0].rendered,
    data.ignition_file.service_account_public_key[0].rendered,
    data.ignition_file.service_account_private_key[0].rendered,
    data.ignition_file.kubelet_csr_json_tpl[0].rendered,
    data.ignition_file.ca_config_json_tpl[0].rendered,
  ] : []
}
