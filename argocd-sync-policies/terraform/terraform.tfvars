# update the correct values before apply
username              = "admin"
password              = "PASTE_HERE"
server_addr           = "127.0.0.1:62907"
namespace             = "argocd"
repo_url              = "https://github.com/naavveenn/argocd.git"
path                  = "argocd-application/helm/nginx"
target_revision       = "main"
values_files          = ["../../app/dev/service/demo/custom-values.yaml"]
destination_namespace = "terraform"
destination_server    = "https://kubernetes.default.svc"
insecure              = true
prune_enabled         = true
selfheal_enabled      = true
sync_options          = ["CreateNamespace=true", "FailOnSharedResource=true"]
namespace_metadata_labels = {
  created_by     = "Terraform"
}
