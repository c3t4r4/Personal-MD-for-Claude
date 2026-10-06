# initProjectsInstall

Empacota o comando `/init-project` do Claude Code (`~/.claude/CLAUDE.md` + `commands/init-project.md` + `templates/init-project/*`) numa pasta simples, para copiar para outra máquina e instalar lá — sem depender de `zip`/`unzip`.

## Por que isso existe

`/init-project` não é um arquivo isolado: ele lê `~/.claude/CLAUDE.md` (regras globais de governança) e depende de 15 arquivos de apoio em `~/.claude/templates/init-project/` (script de varredura, checklists, templates de documentação). Para levar o comando inteiro para uma máquina nova sem esquecer nenhuma peça, os dois scripts aqui automatizam isso.

## Os 17 arquivos empacotados

| Arquivo                                            | Papel                                                                                                                                                                                                               |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `CLAUDE.md`                                        | Instruções globais do usuário — `/init-project` as lê na FASE 1, antes de qualquer plano                                                                                                                            |
| `commands/init-project.md`                         | O próprio comando: as 9 fases, modos (`--check`/`--update`/`--rag`/`--regras`), diagramas de decisão                                                                                                                |
| `templates/init-project/_scan.sh`                  | Script de varredura (capacidades do ambiente, estrutura do projeto) — o único executável do pacote                                                                                                                  |
| `templates/init-project/_capacidades.md`           | O que fazer quando falta MCP `claude-mem`, skill `graphify`, agentes do harness ou `ui-ux-pro-max`                                                                                                                  |
| `templates/init-project/_checklist-entrevista.md`  | Checklist de cobertura da entrevista com o usuário                                                                                                                                                                  |
| `templates/init-project/_varredura-regras.md`      | Procedimento do modo `--regras` (varredura profunda de código)                                                                                                                                                      |
| `templates/init-project/*.md.tpl.md` (11 arquivos) | Templates de `CLAUDE.md`, `RegrasNegocio.md`, `Arquitetura.md`, `RAG.md`, `Harness.md`, `Progresso.md`, `Memoria.md`, `API.md`, `Frontend.md`, `Auth.md`, `Infraestrutura.md` — gerados a cada projeto inicializado |

## Os scripts

### `package-init-project.sh`

Roda na máquina de **origem** (onde o `/init-project` já está configurado).

1. Confere que os 18 arquivos existem em `~/.claude`.
2. Copia tudo para uma pasta temporária, preservando a estrutura de diretórios e o bit executável de `_scan.sh`.
3. Substitui `dist/init-project/` inteira pelo conteúdo novo.

```bash
~/.claude/initProjectsInstall/package-init-project.sh
```

Cada execução **sobrescreve** `dist/init-project/` — não guarda versões antigas. Se quiser preservar um pacote específico antes de gerar um novo, copie a pasta para outro lugar manualmente antes de rodar o script de novo.

### `install-init-project.sh`

Roda na máquina de **destino** (nova ou já existente).

1. Recebe o caminho de uma pasta de pacote (ou usa `dist/init-project/` por padrão, se nenhum caminho for informado).
2. Confere que os 18 arquivos esperados estão presentes na pasta.
3. Copia arquivo por arquivo:
   - Se o destino não existe: instala direto.
   - Se já existe e é idêntico: avisa e ainda assim pergunta (nunca assume).
   - Se já existe e é diferente: pergunta `[s/N/d=ver diff]` antes de decidir — nunca sobrescreve em silêncio.
   - Sem terminal interativo disponível (ex.: rodando de um script/CI): pula tudo que já existe, por segurança.
4. Ao final, roda uma **verificação de componentes** (ver abaixo).

```bash
install-init-project.sh [caminho/para/pasta-do-pacote]
```

### `install-init-project.ps1` e `install-init-project.cmd` (Windows 11)

Mesma instalação, no destino `%USERPROFILE%\.claude`. O `.ps1` é o instalador. O `.cmd` só o chama com `ExecutionPolicy Bypass` neste processo, para funcionar mesmo quando a política da máquina bloqueia scripts.

1. Recebe a pasta do pacote, ou usa `%USERPROFILE%\.claude\initProjectsInstall\dist\init-project` se nenhum caminho for informado. Se essa pasta padrão não existir, ela é criada e a instalação aborta até os 18 arquivos estarem lá.
2. Confere os 18 arquivos antes de copiar qualquer um. Se faltar algum, não instala nada.
3. Copia arquivo por arquivo com a mesma política do script bash: novo entra direto; existente, idêntico ou não, pergunta `[s/N/d=ver diff]`; sem terminal interativo, mantém o que já existe.
4. Ao final, roda a verificação de componentes. Ela não muda o código de saída.

`_scan.sh` continua sendo bash. A cópia dos arquivos não depende disso. O relatório de agentes, skills e plugins usa Git Bash ou, na falta dele, WSL. RTK, se o usuário confirmar, instala com `winget install rtk-ai.rtk`. Archify, se o usuário confirmar, instala com `npx`.

No PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install-init-project.ps1 [caminho\para\pasta-do-pacote]
```

No Prompt de Comando, ou com duplo clique (a janela permanece aberta até uma tecla):

```bat
install-init-project.cmd [caminho\para\pasta-do-pacote]
```

## Verificação de componentes (ao final da instalação)

Depois de copiar os arquivos, o instalador informa — sem nunca bloquear a instalação — se os componentes que o `/init-project` usa estão presentes na máquina de destino:

- **Agentes, skills, plugins e marketplaces**: reaproveita o `_scan.sh capacidades` recém-instalado (agentes do harness, skills como `graphify`/`ui-ux-pro-max`, plugins habilitados, marketplaces conhecidos).
- **RTK** (Rust Token Killer, binário externo de proxy de comandos): checa `which rtk`/`rtk --version` e se o hook `rtk hook claude` está configurado em `settings.json`.
- **MCP `claude-mem`**: não é verificável por script — o relatório lembra que é preciso testar chamando a ferramenta `list_corpora` dentro de uma sessão do Claude Code.

Qualquer coisa ausente aparece no relatório como `ausente`/`indisponivel`, nunca interrompe o processo.

## Fluxo de uso ponta a ponta (máquina nova)

1. Na máquina de origem: `~/.claude/initProjectsInstall/package-init-project.sh` → gera `dist/init-project/`.
2. Copie a pasta `dist/init-project/` inteira para a máquina nova, por qualquer meio (USB, `rsync`, AirDrop, etc.).
3. Na máquina nova, rode `install-init-project.sh <caminho-da-pasta-copiada>` — ou, no Windows 11, `install-init-project.cmd <caminho-da-pasta-copiada>`. Sem argumento, o instalador procura `~/.claude/initProjectsInstall/dist/init-project/` (no Windows, `%USERPROFILE%\.claude\initProjectsInstall\dist\init-project`).
4. Revise o relatório de verificação de componentes ao final e instale o que estiver faltando (RTK, plugins, skills).

## Garantias de segurança

- Nunca sobrescreve um arquivo existente sem confirmação explícita (ou pula com segurança quando não há terminal interativo).
- Checa a integridade dos 18 arquivos antes de instalar qualquer coisa — aborta sem copiar nada se faltar algum.
- Nenhuma etapa depende de rede, exceto a instalação opcional dos componentes listados no relatório final (decisão do usuário, não automática).
