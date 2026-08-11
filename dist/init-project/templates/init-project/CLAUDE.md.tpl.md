# CLAUDE.md — [NOME DO PROJETO]

## Ordem obrigatória de leitura

Antes de qualquer plano, leitura de código, comando ou alteração:

1. `~/.claude/CLAUDE.md`
2. `./CLAUDE.md` (este arquivo)
3. `./docs/RegrasNegocio.md`
4. `./docs/Arquitetura.md`
5. `./docs/Infraestrutura.md`, se existir
6. `./docs/API.md`, se existir
7. `./docs/Frontend.md`, se existir
8. `./docs/Auth.md`, se existir
9. `./docs/RAG.md`
10. `./docs/Progresso.md`
11. `./docs/Memoria.md`
12. `./docs/Harness.md`

## Regras obrigatórias

- Ler o CLAUDE.md global antes deste arquivo.
- Ler este arquivo antes de criar planos.
- Ler este arquivo antes de executar alterações.
- Consultar `docs/RegrasNegocio.md` antes de alterar qualquer comportamento do sistema.
- Atualizar `docs/RegrasNegocio.md` sempre que o comportamento mudar.
- Seguir o protocolo retrieval-first de `docs/RAG.md` antes de leitura ampla de código.
- Utilizar `claude.mem` no início da sessão e após tarefas significativas.
- Utilizar RTK conforme as instruções globais.
- Iniciar tarefas não triviais em modo plan.
- Criar planos em `.claude/plans/`.
- Nomear planos com nome da pasta, timestamp e sufixo descritivo.
- Não sobrescrever arquivos sem confirmação.
- Consultar documentação antes de alterar API, frontend, autenticação, banco ou infraestrutura.
- Executar a sincronização obrigatória de documentação ao fim de **toda** implementação, conforme a seção `## Sincronização de documentação` deste arquivo.
- Utilizar Planner, Coder, Validator, Tester e Security Specialist.
- Uma tarefa só está concluída após aprovação do Validator, Tester e Security Specialist e com a tabela de sincronização preenchida.

## Stack confirmada

- Objetivo: [OBJETIVO]
- Frontend: [STACK]
- Backend: [STACK]
- Banco de dados: [BANCO]
- ORM: [ORM]
- Autenticação: [ESTRATÉGIA]
- API própria: [SIM/NÃO]
- APIs externas: [APIS]
- Docker: [USOS]
- Testes: [ESTRATÉGIA]

## Comandos

- Instalação: `[COMANDO]`
- Desenvolvimento: `[COMANDO]`
- Build: `[COMANDO]`
- Lint: `[COMANDO]`
- Typecheck: `[COMANDO]`
- Testes: `[COMANDO]`
- Docker: `[COMANDO]`

## Regras de negócio

- Consultar `docs/RegrasNegocio.md` antes de alterar telas, fluxos, validações ou lógica de decisão.
- Verificar se a mudança pedida contradiz alguma regra `confirmada`; se contradisser, parar e perguntar.
- Registrar toda regra nova com ID estável (`RN-<DOMINIO>-<NNN>`).
- Regras extraídas do código entram como `⚠ inferida` até confirmação do usuário.
- Nunca apagar regra: marcar como `revogada`, com data e motivo.
- Tarefa que muda comportamento não está concluída com `RegrasNegocio.md` desatualizado.

## Sincronização de documentação

Regra herdada de `~/.claude/CLAUDE.md`, seção `Sincronização obrigatória de documentação`, que é a fonte única. Replicada aqui para leitura sem o arquivo global à mão.

Toda tarefa que altere código, configuração, schema, API, autenticação, infraestrutura ou documentação técnica somente está concluída depois que os dez documentos abaixo forem avaliados e cada um receber um estado explícito: `atualizado`, `criado`, `sem alteração` ou `n/a`.

A sincronização é etapa de **toda implementação**. `/init-project` cria e audita a estrutura; ele não é o mecanismo de manutenção.

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

Como ler a tabela:

- `sem alteração` é julgamento declarado, não silêncio. Documento não avaliado bloqueia a conclusão da tarefa.
- `n/a` vale apenas para documento condicional que este projeto legitimamente não tem.
- Gatilho disparado em documento condicional ausente **obriga a criar o documento**, a partir de `~/.claude/templates/init-project/<Nome>.md.tpl.md`.
- Documento `atualizado` ganha linha datada no seu `## Histórico`. Documento `sem alteração` não recebe linha.
- A regra não se aplica a resposta puramente conversacional, sem alteração de arquivo.

A tabela é preenchida três vezes: no plano pelo Planner (estado previsto), na implementação pelo Coder (estado real) e no resumo final, conferida pelo Validator contra o diff.

Neste projeto, os documentos condicionais têm o seguinte estado inicial:

- `docs/Infraestrutura.md`: [EXISTE / n/a — CRIAR QUANDO HOUVER DOCKER, DEPLOY OU INFRAESTRUTURA]
- `docs/API.md`: [EXISTE / n/a — CRIAR QUANDO HOUVER API PRÓPRIA OU INTEGRAÇÃO RELEVANTE]
- `docs/Frontend.md`: [EXISTE / n/a — CRIAR QUANDO HOUVER FRONTEND]
- `docs/Auth.md`: [EXISTE / n/a — CRIAR QUANDO HOUVER AUTENTICAÇÃO]

## Regras de recuperação de contexto

- Seguir a ordem definida em `docs/RAG.md`: regras de negócio → observações/corpus → busca AST → leitura de arquivos.
- Nunca indexar `.env`, secrets, chaves, tokens ou dados pessoais.
- `/learn-codebase` é opt-in e caro — só com confirmação explícita.

## Regras de autenticação

- Senhas locais devem utilizar Argon2id.
- Nunca utilizar MD5, SHA-1 ou SHA-256 puro para senhas.
- Nunca armazenar senhas em texto puro.
- Nunca registrar credenciais em logs.
- Consultar `docs/Auth.md` antes de alterar autenticação.

## Regras de API

Se `docs/API.md` existir:

- Consultar antes de criar ou alterar endpoints.
- Verificar se já existe endpoint equivalente.
- Atualizar após qualquer alteração.
- Não concluir a tarefa com a documentação desatualizada.

## Regras de frontend

Se `docs/Frontend.md` existir:

- Consultar antes de criar componentes.
- Reutilizar componentes existentes.
- Utilizar shadcn/ui quando compatível.
- Utilizar Tailwind CSS conforme a regra do projeto.
- Atualizar o mapa de componentes após alterações.

## Referências

Documentos permanentes — sempre existem e sempre entram na sincronização:

- Regras de negócio: `docs/RegrasNegocio.md`
- Arquitetura: `docs/Arquitetura.md`
- RAG: `docs/RAG.md`
- Harness: `docs/Harness.md`
- Progresso: `docs/Progresso.md`
- Memória: `docs/Memoria.md`

Documentos condicionais — existem quando o projeto os justifica e devem ser **criados** assim que o gatilho correspondente disparar:

- Infraestrutura: `docs/Infraestrutura.md`
- API: `docs/API.md`
- Frontend: `docs/Frontend.md`
- Auth: `docs/Auth.md`
