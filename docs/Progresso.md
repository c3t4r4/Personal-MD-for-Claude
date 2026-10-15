# Progresso — initProjectsInstall

## Status atual

- Estado: estável para empacotar e instalar o `/init-project`
- Última atualização: 2026-10-15
- Branch atual: `main`

## Em andamento

- Nenhuma.

## Concluído

| Data | Tarefa | Plano | Rodadas | Validator | Tester | Segurança | Regras | Documentos | Observações |
| --- | --- | --- | ---: | --- | --- | --- | --- | --- | --- |
| 2026-10-06 | Instalador Windows 11 do `/init-project` | `.cursor/plans/Personal-MD-for-Claude-2026-10-06-17-05-instalador-windows.md` | 1 | APPROVED | APPROVED | APPROVED | RN-INSTALADOR-001 a RN-INSTALADOR-010 | RegrasNegocio.md (novo), Arquitetura.md (novo), Organograma.md (novo), Progresso.md (novo), Memoria.md (novo), README.md, arquitetura.html (novo) | Conferência estática no macOS; `pwsh` ausente |
| 2026-10-15 | Sincronização de README/docs/AGENTS.md com a reescrita do instalador Windows (pwsh 7, remoção de BOM, detecção de bash simplificada, RTK cross-OS, `ai-memory`) | `.claude/plans/Personal-MD-for-Claude-2026-10-15-11-05-sync-readme-docs-agents.md` | 1 | APPROVED (inline) | APPROVED (inline) | APPROVED (inline) | RN-INSTALADOR-009 e RN-INSTALADOR-010 revogadas; RN-INSTALADOR-008 ampliada | README.md, AGENTS.md, RegrasNegocio.md, Arquitetura.md, Organograma.md, Progresso.md, Memoria.md | Tarefa só de documentação (sem código/schema/API/auth/infra) — revisão rodou inline, sem subagentes dedicados, por decisão explícita registrada no plano |
| 2026-10-15 | Remoção da skill `graphify` de todo o pacote (`dist/init-project/`), por pedido explícito do usuário — só `archify` permanece | (sem plano formal — pedido direto, confirmado via pergunta de escopo antes da execução) | 1 | APPROVED (inline) | APPROVED (inline) | APPROVED (inline) | Nenhuma (conteúdo de template, não regra de instalador) | README.md, `dist/init-project/CLAUDE.md`, `commands/init-project.md`, `_capacidades.md`, `_checklist-entrevista.md`, `RAG.md.tpl.md`, `_scan.sh`, Memoria.md | `bash -n` confirmou sintaxe válida de `_scan.sh` após a remoção; grep final confirmou zero menções a `graphify` no repositório |
| 2026-10-15 | Corrigido o caminho padrão hardcoded do pacote (`~/.claude/initProjectsInstall/dist/init-project`, inexistente nesta máquina) para resolver relativo à própria pasta do script nos três scripts de empacotar/instalar; adicionados `VERSION` (em `dist/init-project/`) e checagem de atualização via GitHub Release nos dois instaladores; criado `release-init-project.sh` (publicação manual de release, validado com shellcheck/paridade de `FILES`/git) e `CHANGELOG.md`; restaurada a detecção Git Bash vs. WSL em `install-init-project.ps1`, com tradução de `CLAUDE_CONFIG_DIR` só para WSL | `.claude/plans/Personal-MD-for-Claude-2026-10-15-12-35-fix-caminho-dist-versionador.md` | 2 (reaproveitou `release.sh`/`CHANGELOG.md` trazidos pelo usuário de um projeto irmão, `Personal-MD-for-Cursor`, adaptados para este repositório) | APPROVED (achado médio de `ConvertTo-WslPath` corrigido no mesmo turno) | APPROVED (11/11 checagens) | APPROVED (2 achados não bloqueantes — médio e baixo — corrigidos no mesmo turno) | RN-INSTALADOR-006 revogada; RN-INSTALADOR-007 reescrita (2x, incluindo o fallback UNC); RN-INSTALADOR-011, 012 e 013 criadas | README.md, RegrasNegocio.md, Arquitetura.md (+ arquitetura.html), Organograma.md, Progresso.md, Memoria.md | Descoberto durante os testes: `package-init-project.sh` sobrescrevia templates do pacote com conteúdo mais antigo de `~/.claude` (drift pré-existente, não causado por esta tarefa) — revertido antes do commit. Validator/Tester/Security Specialist rodados em paralelo (Sonnet/Haiku/Sonnet); release `v1.0.0` publicada via `release-init-project.sh` ao final |

## Backlog

- [ ] Executar `install-init-project.ps1` numa máquina Windows 11 real com pacote real e um arquivo já existente, cobrindo o prompt `[s/N/d]` tanto pelo caminho `pwsh` quanto pelo `powershell.exe` do `.cmd`.
- [ ] Testar de verdade a detecção de Git Bash vs. WSL (tradução de `CLAUDE_CONFIG_DIR`) numa máquina Windows 11 real — validado aqui só estaticamente (`pwsh` no macOS classificou corretamente `/bin/bash` como "nem Git Bash nem WSL" e pulou a checagem, mas não há como simular um `bash.exe` real de WSL ou Git Bash fora do Windows).
- [ ] Reconciliar o drift entre o `~/.claude` desta máquina e o `dist/init-project/` commitado (ver `docs/Memoria.md`) antes da próxima vez que `package-init-project.sh` rodar de verdade — hoje ele reverteria conteúdo mais novo do pacote para o estado mais antigo do `~/.claude` local.

## Bloqueios

- Nenhum.

## Pendências de segurança

- Nenhuma.

## Regras de negócio pendentes

- Nenhuma regra `⚠ inferida` ou `a definir` nesta entrega.

## Dívida de testes

- RN-INSTALADOR-003 e RN-INSTALADOR-004 — o prompt interativo e o modo sem TTY não foram executados aqui; falta um Windows com PowerShell.
