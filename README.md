# Initial Config for Ubuntu - DEV
Script para configuração inicial de um ambiente de desenvolvimento no Ubuntu Server (26.04).

Ao rodar, um **menu interativo (whiptail)** abre com todos os componentes pré-marcados —
desmarque (barra de espaço) o que não quiser instalar e confirme com Enter. O script é
**idempotente** (pode rodar mais de uma vez sem quebrar).

### Componentes selecionáveis

- **MySQL Server**
- **Go** (golang-go)
- **Node.js** via nvm (LTS)
- **Docker** Engine + Compose v2
- **NeoVim** + NvChad
- **Zsh** + Oh My Zsh + Powerlevel10k
- **Busca:** ripgrep, fd, fzf, bat
- **Git:** lazygit, git-delta
- **Sessão:** tmux, btop, ncdu
- **Shell:** zoxide, eza, jq
- **Python:** pip + pyenv

Sempre instalado (base): atualização do sistema, timezone, pacotes essenciais
(build-essential, curl, git, ssh...) e configuração de Git/SSH.

### Debian

Para Debian, basta **desmarcar Docker** no menu (o repositório usa a URL do Ubuntu).

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
sudo rm -rf /opt/nvim && sudo rm -rf /usr/bin/nvim && rm -rf "$HOME/.config/nvim" && rm -rf "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" && rm -rf "$HOME/.oh-my-zsh"
```
