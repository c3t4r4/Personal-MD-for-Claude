# Infraestrutura — [NOME DO PROJETO]

> Consultar antes de alterar Docker, Compose, deploy, redes, volumes ou variáveis de ambiente.
> **Este arquivo registra apenas nomes e finalidades. Nunca valores de secrets.**

## Ambientes

| Ambiente | Finalidade | Onde roda | Branch | Observações |
| --- | --- | --- | --- | --- |
| Desenvolvimento | [FINALIDADE] | [LOCAL] | [BRANCH] | [OBSERVAÇÕES] |
| Homologação | [FINALIDADE] | [LOCAL] | [BRANCH] | [OBSERVAÇÕES] |
| Produção | [FINALIDADE] | [LOCAL] | [BRANCH] | [OBSERVAÇÕES] |

## Docker

| Item | Valor |
| --- | --- |
| Docker no desenvolvimento | [SIM/NÃO] |
| Docker nos testes | [SIM/NÃO] |
| Docker no deploy | [SIM/NÃO] |
| Orquestração | [COMPOSE / SWARM / KUBERNETES / NENHUMA] |
| Deploy via Portainer | [SIM/NÃO] |
| Proxy reverso | [TRAEFIK / NGINX / OUTRO / NENHUM] |

### Imagens

| Imagem | Origem | Tag | Usuário do container | Observações |
| --- | --- | --- | --- | --- |
| [IMAGEM] | [REGISTRO] | [TAG FIXA — NUNCA `latest` EM PRODUÇÃO] | [USUÁRIO NÃO-ROOT QUANDO POSSÍVEL] | [OBSERVAÇÕES] |

### Serviços

| Serviço | Imagem | Portas expostas | Depende de | Healthcheck |
| --- | --- | --- | --- | --- |
| [SERVIÇO] | [IMAGEM] | [PORTAS OU "nenhuma"] | [SERVIÇOS] | [SIM/NÃO — COMANDO] |

Regra: expor apenas as portas necessárias. Banco de dados não deve ser exposto ao host em produção.

### Redes

| Rede | Tipo | Externa | Serviços conectados |
| --- | --- | --- | --- |
| [NOME] | [BRIDGE / OVERLAY] | [SIM/NÃO] | [SERVIÇOS] |

### Volumes

| Volume | Tipo | Conteúdo | Persistente | Backup |
| --- | --- | --- | --- | --- |
| [NOME] | [NOMEADO / BIND] | [CONTEÚDO] | [SIM/NÃO] | [ESTRATÉGIA] |

Regra: bind mount de diretório amplo do host é proibido em produção.

## Secrets

**Somente nomes e origem. Nenhum valor real neste arquivo, em commits ou em logs.**

| Nome | Finalidade | Origem | Ambientes |
| --- | --- | --- | --- |
| [NOME] | [FINALIDADE] | [DOCKER SECRET / VARIÁVEL DE AMBIENTE / SECRET MANAGER] | [AMBIENTES] |

- Rotação: [POLÍTICA]
- Nunca em `Dockerfile`, nunca em `docker-compose.yml` versionado, nunca em `ARG`.

## Variáveis de ambiente

| Variável | Finalidade | Obrigatória | Origem | Valor padrão |
| --- | --- | --- | --- | --- |
| [NOME] | [FINALIDADE] | [SIM/NÃO] | [ORIGEM] | [PADRÃO OU "sem padrão"] |

- Arquivo de exemplo: [`.env.example` OU "a definir"]
- `.env` **deve** estar no `.gitignore`.

## Build

```bash
[COMANDOS DE BUILD]
```

## Deploy

### Procedimento

1. [PASSO]

### Rollback

1. [PASSO]

- Tempo estimado de rollback: [VALOR]
- Responsável: [QUEM]

## Observabilidade

| Item | Solução | Onde consultar |
| --- | --- | --- |
| Logs | [SOLUÇÃO] | [LOCAL] |
| Métricas | [SOLUÇÃO] | [LOCAL] |
| Alertas | [SOLUÇÃO] | [LOCAL] |

Regra: logs não podem conter credenciais, tokens nem dados pessoais desnecessários.

## Backup e recuperação

| Item | Frequência | Retenção | Local | Restauração testada em |
| --- | --- | --- | --- | --- |
| [ITEM] | [FREQUÊNCIA] | [RETENÇÃO] | [LOCAL] | [DATA OU "nunca testada"] |

## Regras de alteração

1. Consultar este arquivo.
2. Alterações de infraestrutura exigem confirmação do usuário antes de executar.
3. Nunca alterar redes, volumes ou secrets de produção sem autorização explícita.
4. Implementar.
5. Atualizar este arquivo.
6. Executar Security Specialist — infraestrutura **sempre** exige revisão de segurança.

## Histórico

| Data | Alteração | Ambiente | Motivo | Plano |
| --- | --- | --- | --- | --- |
| [DATA] | [ALTERAÇÃO] | [AMBIENTE] | [MOTIVO] | [PLANO] |
