# Arquitetura — initProjectsInstall

Última atualização: 2026-10-06

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
| `_scan.sh` | Bash de leitura. No Windows é executado pelo Git Bash ou pelo WSL, depois da cópia. |

## Fluxo de instalação no Windows

1. O usuário entrega a pasta do pacote, ou o script usa a pasta padrão sob `%USERPROFILE%\.claude\initProjectsInstall\dist\init-project`.
2. Os 18 arquivos são conferidos. Qualquer ausência encerra o processo antes da cópia.
3. Cada arquivo novo é copiado. Cada arquivo já presente espera `s`, `N` ou `d`, salvo quando não há terminal: nesse caso permanece.
4. O resumo imprime contagens. Em seguida o relatório de RTK, archify, hook e capacidades roda sem mudar o código de saída.

## Decisão

PowerShell 5.1 é o host porque o Windows 11 já o traz. O `.cmd` existe para a ExecutionPolicy, não para duplicar a lógica de cópia.

## Histórico

| Data | Alteração |
| --- | --- |
| 2026-10-06 | Criado com o instalador Windows 11 ao lado do instalador bash. |
