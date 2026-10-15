# Personal-MD for Claude

Empacota o comando `/init-project` do Claude Code (`~/.claude/CLAUDE.md` + `commands/init-project.md` + `templates/init-project/*`) numa pasta simples, para copiar para outra máquina e instalar lá — sem depender de `zip`/`unzip`. Instalador disponível para macOS, Linux e Windows.

## Por que isso existe

`/init-project` não é um arquivo isolado: ele lê `~/.claude/CLAUDE.md` (regras globais de governança) e depende de 16 arquivos de apoio em `~/.claude/templates/init-project/` (script de varredura, checklists, templates de documentação). Para levar o comando inteiro para uma máquina nova sem esquecer nenhuma peça, os scripts aqui automatizam isso — um par para empacotar/instalar via bash (macOS/Linux) e um instalador equivalente em PowerShell/`.cmd` para Windows.

## Os 18 arquivos empacotados

| Arquivo                                            | Papel                                                                                                                                                                                                                                 |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `CLAUDE.md`                                        | Instruções globais do usuário — `/init-project` as lê na FASE 1, antes de qualquer plano                                                                                                                                              |
| `commands/init-project.md`                         | O próprio comando: as 9 fases, modos (`--check`/`--update`/`--rag`/`--regras`), diagramas de decisão                                                                                                                                  |
| `templates/init-project/_scan.sh`                  | Script de varredura (capacidades do ambiente, estrutura do projeto) — o único executável do pacote                                                                                                                                    |
| `templates/init-project/_capacidades.md`           | O que fazer quando falta MCP `claude-mem` (ou `ai-memory`), skill `archify`, agentes do harness ou `ui-ux-pro-max`                                                                                                                    |
| `templates/init-project/_checklist-entrevista.md`  | Checklist de cobertura da entrevista com o usuário                                                                                                                                                                                    |
| `templates/init-project/_varredura-regras.md`      | Procedimento do modo `--regras` (varredura profunda de código)                                                                                                                                                                        |
| `templates/init-project/*.md.tpl.md` (12 arquivos) | Templates de `CLAUDE.md`, `RegrasNegocio.md`, `Arquitetura.md`, `Organograma.md`, `RAG.md`, `Harness.md`, `Progresso.md`, `Memoria.md`, `API.md`, `Frontend.md`, `Auth.md`, `Infraestrutura.md` — gerados a cada projeto inicializado |

## Os scripts

### `package-init-project.sh`

Roda na máquina de **origem** (onde o `/init-project` já está configurado).

1. Confere que os 18 arquivos existem em `~/.claude`.
2. Copia tudo para uma pasta temporária, preservando a estrutura de diretórios e o bit executável de `_scan.sh`.
3. Preserva o `VERSION` já existente em `dist/init-project/` (se houver) — reempacotar nunca apaga a versão atual.
4. Substitui `dist/init-project/` inteira pelo conteúdo novo.

```bash
./package-init-project.sh
```

A pasta `dist/` é gerada **ao lado deste script** (na raiz do repositório, não em `~/.claude`) — o pacote de origem e o destino da instalação (`~/.claude`) são coisas diferentes. Cada execução **sobrescreve** `dist/init-project/` — não guarda versões antigas. Se quiser preservar um pacote específico antes de gerar um novo, copie a pasta para outro lugar manualmente antes de rodar o script de novo.

### `install-init-project.sh`

Roda na máquina de **destino** (nova ou já existente).

1. Recebe o caminho de uma pasta de pacote (ou usa `dist/init-project/` **ao lado do próprio script** por padrão, se nenhum caminho for informado — não mais `~/.claude/...`).
2. Confere que os 18 arquivos esperados estão presentes na pasta.
3. Copia arquivo por arquivo:
   - Se o destino não existe: instala direto.
   - Se já existe e é idêntico: avisa e ainda assim pergunta (nunca assume).
   - Se já existe e é diferente: pergunta `[s/N/d=ver diff]` antes de decidir — nunca sobrescreve em silêncio.
   - Sem terminal interativo disponível (ex.: rodando de um script/CI): pula tudo que já existe, por segurança.
4. Ao final, roda uma **verificação de componentes** e uma **verificação de atualização** (ver abaixo).

```bash
install-init-project.sh [caminho/para/pasta-do-pacote]
```

### `release-init-project.sh`

Roda manualmente, pelo mantenedor, quando quiser publicar uma versão nova — **nunca** dispara sozinho a partir de push, commit ou CI.

1. Exige bump manual prévio de `dist/init-project/VERSION` e uma seção `## [X.Y.Z]` correspondente em `CHANGELOG.md`, já commitados em `main`.
2. Valida: `shellcheck` nos scripts bash, paridade do array `FILES`/`$Files` entre os três instaladores, pacote completo (todo arquivo de `FILES` presente em `dist/init-project/`), branch `main`, árvore de trabalho limpa, tag `vX.Y.Z` inexistente (local e no remoto), `origin/main` em dia.
3. Empacota `dist/init-project/` em `.tar.gz` e `.zip`, copia os três instaladores e gera `SHA256SUMS.txt`.
4. Só com confirmação `[s/N]` no terminal: cria a tag anotada, dá push e publica a GitHub Release com esses assets.

```bash
./release-init-project.sh            # valida, pede confirmação, publica
./release-init-project.sh --dry-run  # só valida e empacota; nada é tagueado/enviado/publicado
```

### `install-init-project.ps1` / `install-init-project.cmd` (Windows)

Mesmo comportamento do `install-init-project.sh` — mesma lista de 18 arquivos, mesmo fluxo de pergunta `[s/N/d=ver diff]`, mesmo relatório final — só que em PowerShell. `install-init-project.ps1` roda em PowerShell 5.1+ (o host que já vem no Windows 11) ou em `pwsh` 7+ (qualquer SO, útil para desenvolver/testar o script fora do Windows). `install-init-project.cmd` é um atalho fino para quem prefere clicar duas vezes em vez de abrir o terminal manualmente: ele procura `pwsh` no PATH e usa-o quando presente, caindo para `powershell.exe` caso contrário, sempre com `-ExecutionPolicy Bypass` (não altera a política de execução do sistema, só a dessa chamada).

```powershell
.\install-init-project.ps1 [caminho\para\pasta-do-pacote]
```

Destino: `$HOME\.claude` (equivalente ao `~/.claude` do macOS/Linux). Sem argumento, o pacote padrão é `dist\init-project\` **ao lado deste script** (não mais `$HOME\.claude\...`). A seção "Agentes, skills, plugins e marketplaces" da verificação de componentes só roda quando o `bash` do PATH é identificável como Git Bash ou WSL (com `CLAUDE_CONFIG_DIR` traduzido para `/mnt/<drive>/...` nesse segundo caso — o `$HOME` do WSL é o do Linux, não o do Windows). Qualquer outro `bash`, ou nenhum, deixa essa parte do relatório `indisponível` em vez de arriscar um resultado incorreto — a instalação dos arquivos em si não depende disso.

## Verificação de componentes (ao final da instalação)

Depois de copiar os arquivos, o instalador informa — sem nunca bloquear a instalação — se os componentes que o `/init-project` usa estão presentes na máquina de destino:

- **Agentes, skills, plugins e marketplaces**: reaproveita o `_scan.sh capacidades` recém-instalado (agentes do harness, skills como `archify`/`ui-ux-pro-max`, plugins habilitados, marketplaces conhecidos).
- **RTK** (Rust Token Killer, binário externo de proxy de comandos): checa `which rtk`/`rtk --version` e se o hook `rtk hook claude` está configurado em `settings.json`.
- **MCP de memória (`claude-mem` e/ou `ai-memory`)**: não é verificável por script — o relatório lembra que é preciso testar chamando `list_corpora` (`claude-mem`) e/ou `memory_status` (`ai-memory`) dentro de uma sessão do Claude Code. Os dois podem coexistir; nenhum é pré-requisito do outro.
- **Verificação de atualização**: compara o `VERSION` do pacote usado na instalação com a última GitHub Release de `c3t4r4/Personal-MD-for-Claude` (timeout curto, só leitura). Sem rede, sem `VERSION` no pacote (pacotes antigos não o têm) ou sem nenhuma release publicada ainda: avisa `indisponivel` com o motivo.

Qualquer coisa ausente aparece no relatório como `ausente`/`indisponivel`, nunca interrompe o processo.

## Fluxo de uso ponta a ponta (máquina nova)

1. Na máquina de origem: `./package-init-project.sh` → gera `dist/init-project/` ao lado do script.
2. Copie a pasta `dist/init-project/` inteira para a máquina nova, por qualquer meio (USB, `rsync`, AirDrop, etc.) — ou baixe os assets de uma GitHub Release publicada com `release-init-project.sh`.
3. Na máquina nova:
   - macOS/Linux: rode `install-init-project.sh <caminho-da-pasta-copiada>` — ou coloque a pasta em `dist/init-project/` ao lado do script e rode sem argumento.
   - Windows: rode `install-init-project.ps1 <caminho-da-pasta-copiada>` (ou dê duplo clique em `install-init-project.cmd`) — mesma convenção de pasta padrão, em `dist\init-project\` ao lado do script.
4. Revise o relatório de verificação de componentes (e de atualização) ao final e instale o que estiver faltando (RTK, plugins, skills).

## Garantias de segurança

- Nunca sobrescreve um arquivo existente sem confirmação explícita (ou pula com segurança quando não há terminal interativo) — vale para os dois instaladores, bash e PowerShell.
- Checa a integridade dos 18 arquivos antes de instalar qualquer coisa — aborta sem copiar nada se faltar algum.
- Nenhuma etapa depende de rede, exceto a checagem de atualização (só leitura, best-effort, nunca bloqueia) e a instalação opcional dos componentes listados no relatório final (decisão do usuário, não automática).
- `release-init-project.sh` só roda quando o mantenedor o chama manualmente — nenhum push, commit ou workflow de CI publica uma release sozinho, e o próprio script só tagueia/envia/publica depois de confirmação explícita `[s/N]` no terminal.
- `install-init-project.cmd` só repassa argumentos para o `.ps1`; não baixa, não instala e não muda configuração nenhuma por conta própria.
