# Organograma — initProjectsInstall

Última atualização: 2026-10-06

## Relação entre as peças

```text
máquina de origem
  package-init-project.sh
        |
        v
  dist/init-project/  (18 arquivos)
        |
        +-- macOS/Linux --> install-init-project.sh --> ~/.claude
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
```

O `.cmd` não decide o que copiar. Ele só inicia o PowerShell. A verificação de capacidades, quando há Git Bash ou WSL, lê o `_scan.sh` já colocado em `%USERPROFILE%\.claude\templates\init-project\`.

## Histórico

| Data | Alteração |
| --- | --- |
| 2026-10-06 | Criado ao acrescentar o ramo Windows 11. |
