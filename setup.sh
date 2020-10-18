#!/usr/bin/env bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
user_bin_dir=~/.local/bin

install_pritunl() {
  sudo tee /etc/apt/sources.list.d/pritunl.list <<< "deb https://repo.pritunl.com/stable/apt $(lsb_release -c -s) main"

  curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x7568D9BB55FF9E5287D586017AE645C0CF8E292A" | sudo apt-key add
  sudo apt-get update
  sudo apt-get install -y pritunl-client-electron
}

install_gcloud() {
  local tmp_dir script_path install_dir
  install_dir=/opt/google-cloud-sdk
  if [[ ! -e $install_dir ]]; then
    tmp_dir=$(mktemp -d)
    script_path=$tmp_dir/install.sh
    curl -o "$script_path" -sL https://sdk.cloud.google.com
    sudo bash "$script_path" --disable-prompts --install-dir=/opt/
    gcloud init
    gcloud auth application-default login
  fi
  sudo ln -s -f "$install_dir/bin/"* /usr/local/bin/
  ln -s -f "$install_dir/completion.bash.inc" ~/.bash_completion.d/
}

install_kubectl() {
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  sudo tee -a /etc/apt/sources.list.d/kubernetes.list <<< 'deb https://apt.kubernetes.io/ kubernetes-xenial main'
  sudo apt-get update
  sudo apt-get install -y kubectl
  kubectl completion bash > ~/.bash_completion.d/kubectl.bash
}

install_kubectx() {
  local src_dir=~/workspace/kubectx
  if [[ ! -e $src_dir ]]; then
    git clone https://github.com/ahmetb/kubectx.git "$src_dir"
  fi
  ln -s -f "$src_dir"/{kubectx,kubens} "$user_bin_dir/"
  ln -s -f "$src_dir/completion"/*.bash ~/.bash_completion.d/
}

setup_gke() {
  local user=adrian
  local dev_project=render-devs
  local staging_project=render-internal
  local prod_project=render-prod

  local dev_cluster_zone
  dev_cluster_zone=$(gcloud container clusters list --project "$dev_project" --filter=name="$user" --format=json | jq '.[0].zone' -r)
  gcloud container clusters get-credentials --project "$dev_project" --zone "$dev_cluster_zone" "$user"

  local staging_cluster_zone
  staging_cluster_zone=$(gcloud container clusters list --project "$staging_project" --filter=name=staging --format=json | jq '.[0].zone' -r)
  gcloud container clusters get-credentials --project "$staging_project" --zone "$staging_cluster_zone" staging

  local cluster_details prod_cluster_name prod_cluster_zone
  gcloud container clusters list --project "$prod_project" --format=json | jq 'map({name:.name,zone:.zone})[]' -c \
    | while IFS='' read -r cluster_details; do
      prod_cluster_name=$(jq .name -r <<< "$cluster_details")
      prod_cluster_zone=$(jq .zone -r <<< "$cluster_details")
      gcloud container clusters get-credentials --project "$prod_project" --zone "$prod_cluster_zone" "$prod_cluster_name"
    done
}

install_vault() {
  local install_dir tmp_dir download_url archive_path
  install_dir=/opt/hashicorp
  if sha512sum -c <<< "96448092d63c216fa1061bab4d383cf3a08ae3c1c972f89f96e7717db6ab9d2a8055bb2732a0ff352c78b1f5a5f7b7e8d855ebef521fa105912c1895fbc9a9d1  /opt/hashicorp/vault"; then
    return
  fi
  sudo mkdir -p "$install_dir"

  tmp_dir=$(mktemp -d)
  download_url=https://releases.hashicorp.com/vault/1.4.1/vault_1.4.1_linux_amd64.zip
  archive_path=$tmp_dir/$(basename "$download_url")
  curl --fail -o "$archive_path" "$download_url"
  sha512sum -c <<< "2a0c46c21ffa79d389cfb97d1b5a70d6f9110a49eb9506e8058bed9c4ef763c8ee2567b5de9065429e0410987b30aff336b2cb08d667a6a16075919cb2536d58  $archive_path" || return 1

  sudo unzip -d "$install_dir" -o "$archive_path" vault
  sudo chmod +x "$install_dir/vault"
  sudo ln -f -s "$install_dir/vault" /usr/bin/vault
  rm -rf "$tmp_dir"
}

setup_vault() {
  if [[ ! -e ~/.vault-github-token ]]; then
    echo'Create a new personal access token with read:org permissions (make sure to copy it)...'
    xdg-open 'https://github.com/settings/tokens/new'
    echo -n 'Paste the token: '
    local token
    IFS='' read token
    echo "$token" > ~/.vault-github-token
  fi
  vault login -method=github token="$(< ~/.vault-github-token)"
}

install_yarn() {
  sudo npm install --global yarn
}

install_kubespy() {
  local kubespy_path=$GOPATH/src/github.com/pulumi/kubespy
  if [[ ! -e $kubespy_path ]]; then
    git clone git@github.com:pulumi/kubespy.git "$kubespy_path"
  fi
  (
    cd "$kubespy_path"
    git checkout "$(git tag | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -1)"
    go install
  )
}

install_terraform() {
  local install_dir tmp_dir download_url archive_path
  install_dir=/opt/hashicorp
  if sha512sum -c <<< "e4cdb1b13b5591ab09ee4265fd86c9be7d13041f0c993f0b77d2fbf6ff355c9784f15006658329d82a5207cf61c090adad222dd9072c1a4d09ded50b1a721996  /opt/hashicorp/terraform"; then
    return
  fi
  sudo mkdir -p "$install_dir"

  tmp_dir=$(mktemp -d)
  download_url=https://releases.hashicorp.com/terraform/0.13.0/terraform_0.13.0_linux_amd64.zip
  archive_path=$tmp_dir/$(basename "$download_url")
  curl --fail -o "$archive_path" "$download_url"
  sha512sum -c <<< "895c9266c85d1b39736be5b41cb3e6172d54623b2c23469b46251af51a64f5d1c0d089b91df1071247c62fd8b03ff211b8b7b9d5f7ff10e1a21114665df8a199 $archive_path" || return 1

  sudo unzip -d "$install_dir" -o "$archive_path" terraform
  sudo chmod +x "$install_dir/terraform"
  sudo ln -f -s "$install_dir/terraform" /usr/bin/terraform
  rm -rf "$tmp_dir"
}

install_packer() {
  local install_dir tmp_dir download_url archive_path
  install_dir=/opt/hashicorp
  if sha512sum -c <<< "db30fb9d9899a8dd63747f7c1fefc035428f12141d112890ce1f5d2f5f063fef0ccd8a56342413fdc30da77f8e7c48e8569af1943f9428469bd1735265592202  /opt/hashicorp/packer"; then
    return
  fi
  sudo mkdir -p "$install_dir"

  tmp_dir=$(mktemp -d)
  download_url=https://releases.hashicorp.com/packer/1.6.4/packer_1.6.4_linux_amd64.zip
  archive_path=$tmp_dir/$(basename "$download_url")
  curl --fail -o "$archive_path" "$download_url"
  sha512sum -c <<< "6fad46d2b9a8672082f0e41aae9252207ccbc782f754fef1af26f71d8bb342b079743616cc22e468060ac7a3d734143bce87e22e424fdd15e3fc2f0cc6ed9ff5 $archive_path" || return 1

  sudo unzip -d "$install_dir" -o "$archive_path" packer
  sudo chmod +x "$install_dir/packer"
  sudo ln -f -s "$install_dir/packer" /usr/bin/packer
  rm -rf "$tmp_dir"
}

install_grepip() {
  curl -o ~/.local/bin/grepip -sSL https://raw.githubusercontent.com/emugel/grepip/master/grepip
  sha512sum -c <<< "170f3d3ab490372696adaa05601310a1f8a813fc5622480deb76fac5c0a2b32c91a61c41a4533099da4d9694257be70aa1ee25df807ac90a1fb1152c7213cf93 $HOME/.local/bin/grepip"
  chmod a+x ~/.local/bin/grepip
}

install_gh() {
  curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xC99B11DEB97541F0" | sudo apt-key add
  sudo apt-add-repository https://cli.github.com/packages
  sudo apt-get update
  sudo apt-get install gh
}

install_scripts() {
  for file in "$script_dir"/*; do
    if [[ -x "$file" ]]; then
      ln -v -f -s "$script_dir/$file" "$user_bin_dir/"
    fi
  done
}

main() {
  set -o errexit -o nounset -o pipefail

  sudo apt-get update
  sudo apt-get install -y \
    docker-compose \
    postgresql-client \
    redis-tools \
    && :

  sudo pip3 install ansible

  install_vault

  install_pritunl
  install_gcloud
  install_kubectl
  install_kubectx
  setup_gke
  install_yarn
  install_kubespy
  install_terraform
  install_packer
  install_grepip
  install_gh

  install_scripts
}

if [[ $0 != bash ]]; then
  main
fi
