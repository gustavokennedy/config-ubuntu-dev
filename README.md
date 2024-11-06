# Initial Config for Ubuntu - DEV
Script for initial Ubuntu configurations for development environment.

### Debian

For Debian, remove in `run.sh`:

Line 34: `mysql-server`

Docker, from lines `62 to 70`.

### Update

### Adiciona usuário ao sudoers:
 
```
su -
nano /etc/sudoers
```
Atualizado repo e instala pacotes:

```
sudo apt-get update && sudo apt-get install git net-tools ssh
```

### Clona o repo:
 
```
git clone https://github.com/gustavokennedy/config-ubuntu-dev.git
```

### SSH key

Adicionar [chave privada](https://github.com/gustavokennedy/ssh-pk) em:

```
sudo nano ~/.ssh/id_ed25519
```

Para possível erro de 'cannot touch':

```
sudo chown [seu usuario] /home/seu_usuario/.ssh/id_ed25519.pub
```

## Rodar

```
chmod +x run.sh && ./run.sh
```


Para limpar tudo:

```
sudo rm -rf /squashfs-root && sudo rm -rf /usr/bin/nvim && sudo rm -rf /home/kennedy/.config/nvim && sudo rm -rf /home/kennedy/.oh-my-zsh/custom/themes/powerlevel10k && sudo rm -rf /home/kennedy/.oh-my-zsh
```
