# Plano: Instalador Windows 11 do /init-project

## Objetivo

Criar um instalador para Windows 11 equivalente a `install-init-project.sh`: mesmos 18 arquivos, mesma política de não sobrescrever sem confirmação e a mesma verificação final de componentes.

## Contexto

O script bash instala o comando `/init-project` em `~/.claude`. No Windows 11 o destino equivalente é `%USERPROFILE%\.claude`. PowerShell 5.1 (já presente no Windows 11) é o host; um `.cmd` contorna a ExecutionPolicy restrita.

## Arquivos envolvidos

- `install-init-project.sh` (referência, sem alteração de comportamento)
- `install-init-project.ps1` (novo)
- `install-init-project.cmd` (novo)
- `README.md`
- `docs/RegrasNegocio.md`, `docs/Arquitetura.md`, `docs/Organograma.md`, `docs/Progresso.md`, `docs/Memoria.md`
- `docs/arquitetura.html` (diagrama do fluxo de instalação)

## Etapas

1. Portar a lista de arquivos, a validação prévia e o laço interativo `[s/N/d]`.
2. Adaptar a verificação final ao Windows: Git Bash ou WSL para `_scan.sh`, winget para RTK, npx para archify.
3. Documentar o uso no README e registrar as regras de instalação.
4. Conferir a lista de arquivos contra o script bash e a sintaxe do PowerShell na medida do ambiente macOS.

## Sincronização de documentação

Estado **previsto** de cada documento ao fim desta tarefa.

| Documento | Previsto | Motivo |
| --- | --- | --- |
| `docs/RegrasNegocio.md` | criado | comportamento do instalador (validação, sobrescrita, TTY, componentes) |
| `docs/Arquitetura.md` | criado | novo instalador Windows ao lado do bash |
| `docs/Organograma.md` | criado | relação pacote → instalador → `%USERPROFILE%\.claude` |
| `docs/Infraestrutura.md` | n/a | projeto sem Docker, deploy ou observabilidade |
| `docs/API.md` | n/a | sem API |
| `docs/Frontend.md` | n/a | sem frontend |
| `docs/Auth.md` | n/a | sem autenticação |
| `docs/RAG.md` | sem alteração | fontes indexadas não mudam |
| `docs/Progresso.md` | criado | sempre |
| `docs/Memoria.md` | criado | ExecutionPolicy, bash no Windows, winget |
| `docs/Harness.md` | sem alteração | papéis do harness não mudam |

## Validação

- [ ] Validator aprovou.
- [ ] Tester aprovou.
- [ ] Security Specialist aprovou.
- [ ] Tabela de sincronização preenchida com o estado real e conferida contra o diff.
- [ ] Documentos condicionais cujo gatilho disparou foram criados.
- [ ] `docs/Progresso.md` atualizado.

## Riscos e decisões pendentes

- `_scan.sh` continua sendo bash. No Windows a checagem de capacidades depende de Git Bash ou WSL; a ausência degrada o relatório e não impede a cópia.
- Não há `pwsh` nesta máquina macOS. A validação executável do script fica limitada a conferência estática e comparação da lista de arquivos.
