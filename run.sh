#!/bin/bash
# Para rodar: chmod +x run.sh && ./run.sh
# Menu interativo (whiptail): tudo vem pré-marcado, desmarque o que não quiser.
# Seguro para rodar mais de uma vez (idempotente).
# Gustavo Kennedy Renkel

RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
WHITE=`tput setaf 7`
BOLD=`tput bold`
RESET=`tput sgr0`

# Sem 'set -e': vários passos podem falhar de forma esperada (ssh-add sem chave,
# chsh sem senha, pacote opcional ausente) e não devem abortar o provisionamento.
set -o pipefail
export DEBIAN_FRONTEND=noninteractive

info()  { echo "${RED}$1${RESET}"; }
ok()    { echo "${GREEN}----OK $1${RESET}"; }
warn()  { echo "${YELLOW}  Aviso: $1${RESET}"; }
step()  { echo; echo "${BLUE}${BOLD}== $1 ==${RESET}"; }

# =====================================================================
# SELEÇÃO DE COMPONENTES
# =====================================================================
# Cada entrada: TAG "Descrição" estado-inicial(on/off)
COMPONENTS=(
  MYSQL         "MySQL Server"                          on
  GOLANG        "Go (golang-go)"                        on
  NODE          "Node.js via nvm (LTS)"                 on
  DOCKER        "Docker Engine + Compose v2"            on
  NEOVIM        "NeoVim + NvChad"                       on
  ZSH           "Zsh + OhMyZsh + Powerlevel10k"         on
  TOOLS_SEARCH  "Busca: ripgrep, fd, fzf, bat"          on
  TOOLS_GIT     "Git: lazygit, git-delta"               on
  TOOLS_SESSION "Sessao: tmux, btop, ncdu"              on
  TOOLS_SHELL   "Shell: zoxide, eza, jq"                on
  PYTHON        "Python: pip + pyenv"                   on
)

declare -A SELECTED
is_selected() { [[ -n "${SELECTED[$1]:-}" ]]; }

select_components() {
  if command -v whiptail >/dev/null 2>&1; then
    local menu_args=() tag desc state
    local i=0
    while [ $i -lt ${#COMPONENTS[@]} ]; do
      tag="${COMPONENTS[$i]}"; desc="${COMPONENTS[$((i+1))]}"; state="${COMPONENTS[$((i+2))]}"
      menu_args+=("$tag" "$desc" "$state")
      i=$((i+3))
    done
    local choices
    choices=$(whiptail --title "Configuração do ambiente DEV" \
      --checklist "Espaço marca/desmarca, Tab move, Enter confirma:" \
      22 70 13 "${menu_args[@]}" 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ]; then
      echo "${YELLOW}Seleção cancelada. Saindo.${RESET}"; exit 0
    fi
    local t
    for t in $choices; do
      t="${t//\"/}"
      SELECTED["$t"]=1
    done
  else
    warn "whiptail não encontrado — usando prompts de texto."
    local i=0 tag desc state ans
    while [ $i -lt ${#COMPONENTS[@]} ]; do
      tag="${COMPONENTS[$i]}"; desc="${COMPONENTS[$((i+1))]}"; state="${COMPONENTS[$((i+2))]}"
      read -r -p "Instalar ${desc}? [S/n] " ans
      ans="${ans:-S}"
      if [[ "$ans" =~ ^[SsYy]$ ]]; then SELECTED["$tag"]=1; fi
      i=$((i+3))
    done
  fi
}

select_components

echo
echo "${YELLOW}${BOLD} INICIANDO AMBIENTE ${RESET}"
echo "${WHITE}Selecionados: ${!SELECTED[*]}${RESET}"

# =====================================================================
# BASE (sempre executa)
# =====================================================================
step "Sistema base"
info "Atualizando sistema..."
sudo apt-get update --yes
sudo apt-get upgrade --yes
ok "SISTEMA ATUALIZADO"

info "Limpando cache do sistema..."
sudo apt-get autoremove --yes && sudo apt-get autoclean --yes && sudo apt-get clean --yes
ok "CACHE LIMPO"

info "Configurando timezone..."
sudo timedatectl set-timezone "America/Sao_Paulo"
sudo systemctl restart systemd-timesyncd.service
ok "TIMEZONE"

info "Instalando pacotes base..."
sudo apt-get install --yes \
  net-tools ssh build-essential curl file \
  git unzip ca-certificates gnupg lsb-release whiptail
ok "PACOTES BASE"

# Git + SSH
info "Configurando Git e SSH..."
mkdir -p ~/.ssh && chmod 700 ~/.ssh
PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHp3fzYLzQ0FAWFw6qQa/tRqz35mzqZg/v9a9HpnYRk+ gustavo@overall.cloud"
if ! grep -qF "$PUBKEY" ~/.ssh/id_ed25519.pub 2>/dev/null; then
  echo "$PUBKEY" >> ~/.ssh/id_ed25519.pub
fi
chmod 644 ~/.ssh/id_ed25519.pub
if [ -f ~/.ssh/id_ed25519 ]; then
  chmod 600 ~/.ssh/id_ed25519
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519 || warn "não foi possível adicionar a chave privada ao agente."
else
  warn "~/.ssh/id_ed25519 (chave privada) não encontrada — adicione-a manualmente (veja README)."
fi
git config --global user.name "Gustavo Kennedy Renkel"
git config --global user.email gustavo@overall.cloud
ok "GIT/SSH"

# =====================================================================
# COMPONENTES SELECIONÁVEIS
# =====================================================================

if is_selected MYSQL; then
  step "MySQL Server"
  sudo apt-get install --yes mysql-server
  ok "MYSQL"
fi

if is_selected GOLANG; then
  step "Go"
  sudo apt-get install --yes golang-go
  ok "GO"
fi

if is_selected NODE; then
  step "Node.js (nvm)"
  export NVM_DIR="$HOME/.nvm"
  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  fi
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  if command -v nvm >/dev/null 2>&1; then
    nvm install --lts
  fi
  ok "NVM E NODEJS"
fi

if is_selected DOCKER; then
  step "Docker"
  if ! command -v docker >/dev/null 2>&1; then
    sudo install -m 0755 -d /etc/apt/keyrings
    if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      sudo chmod a+r /etc/apt/keyrings/docker.gpg
    fi
    . /etc/os-release
    DOCKER_CODENAME="${UBUNTU_CODENAME:-$(lsb_release -cs)}"
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${DOCKER_CODENAME} stable" \
      | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    if ! sudo apt-get update --yes; then
      warn "repo Docker para '${DOCKER_CODENAME}' indisponível; usando fallback 'noble' (24.04 LTS)."
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update --yes
    fi
    sudo apt-get install --yes \
      docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker "${USER}"
  fi
  ok "DOCKER (Compose v2 via 'docker compose')"
fi

if is_selected NEOVIM; then
  step "NeoVim + NvChad"
  if ! command -v nvim >/dev/null 2>&1; then
    NVIM_TMP="$(mktemp -d)"
    curl -L -o "${NVIM_TMP}/nvim.appimage" \
      https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
    chmod u+x "${NVIM_TMP}/nvim.appimage"
    ( cd "${NVIM_TMP}" && ./nvim.appimage --appimage-extract >/dev/null )
    sudo rm -rf /opt/nvim
    sudo mv "${NVIM_TMP}/squashfs-root" /opt/nvim
    sudo ln -sf /opt/nvim/AppRun /usr/bin/nvim
    rm -rf "${NVIM_TMP}"
  fi
  [ -d ~/.config/nvim ] || git clone https://github.com/NvChad/starter ~/.config/nvim
  ok "NEOVIM E NVCHAD"
fi

if is_selected ZSH; then
  step "Zsh + OhMyZsh + Powerlevel10k"
  sudo apt-get install --yes zsh fonts-powerline
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
  ZSH_AUTOSUGGEST="$HOME/.oh-my-zsh/plugins/zsh-autosuggestions"
  ZSH_HIGHLIGHT="$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting"
  [ -d "$ZSH_AUTOSUGGEST" ] || git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_AUTOSUGGEST"
  [ -d "$ZSH_HIGHLIGHT" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_HIGHLIGHT"
  P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  [ -d "$P10K_DIR" ] || git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  ok "ZSH/OMZ/P10K"
fi

# ---- Ferramentas CLI ----
mkdir -p "$HOME/.local/bin"

if is_selected TOOLS_SEARCH; then
  step "Ferramentas de busca"
  sudo apt-get install --yes ripgrep fd-find fzf bat
  # No Ubuntu os binários são fdfind/batcat; cria atalhos fd/bat em ~/.local/bin
  command -v fdfind >/dev/null && ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  command -v batcat >/dev/null && ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  ok "RIPGREP/FD/FZF/BAT"
fi

if is_selected TOOLS_GIT; then
  step "Ferramentas de Git"
  # git-delta via apt (universe); lazygit via apt e, se ausente, via release do GitHub.
  sudo apt-get install --yes git-delta || warn "git-delta não disponível via apt."
  if ! command -v lazygit >/dev/null 2>&1; then
    if ! sudo apt-get install --yes lazygit 2>/dev/null; then
      LG_VER="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name": *"v\K[^"]*')"
      if [ -n "$LG_VER" ]; then
        LG_TMP="$(mktemp -d)"
        curl -fsSL -o "${LG_TMP}/lazygit.tar.gz" \
          "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LG_VER}_Linux_x86_64.tar.gz"
        tar -xf "${LG_TMP}/lazygit.tar.gz" -C "${LG_TMP}" lazygit
        sudo install "${LG_TMP}/lazygit" /usr/local/bin/lazygit
        rm -rf "${LG_TMP}"
      else
        warn "não foi possível instalar lazygit automaticamente."
      fi
    fi
  fi
  ok "LAZYGIT/GIT-DELTA"
fi

if is_selected TOOLS_SESSION; then
  step "Sessão / monitoramento"
  sudo apt-get install --yes tmux btop ncdu
  ok "TMUX/BTOP/NCDU"
fi

if is_selected TOOLS_SHELL; then
  step "Utilitários de shell"
  sudo apt-get install --yes zoxide eza jq || warn "algum pacote (zoxide/eza/jq) pode não estar disponível."
  ok "ZOXIDE/EZA/JQ"
fi

if is_selected PYTHON; then
  step "Python (pip + pyenv)"
  sudo apt-get install --yes python3-pip python3-venv \
    make libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    libffi-dev liblzma-dev tk-dev
  if [ ! -d "$HOME/.pyenv" ]; then
    curl -fsSL https://pyenv.run | bash
  fi
  ok "PIP/PYENV"
fi

# =====================================================================
# DOTFILES + FINALIZAÇÃO (apenas se Zsh foi selecionado)
# =====================================================================
if is_selected ZSH; then
  step "Aplicando dotfiles"
  cp .p10k.zsh .zshrc ~/

  # Bloco gerenciado com inits/aliases das ferramentas instaladas (idempotente).
  MARK_BEGIN="# >>> config-ubuntu-dev tools >>>"
  MARK_END="# <<< config-ubuntu-dev tools <<<"
  if ! grep -qF "$MARK_BEGIN" ~/.zshrc 2>/dev/null; then
    {
      echo ""
      echo "$MARK_BEGIN"
      echo 'export PATH="$HOME/.local/bin:$PATH"'
      echo 'command -v fdfind >/dev/null && alias fd="fdfind"'
      echo 'command -v batcat >/dev/null && alias bat="batcat"'
      echo 'command -v eza >/dev/null && alias ls="eza --icons --group-directories-first"'
      echo 'command -v zoxide >/dev/null && eval "$(zoxide init zsh)"'
      echo 'command -v fzf >/dev/null && source <(fzf --zsh) 2>/dev/null'
      echo 'if [ -d "$HOME/.pyenv" ]; then'
      echo '  export PYENV_ROOT="$HOME/.pyenv"'
      echo '  export PATH="$PYENV_ROOT/bin:$PATH"'
      echo '  command -v pyenv >/dev/null && eval "$(pyenv init - zsh)"'
      echo 'fi'
      echo "$MARK_END"
    } >> ~/.zshrc
  fi

  chsh -s "$(which zsh)" || warn "não foi possível trocar o shell padrão; rode 'chsh -s $(which zsh)' manualmente."
  ok "DOTFILES"
fi

echo
echo "${GREEN}${BOLD} AMBIENTE CONFIGURADO!${RESET}"
echo "${WHITE} Saia e entre novamente (ou reinicie) para aplicar grupo docker e o shell zsh.${RESET}"
