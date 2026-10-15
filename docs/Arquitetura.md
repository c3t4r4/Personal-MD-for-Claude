# Arquitetura — initProjectsInstall

Última atualização: 2026-10-15

## Papel deste repositório

Este repositório leva o comando `/init-project` de uma máquina para outra. Não há serviço em execução. O diagrama do fluxo está em `docs/arquitetura.html`.

## Peças

| Peça | Função |
| --- | --- |
| `package-init-project.sh` | Lê os 18 arquivos em `~/.claude`, publica `dist/init-project/` ao lado de si mesmo e preserva o `VERSION` já existente no pacote ao reempacotar. |
| `dist/init-project/` | Pacote. A estrutura relativa é a mesma do destino. Inclui `VERSION` (metadado do pacote, mantido manualmente — não é um dos 18 arquivos instalados). |
| `install-init-project.sh` | Instala o pacote em `~/.claude` no macOS e no Linux. Resolve o pacote padrão (`dist/init-project/`) relativo à própria pasta. Ao final, avisa (sem bloquear) se há uma versão mais nova publicada. |
| `install-init-project.ps1` | Instala o mesmo pacote em `%USERPROFILE%\.claude` no Windows 11. Mesma resolução de caminho e mesmo aviso de atualização que `install-init-project.sh`. |
| `install-init-project.cmd` | Abre o `.ps1` com `ExecutionPolicy Bypass` só nesse processo. Não referencia `dist/` — não foi afetado pela mudança de caminho padrão. |
| `release-init-project.sh` | Ferramenta do mantenedor, rodada manualmente: valida (shellcheck, paridade de `FILES`, pacote completo, git limpo) e publica a tag + GitHub Release com os assets do pacote. Nunca dispara a partir de push/commit/CI. |
| `CHANGELOG.md` | Pré-requisito da release: precisa ter uma seção `## [X.Y.Z]` batendo com `dist/init-project/VERSION` antes de `release-init-project.sh` publicar. |
| `_scan.sh` | Bash de leitura. No Windows só é executado quando o `bash` do PATH é identificável como Git Bash ou WSL (com `CLAUDE_CONFIG_DIR` traduzido nesse segundo caso); qualquer outro caso degrada com aviso em vez de arriscar um relatório incorreto. |
| `api.github.com` (GitHub Releases API) | Integração externa só de leitura, usada pelos dois instaladores para a checagem de atualização — e de escrita, usada por `release-init-project.sh` (via `gh`) para publicar a release. Nenhuma chamada é obrigatória para a instalação em si. |

## Fluxo de instalação no Windows

1. O usuário entrega a pasta do pacote, ou o script usa a pasta padrão `dist\init-project\` ao lado de `install-init-project.ps1` (gerada por `package-init-project.sh`).
2. Os 18 arquivos são conferidos. Qualquer ausência encerra o processo antes da cópia.
3. Cada arquivo novo é copiado. Cada arquivo já presente espera `s`, `N` ou `d`, salvo quando não há terminal: nesse caso permanece.
4. O resumo imprime contagens. Em seguida o relatório de RTK, archify, hook e capacidades roda sem mudar o código de saída, seguido da checagem de atualização (comparação de `VERSION` com a última GitHub Release).

## Fluxo de release (manual)

1. O mantenedor faz bump manual de `dist/init-project/VERSION` e adiciona a seção `## [X.Y.Z]` em `CHANGELOG.md`, commitando os dois em `main`.
2. `./release-init-project.sh` valida shellcheck, paridade de `FILES` entre os três instaladores, pacote completo, branch `main`, árvore limpa, tag inexistente (local e remota) e `origin/main` em dia.
3. Com a validação ok, empacota `dist/init-project/` em `.tar.gz`+`.zip`, copia os três instaladores e gera `SHA256SUMS.txt`.
4. Só com confirmação `[s/N]` no terminal: cria a tag anotada, dá push da tag (e de `main`, se à frente) e publica a GitHub Release com esses assets.

## Decisão

PowerShell 5.1 continua o piso garantido, porque o Windows 11 já o traz. A reescrita de 2026-10-15 passou a suportar também `pwsh` 7+ (shebang `#!/usr/bin/env pwsh`), usado principalmente para desenvolver e testar o script fora do Windows — sem tornar o PowerShell 7 um requisito. Essa mudança de alvo também tornou dispensável o BOM UTF-8 e o `chcp 65001` que o script tinha antes (ver `docs/Memoria.md`). O `.cmd` existe para a ExecutionPolicy, não para duplicar a lógica de cópia; ele prefere `pwsh` quando presente no PATH, caindo para `powershell.exe` caso contrário.

O caminho padrão do pacote (`dist/init-project/`) passou a ser resolvido relativo à própria pasta do script, não mais a `~/.claude`/`%USERPROFILE%\.claude`: o pacote de origem e o destino da instalação são coisas diferentes, e amarrar o primeiro ao segundo só fazia sentido se o repositório estivesse clonado exatamente em `~/.claude/initProjectsInstall` — o que não é garantido (nem era o caso na máquina onde o bug foi encontrado). A publicação de release é deliberadamente manual (`release-init-project.sh`, rodado pelo mantenedor) — nenhum workflow de CI/Actions a dispara a partir de um push ou commit.

## Histórico

| Data | Alteração |
| --- | --- |
| 2026-10-06 | Criado com o instalador Windows 11 ao lado do instalador bash. |
| 2026-10-15 | Registrado suporte a `pwsh` 7 lado a lado com PowerShell 5.1, detecção de `bash` simplificada (sem distinguir Git Bash de WSL) e preferência do `.cmd` por `pwsh`. |
| 2026-10-15 | Caminho padrão do pacote passou a ser relativo ao próprio script (não mais a `~/.claude`). Adicionados `VERSION`, checagem de atualização via GitHub Release nos dois instaladores, `release-init-project.sh` e `CHANGELOG.md`. Detecção de Git Bash vs. WSL restaurada em `install-init-project.ps1`, com tradução de `CLAUDE_CONFIG_DIR` só para WSL. |
