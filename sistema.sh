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
sudo apt-get install build-essential curl file git nginx --yes
echo "${GREEN}----OK PACOTES INSTALADOS COM SUCESSO!${RESET}"
# Configura Git
echo "${RED}  Configurando Git (chave, name and email)...${RESET}"
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHp3fzYLzQ0FAWFw6qQa/tRqz35mzqZg/v9a9HpnYRk+ gustavo@overall.cloud" | sudo tee -a ./.ssh/id_ed25519.pub
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
git config --global user.name "Gustavo Kennedy Renkel"
git config --global user.email gustavo@overall.cloud
echo "${GREEN}----OK VARIAVEIS GIT CONFIGURADAS COM SUCESSO!${RESET}"
