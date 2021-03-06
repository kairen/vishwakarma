<!-- DO NOT EDIT. THIS FILE IS GENERATED BY THE MAKEFILE. -->
# Terraform variables
This document gives an overview of variables used in the Ignition of the kubeconfig module.
## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| certificates | The kubernetes certificates. | `map(string)` | <pre>{<br>  "ca_cert": "",<br>  "client_cert": "",<br>  "client_cert_path": "",<br>  "client_key": "",<br>  "client_key_path": "",<br>  "token": ""<br>}</pre> |
| cluster | Name of the cluster. | `string` | `"kubernetes"` |
| config\_path | (Required) The path of kubeconfig. | `string` | `"/etc/kubernetes/admin.conf"` |
| content | The content of the kubeconfig file. | `string` | `""` |
| context | (Required) Name of the context. | `string` | `"kubernetes-admin@kubernetes"` |
| endpoint | (Required) The endpoint of Kubernetes API server. | `string` | `"https://127.0.0.1:6443"` |
| user | (Required) Name of the user. | `string` | `"kubernetes-admin"` |

## Outputs

| Name | Description |
|------|-------------|
| content | n/a |
| files | n/a |

