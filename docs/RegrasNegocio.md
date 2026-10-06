# Regras de Negócio — initProjectsInstall

> Memória viva das regras de instalação do comando `/init-project`.

Última atualização: 2026-10-06

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

- **Status:** `confirmada`
- **Enunciado:** No Windows 11 o destino é `%USERPROFILE%\.claude`. Sem argumento, o pacote procurado é `%USERPROFILE%\.claude\initProjectsInstall\dist\init-project`. Se essa pasta não existir, o instalador a cria e em seguida aplica RN-INSTALADOR-001.
- **Rastreabilidade:** `install-init-project.ps1`

### RN-INSTALADOR-007 — Capacidades no Windows

- **Status:** `confirmada`
- **Enunciado:** `_scan.sh capacidades` roda por Git Bash ou, se esse não existir, por WSL, com `CLAUDE_CONFIG_DIR` apontando para `%USERPROFILE%\.claude`. Sem os dois, o relatório avisa e a instalação dos 18 arquivos permanece válida.
- **Rastreabilidade:** `install-init-project.ps1`, `dist/init-project/templates/init-project/_scan.sh`

### RN-INSTALADOR-008 — Componentes opcionais só com sim

- **Status:** `confirmada`
- **Enunciado:** RTK (`winget install --id rtk-ai.rtk`) e archify (`npx`) só são instalados depois de uma resposta que começa com `s` ou `S` num terminal interativo. Sem terminal, o instalador apenas imprime o comando manual.
- **Rastreabilidade:** `install-init-project.sh`, `install-init-project.ps1`

### RN-INSTALADOR-009 — Origem e destino são o mesmo arquivo

- **Status:** `confirmada`
- **Enunciado:** Se o arquivo do pacote e o destino resolvem para o mesmo caminho, o instalador não copia. Conta o item como pulado e segue para o próximo. Evita copiar um arquivo sobre ele mesmo.
- **Rastreabilidade:** `install-init-project.ps1`

### RN-INSTALADOR-010 — Destino que é pasta

- **Status:** `confirmada`
- **Enunciado:** Se o caminho de destino existe e é uma pasta, o arquivo é pulado com aviso. O instalador não grava o arquivo dentro dessa pasta.
- **Rastreabilidade:** `install-init-project.ps1`

---

## Histórico

| Data | Alteração |
| --- | --- |
| 2026-10-06 | Criado com RN-INSTALADOR-001 a RN-INSTALADOR-010, ao adicionar o instalador Windows 11. |
