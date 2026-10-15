# Memória — initProjectsInstall

Última atualização: 2026-10-06

## Aprendizados

### Windows PowerShell 5.1 e acentos

O Windows 11 ainda abre `powershell.exe` na versão 5.1. Esse host lê um `.ps1` sem BOM como ANSI e quebra o português. `install-init-project.ps1` é gravado em UTF-8 com BOM e quebras CRLF. No início, o script pede a página de código 65001.

### ExecutionPolicy

`Bypass` fica na linha do `powershell.exe -File` dentro de `install-init-project.cmd`. A política da máquina não é alterada.

### `_scan.sh` no Windows

O script de varredura não foi portado. Git Bash enxerga o perfil do Windows em `/c/Users/...`. WSL precisa de `CLAUDE_CONFIG_DIR` em `/mnt/c/Users/...`, senão a varredura olha o home Linux. Sem nenhum dos dois, a cópia dos 18 arquivos continua e o relatório avisa.

### winget

Depois que a pessoa responde `s`, o instalador chama `winget install --id rtk-ai.rtk --exact` e aceita os acordos de origem e de pacote. Esses aceites evitam um segundo prompt do winget para uma instalação que já foi confirmada. O `PATH` da sessão é relido do registro; um terminal já aberto pode continuar sem ver o `rtk` até ser reaberto.

### npx no PowerShell 5.1

`npx` no Windows é `npx.cmd`. A saída desse comando não pode ser atribuída a uma variável, porque o PowerShell mistura o texto do programa com o código de saída. O código fica em `$script:NpxExit`.

### Pasta padrão vazia

Se o instalador Windows roda sem argumento e `%USERPROFILE%\.claude\initProjectsInstall\dist\init-project` não existe, a pasta é criada e a checagem dos 18 arquivos falha em seguida. Nenhum arquivo do comando é instalado. No bash, o `mkdir` equivalente só dispara quando o argumento é a string literal `~/.claude/...` ainda com til; o caso sem argumento usa o caminho já expandido e não entra nesse `if`.

## Histórico

| Data | Alteração |
| --- | --- |
| 2026-10-06 | Registrados BOM, ExecutionPolicy, Git Bash/WSL, winget e npx.cmd. |
