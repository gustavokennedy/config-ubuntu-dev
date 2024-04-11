#!/bin/bash
# Para atualizar o Frontend o utilize: ./setup.sh
# Para problemas de permissão: chmod +x setup.sh
# Gustavo Kennedy Renkel

RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
WHITE=`tput setaf 7`
BOLD=`tput bold`
RESET=`tput sgr0`

set -euo pipefail

echo -e "${YELLOW} INICIANDO AMBIENTE ${RESET}"
export DEBIAN_FRONTEND=noninteractive
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
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce
sudo usermod -aG docker ${USER}
su - ${USER}
sudo usermod -aG docker kennedy
sudo systemctl status docker
echo "${GREEN}----OK DOCKER INSTALADO COM SUCESSO!${RESET}"
# Instala Docker Compose
echo "${RED}  Instalando Docker-Compose...${RESET}"
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose
docker compose version
echo "${GREEN}----OK DOCKER-COMPOSE INSTALADO COM SUCESSO!${RESET}"
echo "${RED}  Instalando FontsPowerline...${RESET}"
sudo apt-get install fonts-powerline
echo "${GREEN}----OK FONTE POWERLINE CONFIGURADAS COM SUCESSO!${RESET}"
# Configura ZSH
echo "${RED}  Instalando e configurando ZSH...${RESET}"
sudo apt-get install zsh --yes
chsh -s /usr/bin/zsh
echo "${GREEN}----OK ZSH INSTALADO COM SUCESSO!${RESET}"
# Oh My ZSH
echo "${RED}  Instalando e configurando OhMyZsh e plugins no ZSH...${RESET}"
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
# PowerLevel10k
echo "${RED}  Instalando e configurando PowerLevel10k...${RESET}"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
echo "${GREEN}----OK POWERLEVEL10K INSTALADO COM SUCESSO!${RESET}"
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