# Datahoarder Terraform

1) ⚙️ Configure `terraform.tfvars`
2) 🔧 Run `terraform apply`
3) 💾 Start [hoarding](https://www.youtube.com/watch?v=up863eQKGUI&t=51s)

## Pre-requisites

- Install [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- Install K3s with [k3sup](https://github.com/alexellis/k3sup#download-k3sup-tldr)

```sh
curl -sLS https://get.k3sup.dev | sh
sudo install k3sup /usr/local/bin/
k3sup install --local --local-path ~/.kube/config
```

Edit the `ExecStart` in the k3s config to enable sysctls for wireguard

```sh
sudo vi /etc/systemd/system/k3s.service
```

```
'--kubelet-arg=allowed-unsafe-sysctls=net.ipv4.conf.all.src_valid_mark' \
```

Then restart the service

```sh
sudo systemctl daemon-reload
sudo systemctl restart k3s.service
```

Test your cluster with

```sh
export KUBECONFIG=/home/chris/.kube/config
kubectl config use-context default
kubectl get node -o wide
```

/usr/local/bin/k3s-killall.sh
