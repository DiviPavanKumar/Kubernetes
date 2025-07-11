#!/bin/bash
# ---------------------------------------------------------------------------
# Installs Docker CE, kubectl, and Minikube on CentOS/RHEL/Amazon Linux.
# Writes progress to /tmp/install-k8s-stack-<timestamp>.log
# ---------------------------------------------------------------------------

set -euo pipefail

# ---------- basic setup -----------------------------------------------------
TS=$(date +%F-%H-%M-%S)
LOG=/tmp/install-k8s-stack-${TS}.log
echo "Log: $LOG"

RED="\e[31m"; GRN="\e[32m"; YEL="\e[33m"; NRM="\e[0m"

die() { echo -e "${RED}$*${NRM}" | tee -a "$LOG"; exit 1; }
ok()  { echo -e "${GRN}$*${NRM}" | tee -a "$LOG"; }

[ "$(id -u)" -eq 0 ] || die "Run as root or with sudo"

# Choose yum (EL7) or dnf (EL8+)
PM=$(command -v dnf || command -v yum) || die "No package manager found"

# ---------- remove old container packages ----------------------------------
echo -e "${YEL}Removing any old Docker/Podman...${NRM}"
$PM -y remove docker* podman runc containerd &>>"$LOG" || true
ok "Cleaned old container packages"

# ---------- system update + base tools -------------------------------------
echo -e "${YEL}Updating OS and installing tools...${NRM}"
$PM -y install dnf-plugins-core curl tar ca-certificates &>>"$LOG"
ok "Base packages ready"

# ---------- Docker CE -------------------------------------------------------
echo -e "${YEL}Adding Docker CE repo & installing Docker...${NRM}"
$PM config-manager --add-repo https://download.docker.com/linux/$(. /etc/os-release; echo $ID)/docker-ce.repo &>>"$LOG"
$PM -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin &>>"$LOG"
systemctl enable --now docker &>>"$LOG"
usermod -aG docker "${SUDO_USER:-root}" || true
ok "Docker installed and running"

# ---------- kubectl ---------------------------------------------------------
echo -e "${YEL}Installing kubectl...${NRM}"
KVER=$(curl -sL https://dl.k8s.io/release/stable.txt)
curl -sL "https://dl.k8s.io/release/${KVER}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl
chmod 755 /usr/local/bin/kubectl
ok "kubectl ${KVER} installed"

# ---------- Minikube --------------------------------------------------------
echo -e "${YEL}Installing Minikube...${NRM}"
curl -sL https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 -o /usr/local/bin/minikube
chmod 755 /usr/local/bin/minikube
ok "Minikube installed"

# ---------- done ------------------------------------------------------------
echo -e "${GRN}All done!${NRM}
- Re‑login so your user picks up Docker group membership.
- Start a cluster with:  minikube start --driver=docker
- Check it with:         kubectl get nodes

Full log: $LOG"
