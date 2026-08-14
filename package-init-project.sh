#!/usr/bin/env bash
#
# package-init-project.sh
#
# Empacota o comando /init-project (CLAUDE.md global + commands/init-project.md)
# e seus 15 arquivos de suporte (templates/init-project/*) em uma pasta simples
# — sem zip — pronta para copiar para outra máquina (USB, rsync, AirDrop) e
# instalar lá com install-init-project.sh.
#
# Uso:
#   ~/.claude/initProjectsInstall/package-init-project.sh
#
# A cada execução, dist/init-project/ é substituída inteiramente pelo
# conteúdo atual de ~/.claude — não guarda histórico de versões anteriores.

set -euo pipefail

CLAUDE_HOME="${HOME}/.claude"
INSTALL_DIR="${CLAUDE_HOME}/initProjectsInstall"
DIST_DIR="${INSTALL_DIR}/dist"
PACKAGE_DIR="${DIST_DIR}/init-project"

FILES=(
  "CLAUDE.md"
  "commands/init-project.md"
  "templates/init-project/_scan.sh"
  "templates/init-project/_capacidades.md"
  "templates/init-project/_checklist-entrevista.md"
  "templates/init-project/_varredura-regras.md"
  "templates/init-project/API.md.tpl.md"
  "templates/init-project/Arquitetura.md.tpl.md"
  "templates/init-project/Auth.md.tpl.md"
  "templates/init-project/CLAUDE.md.tpl.md"
  "templates/init-project/Frontend.md.tpl.md"
  "templates/init-project/Harness.md.tpl.md"
  "templates/init-project/Infraestrutura.md.tpl.md"
  "templates/init-project/Memoria.md.tpl.md"
  "templates/init-project/Organograma.md.tpl.md"
  "templates/init-project/Progresso.md.tpl.md"
  "templates/init-project/RAG.md.tpl.md"
  "templates/init-project/RegrasNegocio.md.tpl.md"
)

echo "==> Verificando integridade dos ${#FILES[@]} arquivos de origem em ${CLAUDE_HOME}"

missing=()
for rel in "${FILES[@]}"; do
  if [[ ! -f "${CLAUDE_HOME}/${rel}" ]]; then
    missing+=("${rel}")
  fi
done

if (( ${#missing[@]} > 0 )); then
  echo "ERRO: ${#missing[@]} arquivo(s) esperado(s) não encontrado(s):" >&2
  for m in "${missing[@]}"; do
    echo "  - ${CLAUDE_HOME}/${m}" >&2
  done
  echo "Abortando. Nenhum pacote foi gerado." >&2
  exit 1
fi

echo "==> OK: todos os ${#FILES[@]} arquivos encontrados."

mkdir -p "${DIST_DIR}"

STAGE_DIR="$(mktemp -d)"
trap 'rm -rf "${STAGE_DIR}"' EXIT

mkdir -p "${STAGE_DIR}/commands" "${STAGE_DIR}/templates/init-project"

for rel in "${FILES[@]}"; do
  dest="${STAGE_DIR}/${rel}"
  mkdir -p "$(dirname "${dest}")"
  ditto "${CLAUDE_HOME}/${rel}" "${dest}"
done

chmod 755 "${STAGE_DIR}/templates/init-project/_scan.sh"

echo "==> Publicando em ${PACKAGE_DIR}"

if [[ -e "${PACKAGE_DIR}" ]]; then
  rm -rf "${PACKAGE_DIR}"
fi

mv "${STAGE_DIR}" "${PACKAGE_DIR}"
trap - EXIT

echo "==> Concluído."
echo "==> Pasta: ${PACKAGE_DIR}"
echo "==> Conteúdo:"
( cd "${PACKAGE_DIR}" && find . -type f | sed 's|^\./||' | sort )
