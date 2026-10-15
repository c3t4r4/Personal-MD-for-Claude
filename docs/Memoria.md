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

### Skill `graphify` removida do pacote (2026-10-15)

Por decisão explícita do usuário, todas as menções a `graphify` (grafo de conhecimento, `graphify-out/`, comando `/graphify`, pacote Python `graphifyy`) foram removidas dos templates empacotados (`_capacidades.md`, `_checklist-entrevista.md`, `RAG.md.tpl.md`, `commands/init-project.md`, `dist/init-project/CLAUDE.md`) e de `_scan.sh` (exclusão de diretório, seção `[RAG]` do relatório e linha correspondente no resumo). Só `archify` (diagramas de arquitetura) continua documentado como skill relacionada a visualização/grafo. Se o pacote precisar reconhecer `graphify` de novo no futuro, reintroduzir a partir do histórico do Git em vez de recriar do zero.

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

### Causa raiz do caminho padrão hardcoded (2026-10-15)

`install-init-project.sh`, `install-init-project.ps1` e `package-init-project.sh` assumiam que o repositório estava clonado exatamente em `~/.claude/initProjectsInstall/`. Nesta máquina ele está em `~/Documents/Projects/IAProjects/Personal-MD-for-Claude/`, e `~/.claude/initProjectsInstall/` nem existe — por isso `install-init-project.sh` sem argumento falhava com "pasta de pacote não encontrada". O `dist/init-project/` já commitado no repositório nunca foi, de fato, gerado pelo `package-init-project.sh` como ele estava escrito (que publicava em `~/.claude/initProjectsInstall/dist`, não na raiz do repo). Fix: os três scripts resolvem `dist/init-project/` relativo à própria pasta do script (`$(dirname "$0")`/`$PSScriptRoot`), nunca mais a `~/.claude`. `CLAUDE_HOME` (`~/.claude`) continua sendo só o destino real da instalação — isso não mudou.

### `dist/init-project/` pode divergir de `~/.claude` local (descoberto em 2026-10-15)

Ao testar `package-init-project.sh` nesta máquina, reempacotar sobrescreveu vários templates do pacote (`CLAUDE.md`, `commands/init-project.md`, `_capacidades.md`, `_scan.sh` etc.) com conteúdo **mais antigo** do que o já commitado em `dist/init-project/` — porque o `~/.claude` local ainda não recebeu a reinstalação mencionada na entrada "`ai-memory` como backend de memória alternativo" abaixo. Revertido antes do commit (`git checkout --` nos arquivos afetados, mantendo só `VERSION`). Isso significa que, hoje, **reempacotar nesta máquina é destrutivo** para o conteúdo mais novo do pacote até que `~/.claude` seja atualizado (via `install-init-project.sh`) para bater com o que já está em `dist/init-project/`. Não corrigido nesta tarefa — registrado como pendência em `docs/Progresso.md`.

### Comparação de versão sem `sort -V` (2026-10-15)

A checagem de atualização (compara `VERSION` do pacote com a última GitHub Release) não usa `sort -V`: o `sort` BSD do macOS não tem essa flag (só a versão GNU tem). A comparação usa uma função pequena e portável (`version_gt` em bash, `Test-VersionGreaterThan` em PowerShell) que separa major.minor.patch e compara numericamente campo a campo, ignorando sufixos de pre-release/build (`-beta`, `+build`, etc. são descartados antes de comparar).

### `VERSION` vive só em `dist/init-project/VERSION` (2026-10-15)

Não existe mais um `VERSION` na raiz do repositório (uma primeira versão deste trabalho criou um, depois removida): a versão do pacote vive só em `dist/init-project/VERSION`, bump manual pelo mantenedor antes de rodar `release-init-project.sh`. Esse arquivo propositalmente **não entra** no array `FILES`/`$Files` dos três scripts — não é instalado em `~/.claude`, é só metadado do pacote lido pela checagem de atualização e por `release-init-project.sh`. `package-init-project.sh` preserva o `VERSION` já existente no pacote ao reempacotar, em vez de apagá-lo.

### `release-init-project.sh` adaptado de um projeto irmão (2026-10-15)

O usuário trouxe `release.sh` e `CHANGELOG.md` de um projeto irmão (`c3t4r4/Personal-MD-for-Cursor`, variante Cursor deste mesmo pacote) como referência — eles chegaram neste repositório por engano (outra sessão, provavelmente trabalhando nesse projeto irmão, escreveu no diretório errado). Adaptados para este repositório como `release-init-project.sh`: removida a referência a `dist/init-project/hooks/session-scan.sh` (não existe aqui), trocado o slug do repositório para `c3t4r4/Personal-MD-for-Claude`. Diferença importante de filosofia em relação à primeira versão deste script (descartada): **não há bump automático de versão** — o mantenedor edita `VERSION` e `CHANGELOG.md` manualmente antes de rodar o script, que só valida e publica. Nenhum workflow de CI/Actions dispara isso — é sempre o mantenedor, manualmente, com confirmação `[s/N]` no terminal.

### Detecção de Git Bash vs. WSL restaurada, de forma mais simples (2026-10-15)

A detecção genérica de `bash` (só `Get-Command bash`, sem distinguir a origem) podia rodar `_scan.sh capacidades` contra um `bash` do WSL sem `CLAUDE_CONFIG_DIR` traduzido — nesse caso o script lê o `$HOME` do Linux, não o do Windows, e o relatório sai errado em vez de avisar. Fix: classificação por padrão de caminho (`\Git\` → Git Bash, chama direto, porque resolve `$HOME` sozinho; `\System32\` → WSL, recebe `CLAUDE_CONFIG_DIR` convertido para `/mnt/<drive>/...`; qualquer outro padrão, inclusive Cygwin, degrada com aviso em vez de arriscar). Mais simples que a função `Find-BashHost`/`Convert-ToBashPath` removida na reescrita de 2026-10-15 anterior (que convertia caminhos completos para os dois hosts) — aqui só o `CLAUDE_CONFIG_DIR` é convertido, e só para WSL. Validado estaticamente via `pwsh` no macOS: `/bin/bash` nativo foi corretamente classificado como "nem Git Bash nem WSL" e a checagem foi pulada — não há como testar a classificação real de um `bash.exe` do Windows fora do Windows.

### Achados do Security Specialist aplicados (2026-10-15)

Dois achados não bloqueantes (média e baixa severidade) do Security Specialist, corrigidos ainda na mesma tarefa: (1) a string montada para `bash.exe -c "CLAUDE_CONFIG_DIR='...' '...' capacidades"` em `install-init-project.ps1` agora escapa aspas simples (`'\\''`) antes de interpolar os caminhos traduzidos — um perfil do Windows com aspas simples no caminho não quebra mais a citação do bash; (2) `Test-VersionGreaterThan` não lança mais exceção quando um segmento de versão não tem dígito nenhum (`[int]` de string vazia) — agora cai para `0`, igual ao `${a1:-0}` do lado bash, preservando o princípio de que a checagem de atualização é só informativa e nunca pode interromper o script sob `$ErrorActionPreference = 'Stop'`.

### Achado do Validator aplicado: `ConvertTo-WslPath` sem assumir unidade com letra (2026-10-15)

O Validator notou que `ConvertTo-WslPath` assumia todo `$HOME`/`CLAUDE_CONFIG_DIR` no formato `X:\...`; um perfil de rede/roaming com caminho UNC (`\\servidor\compartilhamento\...`) produziria um `/mnt/...` incorreto em silêncio — exatamente o resultado que a classificação Git Bash/WSL existe para evitar, só que por uma via diferente (bash corretamente identificado como WSL, mas `$HOME` em formato inesperado). Fix: a função agora retorna `$null` quando o caminho não casa com `^[A-Za-z]:\\`, e o chamador degrada com `AVISO` nesse caso, em vez de montar o comando `bash -c` com um caminho adivinhado.

## Histórico

| Data | Alteração |
| --- | --- |
| 2026-10-06 | Registrados BOM, ExecutionPolicy, Git Bash/WSL, winget e npx.cmd. |
| 2026-10-15 | Registrada a remoção intencional do BOM (alvo passou a incluir pwsh 7), a simplificação da detecção de bash, a preferência do `.cmd` por `pwsh`, RTK cross-OS em `install-init-project.sh` e `ai-memory` como backend de memória alternativo nos templates empacotados. |
| 2026-10-15 | Removida a skill `graphify` de todo o pacote (`dist/init-project/`), por decisão explícita do usuário — só `archify` permanece. |
| 2026-10-15 | Registrada a causa raiz do caminho padrão hardcoded, o drift entre `dist/init-project/` e `~/.claude` local descoberto ao testar, a ausência de `sort -V` no macOS, a decisão de manter `VERSION` só em `dist/init-project/`, a adaptação de `release.sh`/`CHANGELOG.md` trazidos de `Personal-MD-for-Cursor`, e a restauração mais simples da detecção Git Bash vs. WSL. |
| 2026-10-15 | Aplicados os achados não bloqueantes do Security Specialist (escape de aspas simples no bloco WSL do `.ps1`; `Test-VersionGreaterThan` não lança mais exceção com segmento sem dígito) e do Validator (`ConvertTo-WslPath` recusa caminho que não seja unidade com letra, em vez de adivinhar). |
