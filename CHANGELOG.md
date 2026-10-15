# Changelog

Formato: [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/). Versionamento: [SemVer](https://semver.org/lang/pt-BR/).

A versão do pacote vive em `dist/init-project/VERSION`. A release no GitHub é a tag `v<versão>`, criada por `./release-init-project.sh` (não por push), com o conteúdo de `dist/init-project/` anexado em `.tar.gz` e `.zip`, junto dos instaladores e de `SHA256SUMS.txt`.

## [Unreleased]

## [1.0.0] — 2026-10-15

### Corrigido

- `install-init-project.sh`, `install-init-project.ps1` e `package-init-project.sh` paravam de encontrar `dist/init-project/` quando o repositório não estava clonado em `~/.claude/initProjectsInstall` — o caminho padrão do pacote era hardcoded para lá. Agora os três resolvem `dist/init-project/` relativo à própria localização do script.
- `install-init-project.ps1`: a verificação de componentes agora distingue Git Bash de WSL ao localizar `bash` no PATH e, no caso WSL, traduz `CLAUDE_CONFIG_DIR` para o caminho `/mnt/<drive>/...` — sem isso, `_scan.sh capacidades` podia rodar silenciosamente contra o `$HOME` errado (o do Linux, não o do Windows) em vez de avisar com clareza.

### Adicionado

- `VERSION` dentro do pacote (`dist/init-project/VERSION`) e aviso de atualização disponível (consulta a última GitHub Release) ao final de `install-init-project.sh` e `install-init-project.ps1` — somente informativo, nunca bloqueia a instalação.
- `release-init-project.sh`: valida (shellcheck, paridade do array `FILES` entre os três instaladores, pacote completo, branch `main`, árvore limpa, tag inexistente local e remota, `origin/main` em dia) e publica a release manualmente — nunca a partir de push ou CI.

[Unreleased]: https://github.com/c3t4r4/Personal-MD-for-Claude/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/c3t4r4/Personal-MD-for-Claude/releases/tag/v1.0.0
