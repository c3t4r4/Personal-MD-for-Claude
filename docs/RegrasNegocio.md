# Regras de Negócio — initProjectsInstall

> Memória viva das regras de instalação do comando `/init-project`.

Última atualização: 2026-10-15

---

## Como usar este documento

Antes de alterar o que o instalador copia, pergunta ou recusa, ler as regras `confirmada` abaixo. Se a mudança as contradisser, parar e perguntar.

Não apagar regra. Regra que deixar de valer fica `revogada`, com data e motivo.

### Status

| Status | Significado |
| --- | --- |
| `confirmada` | Pedida ao replicar `install-init-project.sh` no Windows 11, ou explícita nos comentários desse script. |
| `⚠ inferida` | Extraída de código sem confirmação. Não tratar como verdade. |
| `a definir` | Ainda não decidida. |
| `revogada` | Histórica. |

---

## Glossário

| Termo | Significado | Onde aparece |
| --- | --- | --- |
| Pacote | Pasta com os 18 arquivos do `/init-project` | `dist/init-project/`, argumento do instalador |
| Destino | Configuração global do Claude Code | `~/.claude` ou `%USERPROFILE%\.claude` |
| TTY | Terminal em que o usuário pode responder | `/dev/tty` no bash; console não redirecionado no PowerShell |

---

## Índice de telas

Não há telas. As regras são do instalador de linha de comando.

---

## Regras

### RN-INSTALADOR-001 — Integridade antes da cópia

- **Status:** `confirmada`
- **Enunciado:** Os 18 caminhos relativos precisam existir como arquivo na pasta do pacote. Se faltar algum, o instalador termina com erro e não copia nenhum deles para o destino do comando.
- **Rastreabilidade:** `install-init-project.sh`, `install-init-project.ps1`

### RN-INSTALADOR-002 — Arquivo novo

- **Status:** `confirmada`
- **Enunciado:** Se o caminho ainda não existe no destino, o arquivo é copiado sem pergunta.
- **Rastreabilidade:** `install-init-project.sh`, `install-init-project.ps1`

### RN-INSTALADOR-003 — Arquivo existente

- **Status:** `confirmada`
- **Enunciado:** Se o destino já tem o arquivo, o instalador pergunta `Sobrescrever? [s/N/d=ver diff]`, mesmo quando o conteúdo é idêntico. `s` sobrescreve, `d` mostra o diff e pergunta de novo, qualquer outra resposta mantém o arquivo.
- **Rastreabilidade:** `install-init-project.sh`, `install-init-project.ps1`

### RN-INSTALADOR-004 — Sem terminal interativo

- **Status:** `confirmada`
- **Enunciado:** Sem terminal interativo, todo arquivo que já existe é mantido. Nada é sobrescrito.
- **Rastreabilidade:** `install-init-project.sh`, `install-init-project.ps1`

### RN-INSTALADOR-005 — Verificação não bloqueia

- **Status:** `confirmada`
- **Enunciado:** Depois da cópia, o relatório de agentes, skills, RTK, archify e hook RTK é só informativo. Ausência desses componentes não altera o código de saída da instalação que já copiou os arquivos.
- **Rastreabilidade:** `install-init-project.sh`, `install-init-project.ps1`

### RN-INSTALADOR-006 — Destino no Windows

- **Status:** `revogada` (2026-10-15)
- **Enunciado:** No Windows 11 o destino é `%USERPROFILE%\.claude`. Sem argumento, o pacote procurado é `%USERPROFILE%\.claude\initProjectsInstall\dist\init-project`. Se essa pasta não existir, o instalador a cria e em seguida aplica RN-INSTALADOR-001.
- **Motivo da revogação:** o caminho padrão do pacote deixou de depender de `~/.claude`/`%USERPROFILE%\.claude` — ver RN-INSTALADOR-011. O destino da instalação (`%USERPROFILE%\.claude`) continua o mesmo; só o caminho padrão do **pacote de origem** mudou.
- **Rastreabilidade:** nenhuma (comportamento substituído por RN-INSTALADOR-011).

### RN-INSTALADOR-007 — Capacidades no Windows

- **Status:** `confirmada`
- **Enunciado:** `_scan.sh capacidades` só roda quando o `bash` resolvido no PATH é identificável como Git Bash (caminho contém `\Git\`) ou WSL (caminho contém `\System32\`). Git Bash chama `_scan.sh` direto, sem variável extra (resolve `$HOME` sozinho). WSL recebe `CLAUDE_CONFIG_DIR` traduzido para `/mnt/<drive>/...` — sem isso, o `$HOME` do WSL é o do Linux, não o do Windows, e a varredura leria o perfil errado em vez de avisar. Se `%USERPROFILE%` não for um caminho de unidade com letra (`X:\...` — ex.: perfil de rede/UNC `\\servidor\compartilhamento`), a tradução falha explicitamente e a checagem é pulada com aviso, em vez de montar um `/mnt/...` adivinhado. Qualquer outro `bash` (ex.: Cygwin) ou nenhum `bash` no PATH: o relatório avisa `AVISO` e pula a checagem, em vez de arriscar um resultado incorreto. A instalação dos 18 arquivos permanece válida em qualquer caso.
- **Rastreabilidade:** `install-init-project.ps1`, `dist/init-project/templates/init-project/_scan.sh`

### RN-INSTALADOR-008 — Componentes opcionais só com sim

- **Status:** `confirmada`
- **Enunciado:** RTK e archify só são instalados depois de uma resposta que começa com `s` ou `S` num terminal interativo. Sem terminal, o instalador apenas imprime o comando manual. RTK é instalado por OS: `brew install rtk` no macOS, script `curl | sh` no Linux, `winget install rtk-ai.rtk` no Windows — nos dois instaladores, `install-init-project.sh` e `install-init-project.ps1`, não só no Windows.
- **Rastreabilidade:** `install-init-project.sh`, `install-init-project.ps1`

### RN-INSTALADOR-009 — Origem e destino são o mesmo arquivo

- **Status:** `revogada` (2026-10-15)
- **Enunciado:** Se o arquivo do pacote e o destino resolvem para o mesmo caminho, o instalador não copia. Conta o item como pulado e segue para o próximo. Evita copiar um arquivo sobre ele mesmo.
- **Motivo da revogação:** a reescrita de `install-init-project.ps1` (2026-10-15) simplificou a lógica de cópia e não reimplementou esta checagem. `install-init-project.sh` nunca a teve. Aceito como simplificação intencional nesta sincronização de documentação — não é mais um comportamento garantido por nenhum dos dois instaladores.
- **Rastreabilidade:** nenhuma (comportamento removido).

### RN-INSTALADOR-010 — Destino que é pasta

- **Status:** `revogada` (2026-10-15)
- **Enunciado:** Se o caminho de destino existe e é uma pasta, o arquivo é pulado com aviso. O instalador não grava o arquivo dentro dessa pasta.
- **Motivo da revogação:** mesma reescrita de `install-init-project.ps1` que revogou RN-INSTALADOR-009 — a checagem explícita de "destino é pasta" não existe mais no script atual. `install-init-project.sh` nunca a teve.
- **Rastreabilidade:** nenhuma (comportamento removido).

### RN-INSTALADOR-011 — Pacote padrão ao lado do script

- **Status:** `confirmada`
- **Enunciado:** Sem argumento, `install-init-project.sh`, `install-init-project.ps1` e `package-init-project.sh` resolvem `dist/init-project/` (e, no caso de `package-init-project.sh`, só `dist/`) relativo à própria pasta do script — nunca a `~/.claude`/`%USERPROFILE%\.claude`. Se a pasta padrão não existir, o instalador encerra com erro explicando que falta rodar `package-init-project.sh` primeiro, em vez de criar uma pasta vazia.
- **Rastreabilidade:** `install-init-project.sh`, `install-init-project.ps1`, `package-init-project.sh`

### RN-INSTALADOR-012 — Verificação de atualização via GitHub Release

- **Status:** `confirmada`
- **Enunciado:** Ao final da instalação, `install-init-project.sh` e `install-init-project.ps1` comparam a versão em `dist/init-project/VERSION` (dentro do pacote usado) com a última GitHub Release de `c3t4r4/Personal-MD-for-Claude`. A chamada é best-effort, com timeout curto: sem rede, sem `VERSION` no pacote (pacotes antigos não o têm) ou sem nenhuma release publicada, o instalador avisa `indisponivel` com o motivo e segue — nunca altera o código de saída nem impede a instalação. `VERSION` não é um dos 18 arquivos instalados em `~/.claude` (não entra no array `FILES`): é metadado do próprio pacote, mantido manualmente pelo mantenedor.
- **Rastreabilidade:** `install-init-project.sh`, `install-init-project.ps1`, `dist/init-project/VERSION`

### RN-INSTALADOR-013 — Pacote completo antes de uma release

- **Status:** `confirmada`
- **Enunciado:** `release-init-project.sh` só publica uma release depois de confirmar que todo caminho listado no array `FILES` de `install-init-project.sh` existe dentro de `dist/init-project/`, e que os três arrays `FILES`/`$Files` (`install-init-project.sh`, `package-init-project.sh`, `install-init-project.ps1`) são idênticos. Qualquer divergência ou arquivo faltante aborta a release antes de qualquer tag, push ou publicação.
- **Rastreabilidade:** `release-init-project.sh`

---

## Histórico

| Data | Alteração |
| --- | --- |
| 2026-10-06 | Criado com RN-INSTALADOR-001 a RN-INSTALADOR-010, ao adicionar o instalador Windows 11. |
| 2026-10-15 | RN-INSTALADOR-009 e RN-INSTALADOR-010 revogadas — removidas na reescrita de `install-init-project.ps1`. RN-INSTALADOR-008 ampliada para cobrir a instalação de RTK por OS também em `install-init-project.sh`. |
| 2026-10-15 | RN-INSTALADOR-006 revogada (caminho padrão do pacote deixou de depender de `~/.claude`). RN-INSTALADOR-007 reescrita (detecção Git Bash vs. WSL restaurada, com tradução de `CLAUDE_CONFIG_DIR` só para WSL). Criadas RN-INSTALADOR-011 (pacote padrão ao lado do script), RN-INSTALADOR-012 (verificação de atualização via GitHub Release) e RN-INSTALADOR-013 (pacote completo antes de release), ao corrigir o caminho padrão hardcoded e adicionar `release-init-project.sh`. |
