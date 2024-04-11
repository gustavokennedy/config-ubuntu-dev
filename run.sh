#!/bin/bash
# Para atualizar o Frontend o utilize: ./run.sh
# Para problemas de permissão: chmod +x run.sh
# Gustavo Kennedy Renkel

RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
WHITE=`tput setaf 7`
BOLD=`tput bold`
RESET=`tput sgr0`

set -euo pipefail
set +u

echo -e "${YELLOW} INICIANDO AMBIENTE ${RESET}"
export DEBIAN_FRONTEND=noninteractive
# Atualiza sistema
echo "${RED} Atualizando sistema...${RESET}"
sudo apt update --yes && sudo apt list --upgradable --yes && sudo apt upgrade --yes
echo "${GREEN}----OK SISTEMA ATUALIZADO COM SUCESSO!${RESET}"
# Limpa cache
echo "${RED} Limpando cache do sistema...${RESET}"
sudo apt autoremove --yes && sudo apt autoclean --yes && sudo apt clean --yes
echo "${GREEN}----OK CACHE LIMPO COM SUCESSO!${RESET}"
# Configura timezone
echo "${RED} Configurando timezone do servidor...${RESET}"
sudo timedatectl set-timezone "America/Sao_Paulo"
sudo systemctl restart systemd-timesyncd.service
echo "${GREEN}----OK TIMEZONE ATUALIZADO COM SUCESSO!${RESET}"
# Instala pacotes
echo "${RED} Instalando pacotes necessários..${RESET}."
sudo apt-get install net-tools ssh build-essential curl file nginx --yes
echo "${GREEN}----OK PACOTES INSTALADOS COM SUCESSO!${RESET}"
# Configura Git
echo "${RED}  Configurando Git (chave, name and email)...${RESET}"
touch ~/.ssh/id_ed25519.pub
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHp3fzYLzQ0FAWFw6qQa/tRqz35mzqZg/v9a9HpnYRk+ gustavo@overall.cloud" | sudo tee -a ~/.ssh/id_ed25519.pub
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
git config --global user.name "Gustavo Kennedy Renkel"
git config --global user.email gustavo@overall.cloud
echo "${GREEN}----OK VARIAVEIS GIT CONFIGURADAS COM SUCESSO!${RESET}"

#
# DEV
# 

# Instala NVM e Node
echo "${RED}  Instalando NVM & NodeJS...${RESET}"
sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh
sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install node
echo "${GREEN}----OK NVM E NODEJS INSTALADOS COM SUCESSO!${RESET}"
sudo systemctl reload nginx && sudo systemctl restart nginx
echo "${GREEN}----OK NGINX REINICIADO COM SUCESSO!${RESET}"

# Instala Docker
echo "${RED}  Instalando Docker...${RESET}"
sudo apt install apt-transport-https ca-certificates curl software-properties-common --yes
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce
sudo usermod -aG docker ${USER}
sudo usermod -aG docker kennedy
echo "${GREEN}----OK DOCKER INSTALADO COM SUCESSO!${RESET}"

# Instala Docker Compose
echo "${RED}  Instalando Docker-Compose...${RESET}"
sudo apt-get install docker-compose --yes
sudo chmod 666 /var/run/docker.sock
docker-compose version
echo "${GREEN}----OK DOCKER-COMPOSE INSTALADO COM SUCESSO!${RESET}"
echo "${RED}  Instalando FontsPowerline...${RESET}"
sudo apt-get install fonts-powerline --yes
echo "${GREEN}----OK FONTE POWERLINE CONFIGURADAS COM SUCESSO!${RESET}"

# NeoVim
echo "${RED}  Instalando e configurando NeoVim...${RESET}"
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage --appimage-extract
sudo mv squashfs-root /
sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
echo "${GREEN}----OK NEOVIM INSTALADO COM SUCESSO!${RESET}"

# NVChad
echo "${RED}  Instalando e configurando NvChad...${RESET}"
git clone https://github.com/NvChad/starter ~/.config/nvim && nvim
echo "${GREEN}----OK NVCHAD INSTALADO COM SUCESSO!${RESET}"

# Configura ZSH
echo "${RED}  Instalando e configurando ZSH...${RESET}"
sudo apt-get install zsh --yes
chsh -s /usr/bin/zsh
cp .zshrc ~/
echo "${GREEN}----OK ZSH INSTALADO COM SUCESSO!${RESET}"

# Oh My ZSH
echo "${RED}  Instalando e configurando OhMyZsh e plugins no ZSH...${RESET}"
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.oh-my-zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting
echo "${GREEN}----OK OMZSH E PLUGINS INSTALADOS COM SUCESSO!${RESET}"

# PowerLevel10k
echo "${RED}  Instalando e configurando PowerLevel10k...${RESET}"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
cp .p10k.zsh ~/
echo "${GREEN}----OK POWERLEVEL10K INSTALADO COM SUCESSO!${RESET}"
