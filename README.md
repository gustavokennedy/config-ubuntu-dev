# Initial Config for Ubuntu - DEV
Script for initial Ubuntu configurations for development environment.

### Update

Atualizado repo e instala pacotes:

```
sudo apt-get update && sudo apt-get install git net-tools ssh
```

### Adiciona usuário ao sudoers:
 
```
sudo -i
nano /etc/sudoers
```

### Clona o repo:
 
```
git clone https://github.com/gustavokennedy/config-ubuntu-dev.git
```

## Rodar

```
chmod +x run.sh && ./run.sh
```


Para limpar tudo:

```
sudo rm -rf /squashfs-root && sudo rm -rf /usr/bin/nvim && sudo rm -rf /home/kennedy/.config/nvim && sudo rm -rf /home/kennedy/.oh-my-zsh/custom/themes/powerlevel10k && sudo rm -rf /home/kennedy/.oh-my-zsh
```
