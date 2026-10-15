#!/usr/bin/env bash
#
# release-init-project.sh
#
# Cria a tag v<VERSION> e a GitHub Release do pacote dist/init-project/.
# Só roda quando o mantenedor pede. Nenhum push dispara isto.
#
# Uso:
#   ./release-init-project.sh            # valida, pede s, publica
#   ./release-init-project.sh --dry-run  # valida e empacota; não cria tag, não envia, não publica
#
# Antes: bump manual de dist/init-project/VERSION e a seção ## [X.Y.Z]
# correspondente em CHANGELOG.md, commitados em main. Árvore suja, branch
# diferente de main, ou ausência de terminal interativo encerram sem publicar.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

DRY=0
case "${1:-}" in
  "") ;;
  --dry-run) DRY=1 ;;
  -h|--help)
    echo "Uso: ./release-init-project.sh [--dry-run]"
    echo "Lê dist/init-project/VERSION, valida o pacote e — com a resposta s — cria a tag e a GitHub Release."
    echo "Não dispara em push. Sem terminal interativo, recusa."
    exit 0
    ;;
  *)
    echo "ERRO: argumento desconhecido: $1" >&2
    echo "Uso: ./release-init-project.sh [--dry-run]" >&2
    exit 2
    ;;
esac

die() { echo "ERRO: $*" >&2; exit 1; }

command -v git >/dev/null 2>&1 || die "git ausente"
command -v gh >/dev/null 2>&1 || die "gh ausente (https://cli.github.com)"
command -v shellcheck >/dev/null 2>&1 || die "shellcheck ausente"
command -v zip >/dev/null 2>&1 || die "zip ausente"
command -v tar >/dev/null 2>&1 || die "tar ausente"

if command -v sha256sum >/dev/null 2>&1; then
  HASH=(sha256sum)
elif command -v shasum >/dev/null 2>&1; then
  HASH=(shasum -a 256)
else
  die "sha256sum ou shasum ausente"
fi

[[ -f dist/init-project/VERSION ]] || die "dist/init-project/VERSION ausente"
VER="$(tr -d '[:space:]' < dist/init-project/VERSION)"
[[ "${VER}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "VERSION não é semver X.Y.Z: ${VER}"
TAG="v${VER}"

grep -q "^## \[${VER}\]" CHANGELOG.md || die "CHANGELOG.md sem a seção ## [${VER}]"

echo "==> shellcheck"
shellcheck -S warning \
  install-init-project.sh package-init-project.sh release-init-project.sh \
  dist/init-project/templates/init-project/_scan.sh

echo "==> paridade das listas FILES"
extrair_sh() { sed -n '/^FILES=(/,/^)/p' "$1" | grep -o '"[^"]*"' | tr -d '"'; }
extrair_ps1() { sed -n '/^\$Files = @(/,/^)/p' "$1" | grep -o "'[^']*'" | tr -d "'"; }
diff -q <(extrair_sh install-init-project.sh) <(extrair_sh package-init-project.sh) >/dev/null \
  || die "FILES diverge entre install-init-project.sh e package-init-project.sh"
diff -q <(extrair_sh install-init-project.sh) <(extrair_ps1 install-init-project.ps1) >/dev/null \
  || die "FILES diverge entre install-init-project.sh e install-init-project.ps1"
faltando=0
while IFS= read -r f; do
  if [[ ! -f "dist/init-project/${f}" ]]; then
    echo "  ausente no pacote: ${f}" >&2
    faltando=1
  fi
done < <(extrair_sh install-init-project.sh)
[[ "${faltando}" -eq 0 ]] || die "pacote incompleto (RN-INSTALADOR-013)"
echo "OK: $(extrair_sh install-init-project.sh | wc -l | tr -d ' ') arquivos, três listas idênticas."

branch="$(git rev-parse --abbrev-ref HEAD)"
[[ "${branch}" == "main" ]] || die "branch atual é ${branch}; a release sai de main"

if [[ -n "$(git status --porcelain)" ]]; then
  die "árvore de trabalho suja. Faça o commit de VERSION e CHANGELOG.md antes."
fi

if git rev-parse -q --verify "refs/tags/${TAG}" >/dev/null; then
  die "a tag ${TAG} já existe neste repositório"
fi

echo "==> conferindo origin"
git fetch origin main --tags || die "não foi possível buscar origin/main"
remoto="$(git ls-remote --tags origin "refs/tags/${TAG}")"
[[ -z "${remoto}" ]] || die "a tag ${TAG} já existe no origin"
if gh release view "${TAG}" >/dev/null 2>&1; then
  die "a release ${TAG} já existe"
fi

counts="$(git rev-list --left-right --count "origin/main...HEAD")"
behind="${counts%%$'\t'*}"
ahead="${counts##*$'\t'}"
[[ "${behind}" -eq 0 ]] || die "main local está ${behind} commit(s) atrás de origin/main. Atualize antes."

OUT="$(mktemp -d)"
trap 'rm -rf "${OUT}"' EXIT

awk -v v="${VER}" '
  $0 ~ "^## \\[" v "\\]" { on=1; next }
  on && /^## \[/ { exit }
  on { print }
' CHANGELOG.md > "${OUT}/NOTES.md"
{
  echo
  echo "## Instalação"
  echo
  echo "Extraia \`init-project-${VER}.tar.gz\` (ou \`.zip\`) e rode \`./install-init-project.sh ./init-project\` (macOS/Linux) ou \`install-init-project.cmd .\\init-project\` (Windows). Nada é instalado sem confirmação no terminal."
} >> "${OUT}/NOTES.md"

tar -C dist -czf "${OUT}/init-project-${VER}.tar.gz" init-project
(cd dist && zip -qr "${OUT}/init-project-${VER}.zip" init-project)
cp install-init-project.sh install-init-project.ps1 install-init-project.cmd "${OUT}/"
(
  cd "${OUT}"
  "${HASH[@]}" \
    "init-project-${VER}.tar.gz" \
    "init-project-${VER}.zip" \
    install-init-project.sh install-init-project.ps1 install-init-project.cmd \
    > SHA256SUMS.txt
)

echo "==> ${TAG} em $(git rev-parse --short HEAD)"
if [[ "${ahead}" -gt 0 ]]; then
  echo "    origin/main está ${ahead} commit(s) atrás; a publicação também envia main."
fi
echo "    assets em ${OUT}:"
ls -1 "${OUT}"

if [[ "${DRY}" -eq 1 ]]; then
  echo "==> dry-run: nada foi tagueado, enviado ou publicado."
  exit 0
fi

if [[ ! -r /dev/tty ]]; then
  die "sem terminal interativo. Rode ./release-init-project.sh num terminal. Nada foi publicado."
fi

echo
read -r -p "Criar a tag ${TAG} e publicar a release no GitHub? [s/N] " resp </dev/tty
if [[ "${resp}" != "s" && "${resp}" != "S" ]]; then
  echo "Cancelado. Nada foi publicado."
  exit 0
fi

if [[ "${ahead}" -gt 0 ]]; then
  git push origin HEAD:main
fi
git tag -a "${TAG}" -m "${TAG}"
git push origin "refs/tags/${TAG}"
gh release create "${TAG}" \
  --verify-tag \
  --title "${TAG}" \
  --notes-file "${OUT}/NOTES.md" \
  "${OUT}/init-project-${VER}.tar.gz" \
  "${OUT}/init-project-${VER}.zip" \
  "${OUT}/install-init-project.sh" \
  "${OUT}/install-init-project.ps1" \
  "${OUT}/install-init-project.cmd" \
  "${OUT}/SHA256SUMS.txt"

echo "==> Release ${TAG} publicada: https://github.com/c3t4r4/Personal-MD-for-Claude/releases/tag/${TAG}"
