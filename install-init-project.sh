#!/usr/bin/env bash
#
# install-init-project.sh
#
# Instala (ou atualiza) o comando /init-project a partir de uma pasta gerada
# por package-init-project.sh. Nunca sobrescreve um arquivo existente sem
# perguntar, arquivo por arquivo, com opção de ver o diff antes de decidir.
#
# Uso:
#   install-init-project.sh [caminho/para/pasta-do-pacote]
#
# Sem argumento, usa ~/.claude/initProjectsInstall/dist/init-project/.

set -uo pipefail
# Sem "set -e" de propósito: o laço de perguntas interativas usa "read" e
# "diff", que retornam status != 0 em casos normais (diferença encontrada),
# o que sob "set -e" abortaria o script. Cada comando relevante trata seu
# próprio erro explicitamente.

CLAUDE_HOME="${HOME}/.claude"
DIST_DIR="${CLAUDE_HOME}/initProjectsInstall/dist"
DEFAULT_PACKAGE_DIR="${DIST_DIR}/init-project"

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

PACKAGE_DIR="${1:-${DEFAULT_PACKAGE_DIR}}"

if [[ ! -d "${PACKAGE_DIR}" ]]; then
  echo "ERRO: pasta de pacote não encontrada: ${PACKAGE_DIR}" >&2
  echo "Uso: $0 [caminho/para/pasta-do-pacote]" >&2
  echo "Sem argumento, espera encontrar: ${DEFAULT_PACKAGE_DIR}" >&2
  exit 1
fi

if [[ "${PACKAGE_DIR}" == "${DEFAULT_PACKAGE_DIR}" ]]; then
  echo "==> Nenhuma pasta informada. Usando: ${PACKAGE_DIR}"
fi

missing=()
for rel in "${FILES[@]}"; do
  if [[ ! -f "${PACKAGE_DIR}/${rel}" ]]; then
    missing+=("${rel}")
  fi
done

if (( ${#missing[@]} > 0 )); then
  echo "ERRO: a pasta não contém todos os ${#FILES[@]} arquivos esperados:" >&2
  for m in "${missing[@]}"; do
    echo "  - ${m}" >&2
  done
  echo "Abortando. Nada foi copiado para ${CLAUDE_HOME}." >&2
  exit 1
fi

echo "==> OK: os ${#FILES[@]} arquivos esperados estão presentes em ${PACKAGE_DIR}."

mkdir -p "${CLAUDE_HOME}"
mkdir -p "${CLAUDE_HOME}/commands"
mkdir -p "${CLAUDE_HOME}/templates/init-project"

installed_new=0
overwritten=0
skipped=0

HAS_TTY=1
if { exec 3< /dev/tty; } 2>/dev/null; then
  exec 3<&-
else
  HAS_TTY=0
  echo "AVISO: nenhum terminal interativo disponível (/dev/tty não pôde ser aberto). Arquivos existentes serão pulados por padrão (sem sobrescrever)." >&2
fi

for rel in "${FILES[@]}"; do
  src="${PACKAGE_DIR}/${rel}"
  dest="${CLAUDE_HOME}/${rel}"
  dest_dir="$(dirname "${dest}")"
  mkdir -p "${dest_dir}"

  if [[ ! -e "${dest}" ]]; then
    cp -p "${src}" "${dest}"
    installed_new=$((installed_new + 1))
    echo "  [novo]         ${rel}"
    continue
  fi

  if cmp -s "${src}" "${dest}"; then
    idem_note=" (idêntico ao existente)"
  else
    idem_note=""
  fi

  if [[ "${HAS_TTY}" -eq 0 ]]; then
    skipped=$((skipped + 1))
    echo "  [pulado, sem TTY]${idem_note} ${rel}"
    continue
  fi

  while true; do
    answer=""
    if ! read -r -p "  ${rel}${idem_note} já existe. Sobrescrever? [s/N/d=ver diff] " answer < /dev/tty; then
      skipped=$((skipped + 1))
      echo "  [pulado, leitura falhou] ${rel}"
      break
    fi
    case "${answer}" in
      [Dd]*)
        echo "----- diff: existente (esquerda) vs. novo (direita) -----"
        diff -u "${dest}" "${src}" || true
        echo "-----------------------------------------------------------"
        continue
        ;;
      [Ss]*)
        cp -p "${src}" "${dest}"
        overwritten=$((overwritten + 1))
        echo "  [sobrescrito]  ${rel}"
        break
        ;;
      *)
        skipped=$((skipped + 1))
        echo "  [mantido]      ${rel}"
        break
        ;;
    esac
  done
done

SCAN_SH="${CLAUDE_HOME}/templates/init-project/_scan.sh"
if [[ -f "${SCAN_SH}" ]]; then
  chmod 755 "${SCAN_SH}"
fi

total=$(( installed_new + overwritten + skipped ))

echo ""
echo "==> Resumo da instalação"
echo "    Novos instalados : ${installed_new}"
echo "    Sobrescritos     : ${overwritten}"
echo "    Pulados/mantidos : ${skipped}"
echo "    Total processado : ${total} / ${#FILES[@]}"
echo ""
echo "==> Destino: ${CLAUDE_HOME}"

# --- Verificação de componentes usados pelo /init-project -------------------
# Puramente informativo: nenhuma checagem aqui altera o código de saída do
# script nem impede a conclusão da instalação (mesmo princípio do
# _scan.sh capacidades — "ausência degrada, nunca interrompe").

echo ""
echo "==> Verificação de componentes usados pelo /init-project"
echo ""

echo "-- Agentes, skills, plugins e marketplaces --"
if [[ -x "${SCAN_SH}" ]]; then
  "${SCAN_SH}" capacidades
else
  echo "AVISO: ${SCAN_SH} não encontrado ou não executável — não foi possível checar agentes/skills/plugins." >&2
fi

echo ""
echo "-- RTK (Rust Token Killer) --"
if command -v rtk >/dev/null 2>&1; then
  RTK_PATH="$(command -v rtk)"
  RTK_VERSION="$(rtk --version 2>/dev/null || echo "versão indisponível")"
  echo "ok: rtk encontrado em ${RTK_PATH} (${RTK_VERSION})"
else
  echo "ausente: binário 'rtk' não encontrado no PATH."
  if [[ -f "${CLAUDE_HOME}/RTK.md" ]]; then
    echo "  Ver ${CLAUDE_HOME}/RTK.md para instruções de instalação."
  fi
fi

SETTINGS_JSON="${CLAUDE_HOME}/settings.json"
if [[ -f "${SETTINGS_JSON}" ]]; then
  if grep -q "rtk hook claude" "${SETTINGS_JSON}" 2>/dev/null; then
    echo "ok: hook 'rtk hook claude' encontrado em settings.json"
  else
    echo "ausente: nenhum hook RTK encontrado em settings.json"
  fi
else
  echo "indisponivel: ${SETTINGS_JSON} não encontrado — hook RTK não verificado."
fi
