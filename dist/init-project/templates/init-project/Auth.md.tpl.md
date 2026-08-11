# Autenticação e autorização — [NOME DO PROJETO]

> Consultar antes de qualquer alteração em login, sessão, papéis ou permissões.

## Estratégia

| Item | Valor |
| --- | --- |
| Tipo de autenticação | [USUÁRIO E SENHA / OAUTH / SSO / MISTO] |
| Provedores externos | [PROVEDORES OU "nenhum"] |
| Mecanismo de sessão | [JWT / COOKIE DE SESSÃO / OUTRO] |
| Expiração | [VALOR] |
| Refresh token | [SIM/NÃO — ESTRATÉGIA] |
| MFA | [SIM/NÃO — MÉTODO] |
| Recuperação de senha | [FLUXO OU "não disponível"] |

## Armazenamento de senhas

Quando o projeto armazena senhas localmente:

- Algoritmo obrigatório: **Argon2id**.
- Parâmetros: [MEMÓRIA / ITERAÇÕES / PARALELISMO]
- Nunca utilizar MD5, SHA-1 ou SHA-256 puro para senhas.
- Nunca armazenar senha em texto puro.
- Nunca registrar senha em log, mensagem de erro ou telemetria.
- Argon2id é hashing de senha, **não** criptografia reversível de dados.

## Tokens

| Token | Formato | Expiração | Onde é armazenado | Revogação |
| --- | --- | --- | --- | --- |
| [NOME] | [FORMATO] | [VALOR] | [LOCAL] | [COMO REVOGAR] |

- Claims: [CLAIMS]
- Emissor: [ISSUER]
- Audiência: [AUDIENCE]
- Segredo/chave: [ORIGEM — VARIÁVEL DE AMBIENTE OU SECRET MANAGER, NUNCA O VALOR]

## Papéis e permissões

| Papel | Descrição | Concedido por |
| --- | --- | --- |
| [PAPEL] | [DESCRIÇÃO] | [QUEM CONCEDE] |

Matriz completa de papel × recurso × operação: `docs/RegrasNegocio.md`, seção `Regras transversais`.

## Middlewares e pontos de verificação

| Middleware / guarda | Onde se aplica | O que verifica | Resposta em falha |
| --- | --- | --- | --- |
| [NOME] | [ROTAS] | [VERIFICAÇÃO] | [CÓDIGO E CORPO] |

Regra: autorização verificada **no servidor**. Esconder um botão na interface não é controle de acesso.

## Proteções obrigatórias

| Proteção | Situação | Detalhe |
| --- | --- | --- |
| Rate limiting no login | [ATIVO / A DEFINIR] | [LIMITE] |
| Bloqueio após tentativas | [ATIVO / A DEFINIR] | [REGRA] |
| Mensagem de erro genérica no login | [ATIVO / A DEFINIR] | Evitar enumeração de usuários |
| Expiração de sessão inativa | [ATIVO / A DEFINIR] | [VALOR] |
| Invalidação de sessão na troca de senha | [ATIVO / A DEFINIR] | [REGRA] |
| Proteção CSRF | [ATIVO / NÃO APLICÁVEL] | [MECANISMO] |
| Auditoria de acesso | [ATIVO / A DEFINIR] | [O QUE É REGISTRADO] |

## Fluxos

### Login

1. [PASSO]

### Recuperação de senha

1. [PASSO]

- Token de recuperação: uso único, expiração [VALOR].
- Nunca revelar se o e-mail existe.

### Logout

1. [PASSO]

## Dados sensíveis

- Nunca registrar em log: senhas, tokens, respostas de MFA, documentos pessoais completos.
- Nunca indexar credenciais em RAG — ver `docs/RAG.md`.
- Retenção de logs de autenticação: [PERÍODO]

## Testes obrigatórios

- [ ] Login com credenciais válidas.
- [ ] Login com credenciais inválidas.
- [ ] Acesso a recurso protegido sem token.
- [ ] Acesso a recurso protegido com token expirado.
- [ ] Acesso a recurso de outro usuário (IDOR/BOLA).
- [ ] Acesso a recurso administrativo com papel comum.
- [ ] Rate limiting no login.

## Regras de alteração

1. Consultar este arquivo.
2. Consultar `docs/RegrasNegocio.md` para as regras de permissão afetadas.
3. Implementar.
4. Atualizar este arquivo e a matriz de permissões.
5. Executar os testes de autenticação e autorização.
6. Executar Security Specialist — alteração de auth **sempre** exige revisão de segurança.

## Histórico

| Data | Alteração | Motivo | Plano |
| --- | --- | --- | --- |
| [DATA] | [ALTERAÇÃO] | [MOTIVO] | [PLANO] |
