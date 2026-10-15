# AGENTS.md — initProjectsInstall

## Objetivo do projeto

Empacotar o comando `/init-project` do Claude Code e instalá-lo em outra máquina, sem zip. No macOS e no Linux o instalador é `install-init-project.sh`. No Windows 11 é `install-init-project.ps1`, chamado por `install-init-project.cmd`.

## Stack principal

Scripts de instalação e templates Markdown. Não há aplicação, servidor nem banco.

## Linguagens e frameworks

- Bash, para empacotar e instalar em macOS/Linux, e para `_scan.sh`.
- PowerShell 5.1 ou superior, para instalar no Windows 11.
- Prompt de Comando (`.cmd`), apenas para contornar a ExecutionPolicy ao lançar o `.ps1`.
- Markdown, nos templates em `dist/init-project/`.

## Banco de dados

Não se aplica.

## Estratégia de autenticação

Não se aplica.

## Convenções de código

- O instalador Windows replica o comportamento de `install-init-project.sh`: os mesmos 18 caminhos relativos, validação antes de qualquer cópia, pergunta `[s/N/d]` por arquivo existente.
- Mensagens ao usuário em português.
- `install-init-project.ps1` fica em UTF-8 com BOM e quebras CRLF, para o Windows PowerShell 5.1 ler os acentos.
- Não sobrescrever arquivo existente sem confirmação explícita.

## Estrutura de diretórios

```text
install-init-project.sh      instalador macOS/Linux
install-init-project.ps1     instalador Windows 11
install-init-project.cmd     lançador do .ps1
package-init-project.sh      gera dist/init-project/ a partir de ~/.claude
dist/init-project/           pacote com os 18 arquivos
docs/                        governança deste repositório
```

Destino da instalação: `~/.claude` ou, no Windows, `%USERPROFILE%\.claude`.

## Comandos úteis

```bash
./package-init-project.sh
./install-init-project.sh [caminho/para/pasta-do-pacote]
```

```bat
install-init-project.cmd [caminho\para\pasta-do-pacote]
```

## Estratégia de testes

Não há suíte automatizada. A conferência do instalador Windows compara a lista dos 18 arquivos com `install-init-project.sh` e revisa o script estaticamente. Execução real do PowerShell exige Windows 11 ou `pwsh`, que não está neste ambiente macOS.

## Decisões arquiteturais relevantes

- Um pacote de pasta, sem zip, para copiar por USB ou rede.
- PowerShell 5.1, já presente no Windows 11, em vez de exigir PowerShell 7.
- `_scan.sh` não foi reescrito. No Windows ele roda via Git Bash ou WSL. Se nenhum dos dois existir, o relatório degrada e a cópia dos arquivos continua válida.

## Restrições conhecidas

- A verificação de capacidades no Windows depende de Git Bash ou WSL.
- A política de execução do PowerShell pode bloquear o `.ps1` se ele for aberto direto. O `.cmd` aplica `Bypass` só naquele processo.
- Este repositório não tem frontend, API, autenticação nem Docker.

## Regras de negócio

Ver `docs/RegrasNegocio.md`.

## Regras de recuperação de contexto

Ver `docs/RAG.md` quando esse arquivo existir. Hoje a recuperação é a leitura de `README.md`, dos scripts de instalação e de `docs/`.

## Regras de API

Não se aplica.

## Regras de frontend

Não se aplica.

## Regras de infraestrutura

Não se aplica. Não há `docs/Infraestrutura.md`.

## Fluxo multiagente

O fluxo padrão da regra global: Planner, Coder, Validator, Tester e Security Specialist. Ver `docs/Harness.md` quando esse arquivo existir. Esta tarefa não alterou papéis nem ferramentas do harness.

## Ordem obrigatória de leitura dos documentos

1. `~/.cursor/rules/personal-md-global.mdc`
2. `./AGENTS.md`
3. `./docs/RegrasNegocio.md`
4. `./docs/Arquitetura.md`
5. `./docs/Organograma.md`
6. `./README.md`
7. `./docs/Progresso.md`
8. `./docs/Memoria.md`

`docs/Infraestrutura.md`, `docs/API.md`, `docs/Frontend.md` e `docs/Auth.md` não se aplicam a este repositório.
