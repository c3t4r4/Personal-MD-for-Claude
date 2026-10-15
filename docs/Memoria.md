# Memória — initProjectsInstall

Última atualização: 2026-10-15

## Aprendizados

### Windows PowerShell 5.1 e acentos (contexto histórico)

O Windows 11 ainda abre `powershell.exe` na versão 5.1. Esse host lê um `.ps1` sem BOM como ANSI e quebra o português — por isso `install-init-project.ps1` foi gravado em UTF-8 com BOM e quebras CRLF, com o script pedindo a página de código 65001 no início.

Em 2026-10-15 o script foi reescrito e deixou de ter BOM e a configuração de `chcp 65001`/`[Console]::OutputEncoding` — decisão intencional, porque o alvo do script passou a incluir também `pwsh` 7 (que lê UTF-8 sem BOM sem o problema de interpretação ANSI do PowerShell 5.1). O risco antigo (acentos quebrados) volta a existir se o script for aberto **só** com `powershell.exe` 5.1 puro sem `pwsh` disponível — não foi testado nessa combinação específica após a reescrita.

### Detecção de bash simplificada (2026-10-15)

A lógica anterior de `Find-BashHost`/`Convert-ToBashPath`, que distinguia Git Bash de WSL e convertia `CLAUDE_CONFIG_DIR` para o formato de caminho de cada um, foi removida na reescrita do `.ps1`. Hoje a detecção é só `Get-Command bash` genérico no PATH, e o script chama `$scanSh` diretamente nesse bash. Se o `bash` resolvido for o do WSL e não enxergar o caminho do Windows corretamente, isso não é mais tratado explicitamente — o relatório de capacidades pode degradar nesse cenário específico.

### `.cmd` agora prefere `pwsh` (2026-10-15)

`install-init-project.cmd` testa `where pwsh` antes de `powershell.exe`; se `pwsh` estiver no PATH, é ele quem roda o `.ps1`. Isso também mudou o comportamento de pausa ao final: o `.cmd` atual sempre pausa com `pause` no fim, em vez da detecção antiga de clique duplo via `cmdcmdline`.

### RTK instalável por OS em ambos os instaladores (2026-10-15)

`install-init-project.sh` passou a oferecer instalação interativa de RTK por sistema operacional (Homebrew no macOS, script `curl | sh` no Linux, `winget` no Windows via Cygwin/MSYS), espelhando o que já existia só no `.ps1` para Windows. Ver RN-INSTALADOR-008 em `docs/RegrasNegocio.md`.

### `ai-memory` como backend de memória alternativo (2026-10-15)

Os templates empacotados (`_capacidades.md`, `commands/init-project.md`, `dist/init-project/CLAUDE.md`) passaram a reconhecer `ai-memory` como alternativa (ou complemento) a `claude-mem`. Os dois podem coexistir; nenhum substitui `docs/Memoria.md`, que continua o registro canônico versionado do projeto. O `~/.claude/CLAUDE.md` **instalado** (live) ainda não recebeu essa atualização — ela existe hoje só no pacote (`dist/init-project/`), à espera de uma reinstalação explícita via `install-init-project.sh`/`.ps1`.

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
| 2026-10-15 | Registrada a remoção intencional do BOM (alvo passou a incluir pwsh 7), a simplificação da detecção de bash, a preferência do `.cmd` por `pwsh`, RTK cross-OS em `install-init-project.sh` e `ai-memory` como backend de memória alternativo nos templates empacotados. |
