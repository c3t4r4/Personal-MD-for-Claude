# Arquitetura — initProjectsInstall

Última atualização: 2026-10-15

## Papel deste repositório

Este repositório leva o comando `/init-project` de uma máquina para outra. Não há serviço em execução. O diagrama do fluxo está em `docs/arquitetura.html`.

## Peças

| Peça | Função |
| --- | --- |
| `package-init-project.sh` | Lê os 18 arquivos em `~/.claude` e publica `dist/init-project/`. |
| `dist/init-project/` | Pacote. A estrutura relativa é a mesma do destino. |
| `install-init-project.sh` | Instala o pacote em `~/.claude` no macOS e no Linux. |
| `install-init-project.ps1` | Instala o mesmo pacote em `%USERPROFILE%\.claude` no Windows 11. |
| `install-init-project.cmd` | Abre o `.ps1` com `ExecutionPolicy Bypass` só nesse processo. |
| `_scan.sh` | Bash de leitura. No Windows é executado por qualquer `bash` resolvível no PATH (tipicamente Git Bash ou WSL), depois da cópia. |

## Fluxo de instalação no Windows

1. O usuário entrega a pasta do pacote, ou o script usa a pasta padrão sob `%USERPROFILE%\.claude\initProjectsInstall\dist\init-project`.
2. Os 18 arquivos são conferidos. Qualquer ausência encerra o processo antes da cópia.
3. Cada arquivo novo é copiado. Cada arquivo já presente espera `s`, `N` ou `d`, salvo quando não há terminal: nesse caso permanece.
4. O resumo imprime contagens. Em seguida o relatório de RTK, archify, hook e capacidades roda sem mudar o código de saída.

## Decisão

PowerShell 5.1 continua o piso garantido, porque o Windows 11 já o traz. A reescrita de 2026-10-15 passou a suportar também `pwsh` 7+ (shebang `#!/usr/bin/env pwsh`), usado principalmente para desenvolver e testar o script fora do Windows — sem tornar o PowerShell 7 um requisito. Essa mudança de alvo também tornou dispensável o BOM UTF-8 e o `chcp 65001` que o script tinha antes (ver `docs/Memoria.md`). O `.cmd` existe para a ExecutionPolicy, não para duplicar a lógica de cópia; ele prefere `pwsh` quando presente no PATH, caindo para `powershell.exe` caso contrário.

## Histórico

| Data | Alteração |
| --- | --- |
| 2026-10-06 | Criado com o instalador Windows 11 ao lado do instalador bash. |
| 2026-10-15 | Registrado suporte a `pwsh` 7 lado a lado com PowerShell 5.1, detecção de `bash` simplificada (sem distinguir Git Bash de WSL) e preferência do `.cmd` por `pwsh`. |
