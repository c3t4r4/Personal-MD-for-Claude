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

## Backlog

- [ ] Executar `install-init-project.ps1` numa máquina Windows 11 real com pacote real e um arquivo já existente, cobrindo o prompt `[s/N/d]` tanto pelo caminho `pwsh` quanto pelo `powershell.exe` do `.cmd`.

## Bloqueios

- Nenhum.

## Pendências de segurança

- Nenhuma.

## Regras de negócio pendentes

- Nenhuma regra `⚠ inferida` ou `a definir` nesta entrega.

## Dívida de testes

- RN-INSTALADOR-003 e RN-INSTALADOR-004 — o prompt interativo e o modo sem TTY não foram executados aqui; falta um Windows com PowerShell.
