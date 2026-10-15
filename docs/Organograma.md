# Organograma — initProjectsInstall

Última atualização: 2026-10-15

## Relação entre as peças

```text
repositório (dist/ ao lado dos scripts, não mais ~/.claude)
  package-init-project.sh  <-- lê ~/.claude, preserva VERSION existente
        |
        v
  dist/init-project/  (18 arquivos + VERSION, metadado do pacote)
        |
        +-- macOS/Linux --> install-init-project.sh --> ~/.claude
        |                         |
        |                         v
        |                  checagem de atualização --> api.github.com (GitHub Releases, leitura)
        |
        +-- Windows 11  --> install-init-project.cmd
                                |
                                v
                         install-init-project.ps1
                                |
                                v
                         %USERPROFILE%\.claude
                                |
                                +-- CLAUDE.md
                                +-- commands/init-project.md
                                +-- templates/init-project/*
                                |
                                v
                         checagem de atualização --> api.github.com (GitHub Releases, leitura)

fluxo de release (separado, manual, rodado pelo mantenedor)
  bump de dist/init-project/VERSION + CHANGELOG.md
        |
        v
  release-init-project.sh  (valida shellcheck, FILES, git, pacote completo)
        |
        v
  tag vX.Y.Z + push + gh release create --> api.github.com (GitHub Releases, escrita)
```

O `.cmd` não decide o que copiar. Ele só inicia o PowerShell, preferindo `pwsh` quando o encontra no PATH e caindo para `powershell.exe` caso contrário. A verificação de capacidades só roda quando o `bash` resolvível no PATH é identificável como Git Bash ou WSL (com `CLAUDE_CONFIG_DIR` traduzido nesse segundo caso) — lê o `_scan.sh` já colocado em `%USERPROFILE%\.claude\templates\init-project\`. Qualquer outro `bash`, ou nenhum, pula a checagem com aviso.

## Histórico

| Data | Alteração |
| --- | --- |
| 2026-10-06 | Criado ao acrescentar o ramo Windows 11. |
| 2026-10-15 | Registrada a preferência do `.cmd` por `pwsh` sobre `powershell.exe`. |
| 2026-10-15 | Pacote padrão deixou de depender de `~/.claude`; adicionados o ramo de checagem de atualização (GitHub Releases, leitura) e o fluxo separado de release manual via `release-init-project.sh` (GitHub Releases, escrita). |
