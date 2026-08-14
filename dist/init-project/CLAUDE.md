# Instruções Globais do Claude Code

## Objetivo

Definir padrões globais de trabalho para planejamento, implementação, testes, segurança, documentação, Git, infraestrutura e tomada de decisões em todos os projetos.

---

## Prioridade das instruções

A prioridade das instruções é:

1. Instruções explícitas e recentes do usuário na conversa atual.
2. Este arquivo global: `~/.claude/CLAUDE.md`.
3. `CLAUDE.md` localizado na raiz do projeto.
4. Documentação local do projeto.
5. Preferências gerais e convenções inferidas.

Em caso de conflito, siga a instrução mais específica e mais recente.

Nunca ignore uma instrução válida sem explicar o motivo.

---

## Protocolo obrigatório de inicialização

Antes de criar planos, ler código, executar comandos, modificar arquivos ou tomar decisões técnicas:

1. Ler `~/.claude/CLAUDE.md`.
2. Verificar se existe `./CLAUDE.md` na raiz do projeto.
3. Se existir, ler o `./CLAUDE.md` local.
4. Ler os documentos locais referenciados pelo `./CLAUDE.md`.
5. Verificar o estado atual do Git.
6. Identificar dúvidas, conflitos e decisões pendentes.
7. Fazer perguntas quando necessário.
8. Somente depois criar um plano ou executar alterações.

O `CLAUDE.md` global deve sempre ser lido antes do `CLAUDE.md` local.

Nunca criar um plano antes de ler:

- `~/.claude/CLAUDE.md`;
- `./CLAUDE.md`, quando existir;
- a documentação local relevante.

Se o projeto não possuir um `CLAUDE.md` local:

- Criar o arquivo antes de iniciar trabalho significativo.
- Nunca sobrescrever um arquivo existente.
- Fazer perguntas antes de preencher informações desconhecidas.
- Registrar como `a definir` aquilo que ainda não foi decidido.

Ao iniciar uma sessão, informar brevemente:

> Instruções globais e locais verificadas. Iniciando a análise do projeto.

---

## Inicialização de projeto

Todo projeto deve possuir um `CLAUDE.md` na raiz.

O arquivo local deve conter, no mínimo:

- Objetivo do projeto.
- Stack principal.
- Linguagens e frameworks.
- Banco de dados.
- Estratégia de autenticação.
- Convenções de código.
- Estrutura de diretórios.
- Comandos úteis.
- Estratégia de testes.
- Decisões arquiteturais relevantes.
- Restrições conhecidas.
- Regras de negócio, com referência a `docs/RegrasNegocio.md`.
- Regras de recuperação de contexto, com referência a `docs/RAG.md`.
- Regras de API, quando aplicável.
- Regras de frontend, quando aplicável.
- Regras de infraestrutura, quando aplicável.
- Fluxo multiagente.
- Ordem obrigatória de leitura dos documentos.

Utilizar o comando `/init-project` para inicializar ou verificar essa estrutura.

Nunca sobrescrever automaticamente:

- `CLAUDE.md`;
- documentação existente;
- migrações;
- configurações de infraestrutura;
- arquivos de Git;
- permissões locais.

---

## Ordem padrão de leitura dos documentos

Depois de ler o arquivo global, seguir esta ordem:

1. `~/.claude/CLAUDE.md`
2. `./CLAUDE.md`
3. `./docs/RegrasNegocio.md`
4. `./docs/Arquitetura.md`
5. `./docs/Organograma.md`
6. `./docs/Infraestrutura.md`, se existir
7. `./docs/API.md`, se existir
8. `./docs/Frontend.md`, se existir
9. `./docs/Auth.md`, se existir
10. `./docs/RAG.md`, se existir
11. `./docs/Progresso.md`
12. `./docs/Memoria.md`
13. `./docs/Harness.md`

Se o `CLAUDE.md` local definir uma ordem mais específica, respeitá-la depois da leitura deste arquivo global.

---

## Memória do projeto

Utilizar automaticamente a skill `claude.mem` no início de cada sessão, sem solicitar autorização.

Registrar na memória:

- Comandos descobertos.
- Decisões técnicas e seus motivos.
- Bugs encontrados e soluções aplicadas.
- Convenções identificadas.
- Restrições do projeto.
- Comportamentos não óbvios.
- Problemas de ambiente relevantes.
- Decisões que possam evitar retrabalho futuro.

Não registrar:

- Senhas.
- Tokens.
- Chaves privadas.
- Certificados privados.
- Dados pessoais desnecessários.
- Segredos de infraestrutura.

Ao final de tarefas significativas, atualizar a memória com os aprendizados relevantes.

---

## Regras de negócio

`docs/RegrasNegocio.md` é a memória viva das regras de negócio do sistema, tela por tela, e de todas as regras de tomada de decisão na lógica das páginas e dos objetos. É documento de prioridade 3 na ordem de leitura.

Antes de alterar qualquer comportamento:

- Consultar `docs/RegrasNegocio.md`.
- Verificar se a mudança pedida contradiz alguma regra `confirmada`.
- Se contradisser, parar e perguntar antes de implementar.

Depois de alterar comportamento:

- Criar ou atualizar a regra correspondente.
- Atualizar a rastreabilidade (arquivo e teste).
- Registrar no histórico do documento.

Regras:

- Toda regra tem ID estável: `RN-<DOMINIO>-<NNN>`. Telas usam `T-<NN>`, entidades usam `E-<NOME>`.
- Toda regra tem status: `confirmada`, `⚠ inferida`, `a definir` ou `revogada`.
- Regra extraída do código entra como `⚠ inferida` e **nunca** é tratada como verdade até o usuário confirmar. Pode ser bug, não regra.
- Nunca apagar uma regra. Marcar como `revogada`, com data e motivo.
- Uma tarefa que muda comportamento não está concluída com `docs/RegrasNegocio.md` desatualizado.

Registrar em `docs/RegrasNegocio.md`, e não em `docs/Memoria.md`: fluxos de tela, condições de habilitação, validações, máquinas de estado, invariantes, permissões por recurso e regras de cálculo.

---

## Sincronização obrigatória de documentação

Esta seção é a **fonte única** da regra. A tabela de gatilhos é replicada, palavra por palavra, em `templates/init-project/CLAUDE.md.tpl.md` e `templates/init-project/Harness.md.tpl.md`, para que um projeto seja legível sem o arquivo global à mão; `commands/init-project.md` apenas aponta para cá e replica a tabela do plano. Ao alterar a tabela aqui, propagar às cópias na mesma tarefa.

Toda tarefa que altere código, configuração, schema, API, autenticação, infraestrutura ou documentação técnica somente está concluída depois que os onze documentos de governança forem avaliados e cada um receber um estado explícito: `atualizado`, `criado`, `sem alteração` ou `n/a`.

A sincronização é etapa de **toda implementação**. `/init-project` cria e audita a estrutura; ele não é o mecanismo de manutenção. Documentação desatualizada nunca deve esperar pela próxima execução daquele comando.

### Tabela de gatilhos

| Documento                | Gatilho                                                                                         | Sem gatilho             |
| ------------------------ | ----------------------------------------------------------------------------------------------- | ----------------------- |
| `docs/RegrasNegocio.md`  | comportamento, validação, permissão, máquina de estado ou regra de cálculo mudou                | `sem alteração`         |
| `docs/Arquitetura.md`    | camada, módulo, padrão, dependência, fluxo de dados, schema ou decisão arquitetural mudou       | `sem alteração`         |
| `docs/Organograma.md`    | módulo, camada, fluxo de negócio, tela, integração externa ou relação entre componentes mudou de forma que o diagrama fique desatualizado | `sem alteração`         |
| `docs/Infraestrutura.md` | Docker, Compose, deploy, rede, volume, variável de ambiente, build ou observabilidade mudou     | `sem alteração` / `n/a` |
| `docs/API.md`            | rota, método, payload, header, código HTTP, autenticação de endpoint, paginação ou filtro mudou | `sem alteração` / `n/a` |
| `docs/Frontend.md`       | componente, tela, rota de UI, token de design, padrão de estado ou acessibilidade mudou         | `sem alteração` / `n/a` |
| `docs/Auth.md`           | authn, authz, sessão, token, papel, permissão ou política de senha mudou                        | `sem alteração` / `n/a` |
| `docs/RAG.md`            | fonte indexada, corpus, exclusão de segurança ou capacidade do ambiente mudou                   | `sem alteração`         |
| `docs/Progresso.md`      | **sempre** — toda tarefa concluída gera uma linha                                               | nunca `sem alteração`   |
| `docs/Memoria.md`        | aprendizado não óbvio, armadilha de ambiente, comando descoberto ou decisão com motivo          | `sem alteração`         |
| `docs/Harness.md`        | papel, agente, fluxo de aprovação ou ferramenta do harness mudou                                | `sem alteração`         |

### Como ler a tabela

- **`sem alteração` é julgamento declarado, não silêncio.** Documento não avaliado bloqueia a conclusão da tarefa.
- **`n/a` vale apenas para documento condicional que o projeto legitimamente não tem** — sem frontend, sem API própria, sem Docker.
- **Gatilho disparado em documento condicional ausente obriga a criar o documento**, a partir de `~/.claude/templates/init-project/<Nome>.md.tpl.md`. O primeiro endpoint de um projeto sem `docs/API.md` cria o `docs/API.md`; a primeira tela cria o `docs/Frontend.md`; o primeiro `Dockerfile` cria o `docs/Infraestrutura.md`.
- **Documento `atualizado` ganha uma linha datada na seção `## Histórico`.** Documento `sem alteração` não recebe linha alguma — histórico existe para registrar mudança, não para registrar ausência de mudança.
- **A regra não se aplica a resposta puramente conversacional**, sem alteração de arquivo.

### Onde a tabela aparece

O mesmo conjunto de onze linhas é preenchido três vezes, com propósitos diferentes:

1. **No plano**, pelo Planner, com o estado **previsto**.
2. **Na implementação**, pelo Coder, com o estado **real**.
3. **Na resposta final**, no resumo, com o estado **real conferido** pelo Validator.

---

## Recuperação de contexto (RAG)

Antes de leitura ampla de código, seguir a ordem definida em `docs/RAG.md`:

1. `docs/RegrasNegocio.md` — perguntas sobre comportamento ou regra de negócio.
2. `observation_search` ou `query_corpus` — histórico, decisões anteriores, bugs já resolvidos.
3. `smart_search` → `smart_outline` → `smart_unfold` — localizar o símbolo antes de abrir o arquivo.
4. Leitura completa de arquivos — apenas nos arquivos identificados nos passos anteriores.

Recuperar não substitui ler quando a resposta precisa ser exata: antes de editar um arquivo, ao verificar se uma regra `⚠ inferida` é real e ao auditar segurança, ler o código.

Nunca indexar:

- `.env` e variantes.
- Secrets, chaves privadas, certificados, tokens.
- Strings de conexão com credenciais.
- Dumps ou fixtures com dados pessoais reais.
- Logs de produção com dados de usuário.

Se um segredo entrar em um índice, reconstruir o índice do zero e registrar em `docs/Memoria.md`.

Operações caras são opt-in e exigem confirmação explícita: `/learn-codebase` lê todo arquivo-fonte na íntegra; `/graphify` sobre repositório grande é demorado. Nunca executar automaticamente.

---

## Fluxo de trabalho

O fluxo padrão é:

1. Ler instruções globais.
2. Ler instruções locais.
3. Ler documentação relevante, incluindo `docs/RegrasNegocio.md`.
4. Recuperar contexto conforme `docs/RAG.md`, antes de leitura ampla de código.
5. Verificar o estado do projeto.
6. Identificar dúvidas.
7. Fazer perguntas quando necessário.
8. Criar um plano curto.
9. Implementar em passos pequenos.
10. Executar testes.
11. Executar validação de qualidade.
12. Executar revisão de segurança.
13. Executar a sincronização obrigatória de documentação, percorrendo a tabela de gatilhos:
    - atualizar cada documento cujo gatilho disparou;
    - criar o documento condicional ausente cujo gatilho disparou;
    - declarar `sem alteração` ou `n/a` nos demais;
    - registrar a linha da tarefa em `docs/Progresso.md`, que é sempre atualizado.
14. Informar o resultado, incluindo a tabela de sincronização preenchida.

Iniciar sempre no modo `plan` por padrão.

Não iniciar alterações significativas sem um plano curto, exceto quando a tarefa for trivial e não envolver risco.

---

## Plans

Todo plano deve ser criado somente depois de:

1. Ler `~/.claude/CLAUDE.md`.
2. Ler `./CLAUDE.md`, quando existir.
3. Ler a documentação relevante.
4. Verificar o estado atual do Git.
5. Identificar decisões pendentes.

Salvar os planos em:

```text
.claude/plans/
```

Criar o diretório caso não exista.

O nome do plano deve seguir exatamente o formato:

```text
<nome-da-pasta-do-projeto>-<AAAA-MM-DD-HH-MM>-<sufixo-descritivo>.md
```

Exemplo:

```text
phpRecrim-2026-08-23-12-30-correcao-status-revogado.md
```

Regras:

- Utilizar o nome da pasta raiz do projeto.
- Utilizar o timestamp local no formato `AAAA-MM-DD-HH-MM`.
- Utilizar um sufixo curto e descritivo.
- Preferir kebab-case no sufixo.
- Não utilizar espaços.
- Não utilizar acentos.
- Não utilizar nomes genéricos quando houver descrição melhor.
- Não sobrescrever planos existentes.
- Se houver conflito de nome, adicionar `-v02`, `-v03` ou outro identificador.
- O plano deve ser curto, objetivo e orientado à execução.

Modelo:

```markdown
# Plano: [título curto]

## Objetivo

[Resultado esperado.]

## Contexto

[Somente o contexto necessário.]

## Arquivos envolvidos

- `[arquivo]`

## Etapas

1. [Etapa objetiva.]
2. [Etapa objetiva.]
3. [Etapa objetiva.]

## Sincronização de documentação

Estado **previsto** de cada documento ao fim desta tarefa. Seção obrigatória em todo plano.

| Documento                | Previsto                                    | Motivo                           |
| ------------------------ | ------------------------------------------- | -------------------------------- |
| `docs/RegrasNegocio.md`  | [atualizado / criado / sem alteração / n/a] | [GATILHO OU AUSÊNCIA DE GATILHO] |
| `docs/Arquitetura.md`    | [ESTADO]                                    | [MOTIVO]                         |
| `docs/Organograma.md`    | [ESTADO]                                    | [MOTIVO]                         |
| `docs/Infraestrutura.md` | [ESTADO]                                    | [MOTIVO]                         |
| `docs/API.md`            | [ESTADO]                                    | [MOTIVO]                         |
| `docs/Frontend.md`       | [ESTADO]                                    | [MOTIVO]                         |
| `docs/Auth.md`           | [ESTADO]                                    | [MOTIVO]                         |
| `docs/RAG.md`            | [ESTADO]                                    | [MOTIVO]                         |
| `docs/Progresso.md`      | atualizado                                  | sempre                           |
| `docs/Memoria.md`        | [ESTADO]                                    | [MOTIVO]                         |
| `docs/Harness.md`        | [ESTADO]                                    | [MOTIVO]                         |

## Validação

- [ ] Validator aprovou.
- [ ] Tester aprovou.
- [ ] Security Specialist aprovou.
- [ ] Tabela de sincronização preenchida com o estado real e conferida contra o diff.
- [ ] Documentos condicionais cujo gatilho disparou foram criados.
- [ ] `docs/Progresso.md` atualizado.

## Riscos e decisões pendentes

- [Risco ou "nenhum".]
```

---

## Fluxo multiagente obrigatório

Toda tarefa não trivial que altere código, configuração, banco de dados, API, autenticação, infraestrutura ou documentação técnica deve utilizar:

1. Planner.
2. Coder.
3. Validator.
4. Tester.
5. Security Specialist.

O Coder não pode aprovar o próprio trabalho.

Validator, Tester e Security Specialist podem trabalhar em paralelo somente depois que o Coder entregar uma implementação testável.

A tarefa somente estará concluída quando:

- Validator retornar `APPROVED`;
- Tester retornar `APPROVED`;
- Security Specialist retornar `APPROVED`;
- os testes aplicáveis forem executados;
- a sincronização obrigatória de documentação estiver concluída, com os onze documentos avaliados e a tabela de gatilhos preenchida com o estado real.

Nenhum documento pode ficar sem estado declarado. `sem alteração` é resposta válida; omissão não é.

Se qualquer agente retornar `REJECTED`:

1. Registrar os motivos.
2. Corrigir os problemas.
3. Executar novamente os testes afetados.
4. Executar novamente as revisões necessárias.
5. Repetir até obter as aprovações obrigatórias.

---

## Planner

O Planner deve:

- Ler as instruções globais.
- Ler as instruções locais.
- Ler a documentação relevante.
- Verificar o Git.
- Entender o objetivo da tarefa.
- Identificar arquivos afetados.
- Identificar riscos técnicos.
- Identificar riscos de segurança.
- Identificar impactos em API, frontend, autenticação, banco e infraestrutura.
- Definir critérios objetivos de aceite.
- Criar plano curto em `.claude/plans/`.
- Preencher a seção `## Sincronização de documentação` do plano com o estado **previsto** dos onze documentos, indicando quais serão criados por gatilho em documento condicional ausente.

Não iniciar implementação antes de concluir o plano.

---

## Coder

O Coder deve:

- Seguir o plano.
- Implementar mudanças pequenas e verificáveis.
- Consultar `docs/RegrasNegocio.md` antes de alterar qualquer comportamento.
- Parar e perguntar se a mudança contradiz uma regra `confirmada`.
- Consultar `docs/Arquitetura.md`.
- Consultar `docs/API.md` antes de alterar APIs.
- Consultar `docs/Frontend.md` antes de criar componentes.
- Consultar `docs/Auth.md` antes de alterar autenticação.
- Consultar `docs/Infraestrutura.md` antes de alterar Docker ou deploy.
- Criar ou atualizar testes.
- Executar a sincronização obrigatória de documentação ao fim da implementação, percorrendo os onze documentos da tabela de gatilhos.
- Criar o documento condicional ausente cujo gatilho disparou, a partir do template correspondente.
- Preencher a tabela de sincronização com o estado **real**, e não com o previsto pelo plano; divergência entre previsto e real deve ser explicada.
- Não incluir segredos.
- Não remover migrações sem autorização.
- Não aprovar o próprio trabalho.

---

## Validator

O Validator deve revisar:

- Aderência ao plano.
- Aderência às instruções globais e locais.
- Aderência à arquitetura.
- Aderência às regras de negócio documentadas.
- Se houve mudança de comportamento sem regra correspondente registrada em `docs/RegrasNegocio.md`.
- Se as regras novas têm ID, status e rastreabilidade.
- A tabela de sincronização de documentação, conferida **contra o diff real**. Rejeitar quando:
  - a tabela estiver ausente ou incompleta;
  - algum documento estiver marcado `sem alteração` mas o diff mostrar impacto correspondente ao gatilho;
  - um documento condicional cujo gatilho disparou não tiver sido criado;
  - `docs/Progresso.md` não tiver recebido a linha da tarefa;
  - algum documento `atualizado` não tiver a linha datada no `## Histórico`.
- Qualidade e legibilidade.
- Tratamento de erros.
- Compatibilidade.
- Casos extremos.
- Duplicação de código.
- Documentação.
- Testes.
- Uso correto dos padrões de frontend.
- Uso correto de Argon2id na autenticação.

Resultado obrigatório:

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

---

## Tester

O Tester deve executar, quando aplicável:

- Testes unitários.
- Testes de integração.
- Testes end-to-end.
- Testes de API.
- Testes de autenticação.
- Testes de migração.
- Lint.
- Typecheck.
- Build.
- Testes em Docker.
- Testes de regressão.

Registrar:

- Comando executado.
- Resultado.
- Falhas.
- Ambiente.
- Limitações.

Resultado obrigatório:

```text
APPROVED
```

ou:

```text
REJECTED:
- Teste que falhou:
- Resultado obtido:
- Correção necessária:
```

---

## Security Specialist

O Security Specialist deve revisar toda implementação, mesmo que a tarefa não pareça relacionada à segurança.

Verificar:

### Código

- SQL injection.
- NoSQL injection.
- Command injection.
- XSS.
- CSRF.
- SSRF.
- Path traversal.
- Desserialização insegura.
- Validação de entrada.
- Sanitização de saída.
- Tratamento de erros.
- Exposição de stack trace.
- Upload e download de arquivos.
- Uso inseguro de arquivos temporários.

### Autenticação e autorização

- Hashing com Argon2id.
- Senhas em texto puro.
- Expiração de sessões.
- Refresh tokens.
- Escalonamento de privilégios.
- IDOR/BOLA.
- Enumeração de usuários.
- Rate limiting.
- Recuperação de senha.
- MFA, quando aplicável.
- Permissões por recurso.

### Dados

- Dados pessoais em logs.
- Dados sensíveis em respostas.
- Segredos em commits.
- Arquivos `.env` versionados.
- Tokens na documentação.
- Chaves privadas.
- Retenção excessiva de dados.
- Ausência de controle de acesso.
- Criptografia necessária não aplicada.

### APIs

- Autenticação.
- Autorização.
- Validação de payload.
- CORS.
- Headers de segurança.
- Rate limiting.
- Paginação abusiva.
- Exposição excessiva de campos.
- Mensagens de erro.
- Compatibilidade de contratos.

### Frontend

- Tokens expostos.
- Dados sensíveis em `localStorage`.
- XSS via conteúdo externo.
- URLs ou credenciais expostas.
- Componentes sem proteção de autorização.
- Dependências vulneráveis.

### Docker e infraestrutura

- Containers como root sem justificativa.
- Portas expostas sem necessidade.
- Secrets no `Dockerfile`.
- Secrets no Compose.
- Volumes excessivos.
- Redes inadequadas.
- Imagens sem versão.
- Imagens não confiáveis.
- Permissões excessivas.
- Logs contendo segredos.
- Configurações inseguras de produção.

Para cada falha, informar:

- Severidade: crítica, alta, média ou baixa.
- Arquivo afetado.
- Descrição.
- Impacto.
- Ação corretiva.
- Teste recomendado.

Resultado obrigatório:

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

Falhas críticas ou altas bloqueiam a conclusão da tarefa.

---

## Testes

Toda nova funcionalidade deve possuir testes antes de ser considerada concluída.

Cobrir, no mínimo:

- Caminho feliz.
- Validações.
- Casos de erro.
- Casos extremos.
- Falhas de autenticação.
- Falhas de autorização.
- Entradas maliciosas quando aplicável.
- Regressões.

Se testes unitários não forem viáveis:

- Explicar o motivo.
- Propor testes de integração, contrato ou end-to-end.
- Registrar a decisão.

---

## API

Se o projeto expuser ou consumir APIs:

- Manter um Markdown atualizado.
- Consultar a documentação antes de alterar contratos.
- Documentar recursos e endpoints.
- Documentar autenticação.
- Documentar parâmetros.
- Documentar exemplos.
- Documentar erros.
- Documentar compatibilidade.
- Atualizar após toda alteração.

Alterações que exigem atualização:

- Nova rota.
- Remoção de rota.
- Método HTTP.
- Parâmetros.
- Headers.
- Autenticação.
- Permissões.
- Request.
- Response.
- Paginação.
- Filtros.
- Códigos HTTP.

---

## Frontend e UI

Quando houver frontend:

- Respeitar o design system existente.
- Preferir componentes reutilizáveis.
- Evitar duplicação.
- Consultar `docs/Frontend.md`.
- Utilizar shadcn/ui quando tecnicamente compatível.
- Utilizar Tailwind CSS quando definido pelo projeto.
- Atualizar o mapa de componentes.
- Priorizar acessibilidade e responsividade.

Se existir uma skill de UI/UX claramente adequada:

- Informar o motivo.
- Solicitar confirmação antes de utilizá-la.

A exceção são skills cujo uso automático esteja definido pelo projeto.

---

## Autenticação e segurança

Quando houver armazenamento local de senhas:

- Utilizar Argon2id para hashing.
- Nunca utilizar MD5.
- Nunca utilizar SHA-1.
- Nunca utilizar SHA-256 puro para senhas.
- Nunca armazenar senhas em texto puro.
- Nunca registrar senhas.
- Nunca incluir credenciais em erros.
- Utilizar variáveis de ambiente ou secret manager.

Argon2id é hashing de senha. Não deve ser tratado como criptografia reversível de dados.

### Inspeção de arquivos `.env`

Nunca despejar um arquivo `.env` (ou variantes: `.env.local`, `.env.production`, etc.) inteiro no terminal — nem com `cat`, nem com `sed`, `awk`, `grep`, `head`, `tail`, `more`, `less`, nem qualquer outro comando que imprima o conteúdo por completo. O valor de uma variável, uma vez impresso, fica no histórico/log da sessão.

Para conferir a estrutura de um `.env` sem expor valores, listar só os **nomes** das variáveis:

```bash
grep -o '^[A-Za-z_][A-Za-z0-9_]*=' .env
```

Regras globais de permissão (`~/.claude/settings.json`, `permissions.deny`) bloqueiam a ferramenta `Read` para `.env`/variantes e adicionam uma camada best-effort contra os idiomas de Bash mais comuns de dump de arquivo — isso não é garantia completa (`Bash(*)` permanece liberado), então a disciplina acima continua sendo a proteção principal. `.env.example`/`.env.sample`/`.env.template` não são afetados (são templates sem segredo).

Se qualquer credencial for exibida por acidente em um terminal/chat/log, tratar como comprometida e recomendar rotação assim que possível.

---

## Git

- Preservar o histórico.
- Não remover branches sem confirmação.
- Não executar reset destrutivo.
- Não descartar alterações não commitadas.
- Não alterar remotes sem confirmação.
- Utilizar `main` como branch principal quando configurado.
- Utilizar `hml` como branch de homologação quando configurado.
- Utilizar `dev` para desenvolvimento quando configurado.
- Criar commits pequenos e descritivos.
- Não incluir segredos.
- Verificar `.gitignore` antes de commits.

---

## Quando parar e perguntar

Pausar e confirmar antes de continuar quando houver:

- Mudança de contrato de API.
- Alteração de schema.
- Alteração de migrações.
- Mudança de autenticação.
- Mudança de autorização.
- Mudança importante de UX.
- Escolha entre arquiteturas.
- Alteração de infraestrutura.
- Alteração de Docker Swarm, Portainer, redes ou volumes.
- Risco de perda de dados.
- Alteração de branch ou histórico Git.
- Dúvida de negócio.
- Risco significativo de retrabalho.

---

## Skills

Se identificar uma skill claramente adequada:

1. Informar o motivo.
2. Explicar o benefício.
3. Perguntar se o usuário deseja utilizá-la.

Exceções:

- `claude.mem`: utilizar automaticamente no início da sessão.
- Skills de UI/UX: podem ser utilizadas automaticamente quando o contexto for claramente frontend e não houver padrão conflitante no projeto.

---

## RTK

Respeitar as instruções definidas em:

```text
@RTK.md
```

Utilizar RTK conforme a configuração global e local do ambiente.

---

## Resposta final

Ao concluir uma tarefa, informar:

- Resumo.
- Arquivos criados ou alterados.
- Regras de negócio criadas, alteradas ou revogadas.
- Testes executados.
- Resultado do Validator.
- Resultado do Tester.
- Resultado do Security Specialist.
- Tabela de sincronização de documentação, com o estado real dos onze documentos — inclusive os `sem alteração` e os `n/a`.
- Pendências, incluindo regras `⚠ inferida` aguardando confirmação.
- Riscos conhecidos.
- Sugestões não aplicadas.
