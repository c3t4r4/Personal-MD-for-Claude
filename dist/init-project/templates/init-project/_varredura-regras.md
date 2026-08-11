# Varredura de regras de negócio (`--regras`)

Modo opt-in, caro e demorado. Executar somente quando pedido explicitamente.

## Procedimento

1. Listar as telas e entidades do índice de `docs/RegrasNegocio.md`.
2. Para cada tela ou módulo, extrair do código e dos testes:
   - condições que alteram o que é exibido;
   - condições que habilitam ou desabilitam ações;
   - validações de campo e suas mensagens;
   - transições de estado de entidades;
   - verificações de permissão;
   - valores fixos com significado de negócio (limites, prazos, alçadas);
   - tratamento de caso não previsto (o `else` final).
3. Registrar cada achado como regra com:
   - ID estável `RN-<DOMINIO>-<NNN>`;
   - tabela de decisão (condição → resultado);
   - fonte `arquivo:linha`;
   - status **`⚠ inferida`**.
4. Apresentar as regras inferidas ao usuário em lotes para confirmação. Somente o usuário promove `⚠ inferida` para `confirmada`.
5. Registrar em `Conflitos detectados` toda divergência entre o que o código faz e o que o usuário afirma ser a regra.

## Regras da varredura

- Regra extraída de código pode ser **bug, não regra**. Nunca tratar `⚠ inferida` como verdade.
- Preferir busca AST (`smart_search`, `smart_outline`, `smart_unfold`) à leitura de arquivos inteiros.
- Testes são a melhor fonte: um teste nomeado descreve a regra que alguém quis garantir.
- Não inventar o motivo da regra. Se o porquê não estiver no código nem em comentário, deixar `Motivo da regra: a definir`.

## Delegação

Este é o modo que mais consome contexto, e por isso o que mais ganha com isolamento.

Se o agente `Explore` estiver disponível (FASE 0.5) e houver mais de uma tela ou módulo a varrer, **perguntar** se deve paralelizar. Autorizado: um `Explore` por tela ou módulo, em paralelo.

Cada agente recebe o escopo de **uma** tela ou módulo e devolve **exclusivamente** esta tabela:

```text
| ID | Condição | Resultado | Fonte (arquivo:linha) | Status |
```

com `Status` sempre `⚠ inferida`. Nunca devolve conteúdo de arquivo, trecho de código ou narrativa — só a tabela. É isso que impede a varredura de estourar o contexto principal.

Sem `Explore`, ou sem autorização: varrer inline, um módulo por vez, consolidando em lotes.

## Saída

Atualizar `docs/RegrasNegocio.md` e reportar:

- Quantidade de regras inferidas por tela e por entidade.
- Regras confirmadas pelo usuário durante a varredura.
- Conflitos detectados.
- Telas e módulos que ficaram sem cobertura, e por quê.
