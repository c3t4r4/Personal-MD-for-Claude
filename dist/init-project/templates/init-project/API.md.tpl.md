# API — [NOME DO PROJETO]

> Consultar antes de alterar qualquer API. Atualizar após qualquer alteração aprovada.

## Informações gerais

- Tipo: [REST / GRAPHQL / WEBSOCKET / RPC]
- Versão: [VERSÃO]
- Base URL de desenvolvimento: [URL]
- Base URL de produção: [URL]
- Formato: [JSON / OUTRO]
- Versionamento: [ESTRATÉGIA]

## Autenticação

- Estratégia: [ESTRATÉGIA]
- Header ou mecanismo: [MECANISMO]
- Expiração: [EXPIRAÇÃO]
- Refresh token: [SIM/NÃO]

## Formato de sucesso

```json
{
  "data": {},
  "meta": {}
}
```

## Formato de erro

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Mensagem do erro",
    "details": {}
  }
}
```

## Endpoints

### [RECURSO]

#### `[MÉTODO] [ROTA]`

- Descrição: [DESCRIÇÃO]
- Auth: [SIM/NÃO]
- Permissões: [PERMISSÕES]
- Regras de negócio: [RN-... OU "n/a"]
- Path params: [PARÂMETROS]
- Query params: [PARÂMETROS]
- Headers: [HEADERS]

Request:

```json
{}
```

Response:

```json
{}
```

Códigos:

| Código | Descrição |
| --- | --- |
| 200 | [DESCRIÇÃO] |
| 400 | [DESCRIÇÃO] |
| 401 | [DESCRIÇÃO] |
| 403 | [DESCRIÇÃO] |
| 404 | [DESCRIÇÃO] |
| 500 | [DESCRIÇÃO] |

## Resumo de endpoints

| Método | Rota | Descrição | Auth | Permissão | Regras | Status |
| --- | --- | --- | --- | --- | --- | --- |
| [MÉTODO] | [ROTA] | [DESCRIÇÃO] | [SIM/NÃO] | [PERMISSÃO] | [RN-...] | [ATIVO] |

## APIs externas

| Serviço | Base URL | Autenticação | Timeout | Retry | Observações |
| --- | --- | --- | --- | --- | --- |
| [SERVIÇO] | [URL] | [TIPO] | [VALOR] | [ESTRATÉGIA] | [OBSERVAÇÕES] |

## Regras de alteração

Antes de alterar:

1. Consultar este arquivo.
2. Consultar `docs/RegrasNegocio.md` se a alteração muda comportamento.
3. Procurar endpoint equivalente.
4. Avaliar compatibilidade.
5. Implementar.
6. Atualizar este arquivo.
7. Atualizar as regras de negócio afetadas.
8. Atualizar testes.
9. Executar Validator.
10. Executar Tester.
11. Executar Security Specialist.
12. Atualizar o histórico.

## Histórico

| Data | Endpoint | Alteração | Compatibilidade | Motivo |
| --- | --- | --- | --- | --- |
| [DATA] | [ENDPOINT] | [ALTERAÇÃO] | [COMPATÍVEL / NÃO] | [MOTIVO] |
