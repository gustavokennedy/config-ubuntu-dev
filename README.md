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

## Uso das ferramentas instaladas

Abaixo, para cada ferramenta provisionada pelo `run.sh`, uma breve descrição do uso,
um exemplo prático e o código para rodar.

### MySQL Server

Banco de dados relacional. Após a instalação o serviço já sobe via systemd.

```bash
# Verificar status do serviço
sudo systemctl status mysql

# Acessar o console (login como root via socket)
sudo mysql

# Exemplo: criar um banco e um usuário
sudo mysql -e "CREATE DATABASE app; CREATE USER 'dev'@'localhost' IDENTIFIED BY 'senha'; GRANT ALL ON app.* TO 'dev'@'localhost';"
```

### Go (golang-go)

Linguagem compilada da Google. Ideal para CLIs e serviços.

```bash
# Conferir a versão
go version

# Exemplo: compilar e rodar um programa
echo 'package main; import "fmt"; func main(){ fmt.Println("olá, Go") }' > main.go
go run main.go        # executa direto
go build -o app main.go && ./app   # compila um binário
```

### Node.js (via nvm)

Runtime JavaScript instalado pelo nvm (versão LTS). O nvm permite alternar versões.

```bash
# Versões instaladas / em uso
node --version
nvm ls

# Exemplo: instalar e usar outra versão, e rodar um script
nvm install 20 && nvm use 20
node -e "console.log('olá, Node ' + process.version)"
```

### Docker (Engine + Compose v2)

Containers de aplicação. O Compose v2 roda como subcomando `docker compose`.

```bash
# Testar a instalação
docker run --rm hello-world

# Exemplo: subir um container e usar Compose
docker run -d --name web -p 8080:80 nginx
docker compose up -d        # usa o docker-compose.yml do diretório atual
```

> Após a instalação, saia e entre novamente na sessão para usar o Docker sem `sudo`.

### NeoVim + NvChad

Editor de texto modal com a configuração NvChad. Na primeira abertura ele instala os plugins.

```bash
# Abrir um arquivo
nvim README.md

# Exemplo: editar e sair salvando
# dentro do nvim:  i (insere)  ->  Esc  ->  :wq  (salva e sai)
```

### Zsh + Oh My Zsh + Powerlevel10k

Shell interativo com framework de plugins e tema. Vira o shell padrão ao final do script.

```bash
# Entrar no zsh manualmente
zsh

# Exemplo: reconfigurar o tema Powerlevel10k
p10k configure
```

### Busca: ripgrep, fd, fzf, bat

Ferramentas rápidas de busca e navegação.

```bash
# ripgrep (rg): procurar um texto recursivamente
rg "TODO" .

# fd: encontrar arquivos por nome
fd ".sh$"

# fzf: busca interativa (ex.: abrir arquivo escolhido no nvim)
nvim "$(fzf)"

# bat: cat com syntax highlight e numeração
bat run.sh
```

### Git: lazygit, git-delta

Interface TUI para Git e diffs mais legíveis.

```bash
# lazygit: abrir a interface no repositório atual
lazygit

# git-delta: usar como paginador de diffs
git config --global core.pager delta
git diff        # agora exibido pelo delta
```

### Sessão / monitoramento: tmux, btop, ncdu

Multiplexador de terminal e monitores de sistema/disco.

```bash
# tmux: criar uma sessão nomeada (destacar: Ctrl-b d)
tmux new -s dev

# btop: monitor interativo de CPU, memória e processos
btop

# ncdu: análise de uso de disco por diretório
ncdu /home
```

### Shell: zoxide, eza, jq

Navegação inteligente de diretórios, `ls` moderno e processamento de JSON.

```bash
# zoxide (z): pular para diretórios usados com frequência
z config        # vai para .../config-ubuntu-dev após visitá-lo uma vez

# eza: substituto do ls (já aliasado no .zshrc)
eza --icons --group-directories-first -la

# jq: filtrar/transformar JSON
echo '{"nome":"dev","tags":["go","node"]}' | jq '.tags[0]'
```

### Python: pip + pyenv

Gerenciador de pacotes e gerenciador de versões do Python.

```bash
# pip: instalar um pacote
pip install --user requests

# pyenv: instalar e ativar uma versão do Python
pyenv install 3.12
pyenv global 3.12
python --version
```
