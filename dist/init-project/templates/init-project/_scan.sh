#!/usr/bin/env bash
# _scan.sh — detecção somente-leitura para /init-project
#
# Uso:
#   _scan.sh capacidades                 → o que existe no ambiente (agentes, skills, plugins)
#   _scan.sh projeto [caminho] [--no-cache]  → o que existe no projeto (stack, docker, git, telas)
#   _scan.sh sessao  [caminho] [--no-cache]  → resumo compacto para o hook SessionStart
#
# REGRAS INVIOLÁVEIS:
#   - Somente leitura SOBRE O PROJETO. Não cria, não altera, não remove nada no
#     repositório analisado. A única escrita do script é o próprio cache, em
#     $CLAUDE_HOME/.scan-cache.
#   - NUNCA imprime conteúdo de .env, secret, chave, token ou credencial.
#     Arquivos de ambiente aparecem apenas como NOME e estado de versionamento.
#     Como o cache guarda exatamente o que seria impresso, a regra vale para ele.

set -uo pipefail

CLAUDE_HOME="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
CACHE_DIR="$CLAUDE_HOME/.scan-cache"
CACHE_TTL=21600   # 6h — rede de segurança para o que o fingerprint não captura
CACHE_MAX_DIAS=30

# ---------------------------------------------------------------- utilitários

# Um agente/skill só carrega se tiver `name:` E `description:` no PRIMEIRO nível
# do frontmatter. Campo aninhado (ex.: metadata.description) não conta.
fm_valido() {
  awk '
    NR==1 && $0!="---" { exit 1 }
    NR>1  && $0=="---" { if (n && d) exit 0; else exit 1 }
    NR>1  && index($0,"name:")==1        { n=1 }
    NR>1  && index($0,"description:")==1 { d=1 }
    END { if (n && d) exit 0; else exit 1 }
  ' "$1" 2>/dev/null
}

fm_nome() {
  awk '
    NR==1 && $0!="---" { exit }
    NR>1  && $0=="---" { exit }
    NR>1  && index($0,"name:")==1 { sub(/^name:[ \t]*/,""); gsub(/["\047]/,""); print; exit }
  ' "$1" 2>/dev/null
}

existe() { [ -e "$1" ] && echo "presente" || echo "ausente"; }

# ---------------------------------------------------------------------- cache
#
# Cacheia apenas o modo `projeto` (e, por tabela, `sessao`). O modo
# `capacidades` fica de fora de propósito: sua invalidação natural seria o mtime
# de agents/ e skills/, que NÃO muda quando um frontmatter é editado no lugar —
# justamente o caso que o scan precisa detectar.

# mtime portátil: BSD (macOS) e GNU. Arquivo ausente vale 0.
mtime() {
  [ -e "$1" ] || { echo 0; return; }
  stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null || echo 0
}

cache_chave() {
  printf '%s-%s' "$(basename "$1")" "$(printf '%s' "$1" | cksum | awk '{print $1}')"
}

# Fingerprint estrutural. .git/HEAD sozinho não basta: não se move quando um
# arquivo é editado, e nem todo projeto é repositório Git.
cache_fingerprint() {
  local abs="$1" p
  for p in "$abs/.git/HEAD" "$abs/.git/index" "$abs" "$abs/docs" "$abs/.claude" "$0"; do
    printf '%s:' "$(mtime "$p")"
  done
}

cache_ler() {
  local f="$CACHE_DIR/$1.out" s="$CACHE_DIR/$1.stamp" fp="$2" idade
  [ -f "$f" ] && [ -f "$s" ] || return 1
  [ "$(cat "$s" 2>/dev/null)" = "$fp" ] || return 1
  idade=$(( $(date +%s) - $(mtime "$f") ))
  [ "$idade" -ge 0 ] && [ "$idade" -lt "$CACHE_TTL" ] || return 1
  cat "$f"
}

# Lê o conteúdo da entrada padrão. Gravação atômica: sessão interrompida não
# deixa cache truncado.
cache_gravar() {
  local f="$CACHE_DIR/$1.out" s="$CACHE_DIR/$1.stamp" fp="$2"
  mkdir -p "$CACHE_DIR" 2>/dev/null || { cat >/dev/null; return 1; }
  cat > "$f.tmp" 2>/dev/null || return 1
  mv -f "$f.tmp" "$f" 2>/dev/null || return 1
  printf '%s' "$fp" > "$s.tmp" 2>/dev/null && mv -f "$s.tmp" "$s" 2>/dev/null
  # Limpeza oportunista: o diretório não pode crescer sem limite.
  find "$CACHE_DIR" -maxdepth 1 -type f \
       \( -name '*.out' -o -name '*.stamp' -o -name '*.tmp' \) \
       -mtime +"$CACHE_MAX_DIAS" -delete 2>/dev/null
  return 0
}

# scan_projeto com cache. Ecoa a saída, venha do cache ou da varredura.
projeto_cacheado() {
  local abs="$1" nocache="$2" chave fp saida
  chave="$(cache_chave "$abs")"
  fp="$(cache_fingerprint "$abs")"
  if [ "$nocache" != "sim" ] && saida="$(cache_ler "$chave" "$fp")"; then
    printf '%s\n' "$saida"
    return 0
  fi
  saida="$(scan_projeto "$abs")" || return 1
  printf '%s\n' "$saida" | cache_gravar "$chave" "$fp"
  printf '%s\n' "$saida"
}

# ------------------------------------------------------------- capacidades

scan_capacidades() {
  echo "[AGENTES]"
  local total=0 validos=0
  for dir in "$CLAUDE_HOME/agents" "./.claude/agents" "$CLAUDE_HOME"/plugins/cache/*/*/*/agents; do
    [ -d "$dir" ] || continue
    for f in "$dir"/*.md; do
      [ -f "$f" ] || continue
      total=$((total + 1))
      if fm_valido "$f"; then
        validos=$((validos + 1))
        echo "ok: $(fm_nome "$f")"
      else
        echo "INVALIDO: $(basename "$f") (sem name: ou description: no topo do frontmatter)"
      fi
    done
  done
  echo "total: $total"
  echo "carregaveis: $validos"

  echo
  echo "[SKILLS]"
  for dir in "$CLAUDE_HOME/skills" "./.claude/skills" "$CLAUDE_HOME"/plugins/cache/*/*/*/skills; do
    [ -d "$dir" ] || continue
    for s in "$dir"/*/SKILL.md; do
      [ -f "$s" ] || continue
      # O harness expõe a skill pelo NOME DO DIRETÓRIO, não pelo `name:` do
      # frontmatter. Ex.: skills/version-bump/SKILL.md declara
      # `name: claude-code-plugin-release`, mas o registro oferece
      # `version-bump`. Para agentes é o oposto — lá vale o `name:`.
      local nome
      nome="$(basename "$(dirname "$s")")"
      case "$dir" in
        */plugins/cache/*) echo "$nome (plugin)" ;;
        ./.claude/*)       echo "$nome (projeto)" ;;
        *)                 echo "$nome (usuario)" ;;
      esac
    done
  done

  echo
  echo "[PLUGINS_HABILITADOS]"
  if [ -f "$CLAUDE_HOME/settings.json" ] && command -v python3 >/dev/null 2>&1; then
    python3 - "$CLAUDE_HOME/settings.json" <<'PY' 2>/dev/null || echo "indisponivel"
import json,sys
try:
    d=json.load(open(sys.argv[1]))
except Exception:
    sys.exit(1)
for k,v in (d.get("enabledPlugins") or {}).items():
    if v: print(k)
PY
  else
    echo "indisponivel"
  fi

  echo
  echo "[MARKETPLACES]"
  if [ -f "$CLAUDE_HOME/plugins/known_marketplaces.json" ] && command -v python3 >/dev/null 2>&1; then
    python3 - "$CLAUDE_HOME/plugins/known_marketplaces.json" <<'PY' 2>/dev/null || echo "indisponivel"
import json,sys
try:
    d=json.load(open(sys.argv[1]))
except Exception:
    sys.exit(1)
for k,v in d.items():
    print(f"{k} = {v.get('source',{}).get('repo','?')}")
PY
  else
    echo "indisponivel"
  fi

  echo
  echo "[NOTA]"
  echo "MCP claude-mem nao e verificavel por script — testar chamando list_corpora."
}

# ----------------------------------------------------------------- projeto

scan_projeto() {
  local root="${1:-.}"
  cd "$root" 2>/dev/null || { echo "erro: caminho inacessivel: $root"; return 1; }

  echo "[PROJETO]"
  echo "raiz: $(pwd)"
  echo "nome: $(basename "$(pwd)")"

  local PRUNE='-name node_modules -o -name .git -o -name target -o -name dist -o -name build
               -o -name .next -o -name vendor -o -name venv -o -name .venv
               -o -name __pycache__ -o -name graphify-out -o -name coverage'

  echo
  echo "[MANIFESTOS]"
  # shellcheck disable=SC2086
  local manifestos
  manifestos=$(find . -maxdepth 3 \( $PRUNE \) -prune -o -type f \( \
      -name package.json -o -name requirements.txt -o -name pyproject.toml \
      -o -name go.mod -o -name Cargo.toml -o -name composer.json -o -name Gemfile \
      -o -name '*.csproj' -o -name pom.xml -o -name build.gradle -o -name build.gradle.kts \
    \) -print 2>/dev/null | sed 's|^\./||' | sort)
  [ -n "$manifestos" ] && printf '%s\n' "$manifestos"

  echo
  echo "[LOCKS]"
  # shellcheck disable=SC2086
  local locks
  locks=$(find . -maxdepth 3 \( $PRUNE \) -prune -o -type f \( \
      -name package-lock.json -o -name yarn.lock -o -name pnpm-lock.yaml \
      -o -name bun.lockb -o -name poetry.lock -o -name Cargo.lock -o -name composer.lock \
    \) -print 2>/dev/null | sed 's|^\./||' | sort)
  [ -n "$locks" ] && printf '%s\n' "$locks"

  echo
  echo "[DOCKER]"
  # shellcheck disable=SC2086
  find . -maxdepth 3 \( $PRUNE \) -prune -o -type f \( \
      -name 'Dockerfile*' -o -name 'docker-compose*.yml' -o -name 'docker-compose*.yaml' \
      -o -name 'docker-stack*.yml' -o -name '.dockerignore' \
    \) -print 2>/dev/null | sed 's|^\./||' | sort

  echo
  echo "[BUILD]"
  for f in Makefile justfile Taskfile.yml turbo.json nx.json; do
    [ -f "$f" ] && echo "$f"
  done

  echo
  echo "[CODIGO]"
  local app_dirs=0
  for d in src app pages frontend backend server api routes controllers components lib crates cmd internal; do
    if [ -d "$d" ]; then
      echo "$d/"
      app_dirs=$((app_dirs + 1))
    fi
  done

  echo
  echo "[TESTES]"
  # Diretórios de teste em qualquer nível útil (monorepo, workspace de crates).
  # shellcheck disable=SC2086
  find . -maxdepth 3 \( $PRUNE \) -prune -o -type d \( \
      -name tests -o -name test -o -name e2e -o -name __tests__ \
      -o -name spec -o -name cypress -o -name playwright \
    \) -print 2>/dev/null | sed 's|^\./||' | sort | head -20
  local n_test
  # shellcheck disable=SC2086
  n_test=$(find . \( $PRUNE \) -prune -o -type f \( \
      -name '*.test.*' -o -name '*.spec.*' -o -name '*_test.go' \
      -o -name 'test_*.py' -o -name '*_test.rs' -o -name '*Test.java' \
    \) -print 2>/dev/null | wc -l | tr -d ' ')
  echo "arquivos_de_teste: $n_test"
  # Só varre em busca de teste inline Rust se o projeto já deu sinal de ser
  # Rust (Cargo.toml/Cargo.lock encontrado acima) — evita percorrer a árvore
  # inteira (inclusive node_modules/.git, sem exclusão nesta chamada) em todo
  # projeto não-Rust. --exclude-dir é defesa adicional para quando roda.
  if printf '%s\n%s\n' "$manifestos" "$locks" | grep -q 'Cargo\.'; then
    if grep -rlsq --include='*.rs' \
        --exclude-dir={node_modules,.git,target,dist,build,.next,vendor,venv,.venv,__pycache__,graphify-out,coverage} \
        '#\[cfg(test)\]' . 2>/dev/null; then
      echo "testes_inline_rust: sim"
    fi
  fi

  echo
  echo "[BANCO]"
  # shellcheck disable=SC2086
  find . -maxdepth 4 \( $PRUNE \) -prune -o \( \
      -name 'schema.prisma' -o -name migrations -o -name migrate -o -name alembic \
      -o -name 'schema.rb' -o -name 'diesel.toml' \
    \) -print 2>/dev/null | sed 's|^\./||' | sort | head -20

  echo
  echo "[API]"
  # shellcheck disable=SC2086
  find . -maxdepth 4 \( $PRUNE \) -prune -o -type f \( \
      -name 'openapi.*' -o -name 'swagger.*' -o -name '*.proto' -o -name 'schema.graphql' \
    \) -print 2>/dev/null | sed 's|^\./||' | sort | head -20

  echo
  echo "[AMBIENTE]"
  # Apenas nomes e estado. Nenhum conteudo e lido.
  for f in .gitignore .gitattributes .env.example .env.sample .editorconfig; do
    echo "$f: $(existe "$f")"
  done
  local env_alerta="nao"
  for f in .env .env.local .env.production .env.development; do
    if [ -f "$f" ]; then
      if git rev-parse --is-inside-work-tree >/dev/null 2>&1 && git check-ignore -q "$f" 2>/dev/null; then
        echo "$f: presente (ignorado pelo git)"
      else
        echo "$f: presente — *** NAO IGNORADO PELO GIT ***"
        env_alerta="sim"
      fi
    fi
  done
  echo "alerta_env_versionado: $env_alerta"

  echo
  echo "[GOVERNANCA]"
  echo "CLAUDE.md: $(existe CLAUDE.md)"
  echo ".claude/: $(existe .claude)"
  echo ".claude/plans/: $(existe .claude/plans)"
  echo ".claude/settings.local.json: $(existe .claude/settings.local.json)"
  echo "README.md: $(existe README.md)"
  for d in RegrasNegocio Arquitetura Organograma RAG Harness Progresso Memoria API Frontend Auth Infraestrutura; do
    echo "docs/$d.md: $(existe "docs/$d.md")"
  done

  echo
  echo "[RAG]"
  echo "graphify-out/: $(existe graphify-out)"

  echo
  echo "[GIT]"
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "repositorio: sim"
    echo "branch: $(git branch --show-current 2>/dev/null || echo '(destacado)')"
    echo "branches: $(git branch 2>/dev/null | wc -l | tr -d ' ')"
    echo "remotes: $(git remote 2>/dev/null | tr '\n' ' ' | sed 's/ $//')"
    echo "alteracoes_nao_commitadas: $(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
    echo "commits: $(git rev-list --count HEAD 2>/dev/null || echo 0)"
  else
    echo "repositorio: nao"
  fi

  echo
  echo "[VOLUME]"
  local n_cod
  # shellcheck disable=SC2086
  n_cod=$(find . \( $PRUNE \) -prune -o -type f \( \
      -name '*.js' -o -name '*.ts' -o -name '*.jsx' -o -name '*.tsx' -o -name '*.vue' \
      -o -name '*.svelte' -o -name '*.py' -o -name '*.rs' -o -name '*.go' -o -name '*.rb' \
      -o -name '*.php' -o -name '*.java' -o -name '*.kt' -o -name '*.swift' -o -name '*.cs' \
    \) -print 2>/dev/null | wc -l | tr -d ' ')
  echo "arquivos_codigo: $n_cod"
  echo "dirs_aplicacao: $app_dirs"
  if [ "$n_cod" -gt 500 ] || [ "$app_dirs" -gt 3 ]; then
    echo "sugerir_delegacao: sim"
  else
    echo "sugerir_delegacao: nao"
  fi
}

# ----------------------------------------------------------------- sessao
#
# Resumo compacto para o hook SessionStart. Reaproveita o `projeto` cacheado.

# Seção do relatório, sem o cabeçalho. Lê da entrada padrão.
_secao() { awk -v s="[$1]" 'index($0,s)==1 {f=1; next} /^\[/ {f=0} f && NF {print}'; }

# Valor de uma linha `chave: valor`. Lê da entrada padrão.
_campo() { awk -v k="$1: " 'index($0,k)==1 { print substr($0, length(k)+1); exit }'; }

# Vale a pena falar deste diretório? A checagem é barata e vem ANTES da
# varredura: rodar `find` em $HOME ou /tmp seria caro e inútil.
sessao_relevante() {
  local abs="$1" m
  [ "$abs" = "$HOME" ] || [ "$abs" = "/" ] && return 1
  git -C "$abs" rev-parse --is-inside-work-tree >/dev/null 2>&1 && return 0
  [ -f "$abs/CLAUDE.md" ] && return 0
  for m in package.json requirements.txt pyproject.toml go.mod Cargo.toml \
           composer.json Gemfile pom.xml build.gradle build.gradle.kts; do
    [ -f "$abs/$m" ] && return 0
  done
  return 1
}

scan_sessao() {
  local abs="$1" nocache="$2" dados v par d
  sessao_relevante "$abs" || return 0

  dados="$(projeto_cacheado "$abs" "$nocache")" || return 0
  [ -n "$dados" ] || return 0

  echo "[CONTEXTO_DO_PROJETO]"
  echo "nome: $(printf '%s\n' "$dados" | _campo nome)"
  echo "raiz: $(printf '%s\n' "$dados" | _campo raiz)"

  v="$(printf '%s\n' "$dados" | _secao MANIFESTOS | tr '\n' ' ' | sed 's/ $//')"
  echo "manifestos: ${v:-nenhum}"

  v="$(printf '%s\n' "$dados" | _secao CODIGO | tr '\n' ' ' | sed 's/ $//')"
  echo "dirs_aplicacao: ${v:-nenhum}"

  for par in DOCKER:docker BANCO:banco API:api; do
    v="$(printf '%s\n' "$dados" | _secao "${par%%:*}" | head -3 | tr '\n' ' ' | sed 's/ $//')"
    echo "${par##*:}: ${v:-ausente}"
  done

  echo "arquivos_de_teste: $(printf '%s\n' "$dados" | _campo arquivos_de_teste)"

  v=""
  for d in "CLAUDE.md" "docs/RegrasNegocio.md" "docs/Arquitetura.md" "docs/Organograma.md" "docs/Progresso.md"; do
    [ "$(printf '%s\n' "$dados" | _campo "$d")" = "presente" ] && v="$v $d"
  done
  echo "governanca:${v:- nenhuma (considere /init-project)}"

  if [ "$(printf '%s\n' "$dados" | _campo repositorio)" = "sim" ]; then
    echo "git: branch $(printf '%s\n' "$dados" | _campo branch), \
$(printf '%s\n' "$dados" | _campo alteracoes_nao_commitadas) alteracao(oes) nao commitada(s)"
  else
    echo "git: nao versionado"
  fi

  echo "graphify-out: $(printf '%s\n' "$dados" | _campo 'graphify-out/')"

  if [ "$(printf '%s\n' "$dados" | _campo alerta_env_versionado)" = "sim" ]; then
    echo "ALERTA: ha arquivo .env NAO ignorado pelo git"
  fi
}

# -------------------------------------------------------------------- main

# Argumentos: <modo> [caminho] [--no-cache], em qualquer ordem para as flags.
modo="${1:-}"
shift 2>/dev/null || true
caminho="."
nocache="nao"
for arg in "$@"; do
  case "$arg" in
    --no-cache) nocache="sim" ;;
    -*)         echo "opcao desconhecida: $arg" >&2; exit 2 ;;
    *)          caminho="$arg" ;;
  esac
done

resolver() { cd "$1" 2>/dev/null && pwd; }

case "$modo" in
  capacidades)
    scan_capacidades
    ;;
  projeto)
    abs="$(resolver "$caminho")" || { echo "erro: caminho inacessivel: $caminho"; exit 1; }
    projeto_cacheado "$abs" "$nocache"
    ;;
  sessao)
    # Hook nunca pode atrapalhar a abertura da sessão: falha em silêncio.
    abs="$(resolver "$caminho")" || exit 0
    scan_sessao "$abs" "$nocache" 2>/dev/null
    exit 0
    ;;
  *)
    echo "uso: _scan.sh capacidades" >&2
    echo "     _scan.sh projeto [caminho] [--no-cache]" >&2
    echo "     _scan.sh sessao  [caminho] [--no-cache]" >&2
    exit 2
    ;;
esac
