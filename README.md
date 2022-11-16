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

- Enable ipv4 systctls (required for wireguard)

Edit the k3s config

```sh
sudo vi /etc/systemd/system/k3s.service
```

Add this line under `ExecStart`

```
'--kubelet-arg=allowed-unsafe-sysctls=net.ipv4.*' \
```

Restart k3s

```sh
sudo systemctl daemon-reload
sudo systemctl restart k3s.service
```