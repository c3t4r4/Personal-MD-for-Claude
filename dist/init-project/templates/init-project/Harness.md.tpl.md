# Harness Multiagente — [NOME DO PROJETO]

## Objetivo

Garantir que toda tarefa relevante seja planejada, implementada, validada, testada e revisada quanto à segurança.

## Fluxo obrigatório

1. Leitura das instruções globais.
2. Leitura das instruções locais.
3. Leitura da documentação, incluindo `docs/RegrasNegocio.md`.
4. Recuperação de contexto conforme `docs/RAG.md`.
5. Planner.
6. Coder.
7. Validator.
8. Tester.
9. Security Specialist.
10. Correções, se necessárias.
11. Nova validação.
12. Sincronização obrigatória de documentação — os dez documentos avaliados, os impactados atualizados ou criados, os demais declarados `sem alteração` ou `n/a`.

## Quem executa cada papel

Papel é responsabilidade; agente é quem a executa. Preenchido conforme o que existe **neste** ambiente — papel sem agente correspondente roda `inline`, na conversa principal, com o mesmo protocolo.

| Papel | Agente preferido | Alternativa | Neste projeto |
| --- | --- | --- | --- |
| Planner | `planner` | `task-decomposition-expert` | [AGENTE OU `inline`] |
| Coder | `coder` | especialista do domínio | [AGENTE OU `inline`] |
| Validator | `code-reviewer` | `reviewer` | [AGENTE OU `inline`] |
| Tester | `test-engineer` | — | [AGENTE OU `inline`] |
| Security Specialist | `security-auditor` | — | [AGENTE OU `inline`] |

Especialistas que o Coder aciona quando o assunto pedir:

| Assunto | Agente |
| --- | --- |
| Arquitetura de backend | `backend-architect`, `system-architect` |
| Modelagem e migrações | `database-architect` |
| Frontend | `frontend-developer`, `ui-ux-designer` |
| Docker, deploy, CI/CD | `devops-engineer`, `deployment-engineer`, `cicd-engineer` |
| Documentação de API | `api-documenter`, `api-docs` |
| Documentação geral | `documentation-expert` |

Regras:

- **`security-auditor` só tem `Read`, `Grep` e `Glob`** — e isso é proposital: auditoria não escreve. As correções que ele apontar voltam para o Coder.
- Delegar isola contexto, mas custa uma rodada. Tarefa trivial não delega.
- O Coder continua sem poder aprovar o próprio trabalho, delegando ou não.
- Se um agente não existir no ambiente, o papel roda inline. Ausência de agente nunca dispensa o papel.

## Planner

Responsabilidades:

- Ler `~/.claude/CLAUDE.md`.
- Ler `./CLAUDE.md`.
- Ler `docs/RegrasNegocio.md` e identificar as regras afetadas.
- Ler a documentação aplicável.
- Verificar o Git.
- Criar um plano curto em `.claude/plans/`.
- Identificar riscos técnicos e de segurança.
- Listar os IDs das regras que serão criadas ou alteradas.
- Preencher no plano a seção `## Sincronização de documentação` com o estado **previsto** dos dez documentos.
- Definir critérios de aceite.

O nome do plano deve seguir:

```text
<nome-da-pasta-do-projeto>-<AAAA-MM-DD-HH-MM>-<sufixo-descritivo>.md
```

## Coder

Responsabilidades:

- Implementar conforme o plano.
- Consultar `docs/RegrasNegocio.md` antes de alterar comportamento.
- Parar e perguntar se a mudança contradiz uma regra `confirmada`.
- Consultar a documentação antes de alterar APIs, frontend, autenticação, banco ou infraestrutura.
- Criar ou atualizar testes.
- Executar a sincronização obrigatória de documentação e preencher a tabela com o estado **real**.
- Criar o documento condicional ausente cujo gatilho disparou, a partir do template correspondente.
- Não incluir segredos.
- Não aprovar o próprio trabalho.

### Tabela de sincronização

Conforme a seção `Sincronização obrigatória de documentação` de `~/.claude/CLAUDE.md`, que é a fonte única.

| Documento | Gatilho | Sem gatilho |
| --- | --- | --- |
| `docs/RegrasNegocio.md` | comportamento, validação, permissão, máquina de estado ou regra de cálculo mudou | `sem alteração` |
| `docs/Arquitetura.md` | camada, módulo, padrão, dependência, fluxo de dados, schema ou decisão arquitetural mudou | `sem alteração` |
| `docs/Infraestrutura.md` | Docker, Compose, deploy, rede, volume, variável de ambiente, build ou observabilidade mudou | `sem alteração` / `n/a` |
| `docs/API.md` | rota, método, payload, header, código HTTP, autenticação de endpoint, paginação ou filtro mudou | `sem alteração` / `n/a` |
| `docs/Frontend.md` | componente, tela, rota de UI, token de design, padrão de estado ou acessibilidade mudou | `sem alteração` / `n/a` |
| `docs/Auth.md` | authn, authz, sessão, token, papel, permissão ou política de senha mudou | `sem alteração` / `n/a` |
| `docs/RAG.md` | fonte indexada, corpus, exclusão de segurança ou capacidade do ambiente mudou | `sem alteração` |
| `docs/Progresso.md` | **sempre** — toda tarefa concluída gera uma linha | nunca `sem alteração` |
| `docs/Memoria.md` | aprendizado não óbvio, armadilha de ambiente, comando descoberto ou decisão com motivo | `sem alteração` |
| `docs/Harness.md` | papel, agente, fluxo de aprovação ou ferramenta do harness mudou | `sem alteração` |

`sem alteração` é julgamento declarado, não silêncio. Documento `atualizado` ganha linha datada no seu `## Histórico`; documento `sem alteração` não recebe linha.

## Validator

Verificar:

- Aderência ao plano.
- Aderência à arquitetura.
- Aderência às regras de negócio documentadas.
- Se houve mudança de comportamento sem regra correspondente registrada.
- Se regras novas têm ID, status e rastreabilidade.
- A tabela de sincronização **contra o diff real**, rejeitando quando: a tabela estiver ausente ou incompleta; um `sem alteração` for desmentido pelo diff; um documento condicional cujo gatilho disparou não tiver sido criado; `docs/Progresso.md` não tiver a linha da tarefa; um documento `atualizado` não tiver linha no `## Histórico`.
- Qualidade.
- Tratamento de erros.
- Compatibilidade.
- Casos extremos.
- Documentação.
- Testes.
- Convenções do projeto.

Resultado:

```text
APPROVED
```

ou:

```text
REJECTED:
- Problema:
- Motivo:
- Correção necessária:
```

## Tester

Executar, quando aplicável:

- Testes unitários.
- Testes de integração.
- Testes end-to-end.
- Testes de API.
- Testes de autenticação.
- Testes das regras de negócio alteradas.
- Lint.
- Typecheck.
- Build.
- Testes Docker.
- Testes de regressão.

Registrar os comandos e resultados reais.

Resultado:

```text
APPROVED
```

ou:

```text
REJECTED:
- Teste:
- Resultado:
- Correção necessária:
```

## Security Specialist

O Security Specialist deve analisar toda implementação, mesmo que a tarefa não pareça relacionada à segurança.

### Código

- SQL injection.
- NoSQL injection.
- Command injection.
- XSS.
- CSRF.
- SSRF.
- Path traversal.
- Desserialização insegura.
- Validação de entradas.
- Sanitização de saídas.
- Upload e download de arquivos.
- Exposição de stack traces.
- Dados sensíveis em logs.

### Autenticação e autorização

- Argon2id.
- Senhas em texto puro.
- Expiração de sessões.
- Refresh tokens.
- Controle de acesso.
- IDOR/BOLA.
- Escalonamento de privilégios.
- Enumeração de usuários.
- Rate limiting.
- Recuperação de senha.
- MFA.

### Dados

- Segredos em commits.
- `.env` versionado.
- Tokens em documentação.
- Dados pessoais em logs.
- Dados sensíveis em respostas.
- Dados sensíveis em índices de RAG.
- Retenção excessiva.
- Ausência de controle de acesso.
- Criptografia necessária não aplicada.

### API

- Autenticação.
- Autorização.
- Validação de payload.
- CORS.
- Headers.
- Rate limiting.
- Paginação abusiva.
- Exposição excessiva de dados.
- Mensagens de erro.

### Frontend

- Tokens expostos.
- Dados sensíveis em `localStorage`.
- XSS.
- Credenciais no cliente.
- Falhas de autorização.
- Regra de permissão aplicada apenas na UI, sem validação no servidor.
- Dependências vulneráveis.

### Docker e infraestrutura

- Containers como root.
- Portas desnecessárias.
- Secrets em Dockerfile ou Compose.
- Volumes excessivos.
- Redes inadequadas.
- Imagens sem versão.
- Imagens não confiáveis.
- Permissões excessivas.
- Logs com segredos.

Para cada problema, informar:

- Severidade.
- Arquivo afetado.
- Descrição.
- Impacto.
- Ação corretiva.
- Teste recomendado.

Resultado:

```text
APPROVED
```

ou:

```text
REJECTED:
- Severidade:
- Arquivo:
- Problema:
- Impacto:
- Ação corretiva:
- Teste recomendado:
```

Falhas críticas ou altas bloqueiam a conclusão.

## Aprovação final

A tarefa somente está concluída quando:

- Validator = `APPROVED`;
- Tester = `APPROVED`;
- Security Specialist = `APPROVED`;
- testes aplicáveis foram executados;
- a sincronização obrigatória de documentação foi concluída, com os dez documentos avaliados e a tabela preenchida com o estado real.

Nenhum documento pode ficar sem estado declarado. `sem alteração` é resposta válida; omissão não é.

## Registro

Registrar em `docs/Progresso.md`:

- Data.
- Plano.
- Descrição.
- Arquivos alterados.
- Regras de negócio criadas ou alteradas.
- Número de rodadas.
- Resultado do Validator.
- Resultado do Tester.
- Resultado do Security Specialist.
- Testes executados.
- Riscos encontrados.
- Documentos `atualizado` e `criado` da tabela de sincronização. Os `sem alteração` e `n/a` ficam fora da tabela de progresso, mas devem constar do resumo final da tarefa.
