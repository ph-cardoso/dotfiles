# Ansible (WSL Ubuntu 24.04)

Playbooks para automatizar o bootstrap de um ambiente novo baseado nestes dotfiles.

## Como usar

```bash
cd ansible
ansible-playbook playbooks/site.yml
```

Playbooks individuais:

```bash
ansible-playbook playbooks/update-packages.yml
ansible-playbook playbooks/install-tools.yml
ansible-playbook playbooks/configure-dotfiles.yml
```
