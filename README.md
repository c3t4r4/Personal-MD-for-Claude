# initProjectsInstall

Empacota o comando `/init-project` do Claude Code (`~/.claude/CLAUDE.md` + `commands/init-project.md` + `templates/init-project/*`) numa pasta simples, para copiar para outra máquina e instalar lá — sem depender de `zip`/`unzip`.

## Por que isso existe

`/init-project` não é um arquivo isolado: ele lê `~/.claude/CLAUDE.md` (regras globais de governança) e depende de 15 arquivos de apoio em `~/.claude/templates/init-project/` (script de varredura, checklists, templates de documentação). Para levar o comando inteiro para uma máquina nova sem esquecer nenhuma peça, os dois scripts aqui automatizam isso.

## Os 17 arquivos empacotados

| Arquivo | Papel |
| --- | --- |
| `CLAUDE.md` | Instruções globais do usuário — `/init-project` as lê na FASE 1, antes de qualquer plano |
| `commands/init-project.md` | O próprio comando: as 9 fases, modos (`--check`/`--update`/`--rag`/`--regras`), diagramas de decisão |
| `templates/init-project/_scan.sh` | Script de varredura (capacidades do ambiente, estrutura do projeto) — o único executável do pacote |
| `templates/init-project/_capacidades.md` | O que fazer quando falta MCP `claude-mem`, skill `graphify`, agentes do harness ou `ui-ux-pro-max` |
| `templates/init-project/_checklist-entrevista.md` | Checklist de cobertura da entrevista com o usuário |
| `templates/init-project/_varredura-regras.md` | Procedimento do modo `--regras` (varredura profunda de código) |
| `templates/init-project/*.md.tpl.md` (11 arquivos) | Templates de `CLAUDE.md`, `RegrasNegocio.md`, `Arquitetura.md`, `RAG.md`, `Harness.md`, `Progresso.md`, `Memoria.md`, `API.md`, `Frontend.md`, `Auth.md`, `Infraestrutura.md` — gerados a cada projeto inicializado |

## Os dois scripts

### `package-init-project.sh`

Roda na máquina de **origem** (onde o `/init-project` já está configurado).

1. Confere que os 17 arquivos existem em `~/.claude`.
2. Copia tudo para uma pasta temporária, preservando a estrutura de diretórios e o bit executável de `_scan.sh`.
3. Substitui `dist/init-project/` inteira pelo conteúdo novo.

```bash
~/.claude/initProjectsInstall/package-init-project.sh
```

Cada execução **sobrescreve** `dist/init-project/` — não guarda versões antigas. Se quiser preservar um pacote específico antes de gerar um novo, copie a pasta para outro lugar manualmente antes de rodar o script de novo.

### `install-init-project.sh`

Roda na máquina de **destino** (nova ou já existente).

1. Recebe o caminho de uma pasta de pacote (ou usa `dist/init-project/` por padrão, se nenhum caminho for informado).
2. Confere que os 17 arquivos esperados estão presentes na pasta.
3. Copia arquivo por arquivo:
   - Se o destino não existe: instala direto.
   - Se já existe e é idêntico: avisa e ainda assim pergunta (nunca assume).
   - Se já existe e é diferente: pergunta `[s/N/d=ver diff]` antes de decidir — nunca sobrescreve em silêncio.
   - Sem terminal interativo disponível (ex.: rodando de um script/CI): pula tudo que já existe, por segurança.
4. Ao final, roda uma **verificação de componentes** (ver abaixo).

```bash
install-init-project.sh [caminho/para/pasta-do-pacote]
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
3. Na máquina nova, rode `install-init-project.sh <caminho-da-pasta-copiada>` — ou coloque a pasta em `~/.claude/initProjectsInstall/dist/init-project/` e rode sem argumento.
4. Revise o relatório de verificação de componentes ao final e instale o que estiver faltando (RTK, plugins, skills).

## Garantias de segurança

- Nunca sobrescreve um arquivo existente sem confirmação explícita (ou pula com segurança quando não há terminal interativo).
- Checa a integridade dos 17 arquivos antes de instalar qualquer coisa — aborta sem copiar nada se faltar algum.
- Nenhuma etapa depende de rede, exceto a instalação opcional dos componentes listados no relatório final (decisão do usuário, não automática).
