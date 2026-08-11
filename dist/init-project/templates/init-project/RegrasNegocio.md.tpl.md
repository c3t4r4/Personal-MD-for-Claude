# Regras de Negócio — [NOME DO PROJETO]

> **Documento de prioridade 3 na ordem de leitura obrigatória.**
> Memória viva de todas as regras de negócio do sistema, tela por tela, e de todas as regras de tomada de decisão na lógica das páginas e dos objetos.

Última atualização: [DATA]

---

## Como usar este documento

**Antes de alterar comportamento:**

1. Localizar a tela em `Índice de telas`.
2. Ler as regras daquela tela e as regras transversais aplicáveis.
3. Verificar se a mudança pedida contradiz alguma regra `confirmada`.
4. Se contradisser, **parar e perguntar** ao usuário antes de implementar.

**Depois de alterar comportamento:**

1. Criar ou atualizar a regra correspondente.
2. Atualizar a rastreabilidade (arquivo e teste).
3. Registrar no `Histórico`.
4. Uma tarefa que muda comportamento **não está concluída** com este documento desatualizado.

**Nunca apagar uma regra.** Regra que deixou de valer é marcada como `revogada`, com data e motivo. O histórico é o que permite entender por que o sistema é como é.

### Status obrigatório em toda regra

| Status | Significado |
| --- | --- |
| `confirmada` | Validada pelo usuário ou pelo negócio. Pode ser tratada como verdade. |
| `⚠ inferida` | Extraída do código, **aguardando confirmação**. Pode ser bug, não regra. Nunca tratar como verdade. |
| `a definir` | Lacuna conhecida. O comportamento ainda não foi decidido. |
| `revogada` | Histórica. Manter com data e motivo da revogação. |

### Convenção de identificadores

| Prefixo | Uso | Exemplo |
| --- | --- | --- |
| `RN-<DOMINIO>-<NNN>` | Regra de negócio | `RN-MANDADO-014` |
| `T-<NN>` | Tela | `T-07` |
| `E-<NOME>` | Entidade / objeto | `E-MANDADO` |
| `RT-<NNN>` | Regra transversal | `RT-003` |

IDs são **estáveis e nunca reutilizados**. Podem ser citados em planos, comentários de código, mensagens de commit e testes.

---

## Glossário do domínio

| Termo | Significado no negócio | Onde aparece no código |
| --- | --- | --- |
| [TERMO] | [SIGNIFICADO] | [ARQUIVO OU SÍMBOLO] |

---

## Índice de telas

| ID | Tela | Rota | Arquivo principal | Papéis com acesso | Regras | Status |
| --- | --- | --- | --- | --- | --- | --- |
| [T-01] | [NOME] | [ROTA] | [ARQUIVO] | [PAPÉIS] | [RN-...] | [STATUS] |

---

## Regras por tela

### T-[NN] — [NOME DA TELA]

- **Objetivo:** [O QUE O USUÁRIO REALIZA NESTA TELA]
- **Rota:** [ROTA]
- **Arquivo:** [ARQUIVO]
- **Acesso:** [PAPÉIS OU "público"]
- **Status:** [confirmada / ⚠ inferida / a definir]

#### Dados exibidos

| Campo | Origem | Formato | Regra de exibição |
| --- | --- | --- | --- |
| [CAMPO] | [ENDPOINT OU CÁLCULO] | [FORMATO] | [QUANDO APARECE] |

#### Ações disponíveis

| Ação | Condição de habilitação | Papel exigido | Efeito | Regra |
| --- | --- | --- | --- | --- |
| [AÇÃO] | [CONDIÇÃO] | [PAPEL] | [EFEITO] | [RN-...] |

#### Validações de campo

| Campo | Obrigatório | Regra | Mensagem ao usuário |
| --- | --- | --- | --- |
| [CAMPO] | [SIM/NÃO] | [REGRA] | [MENSAGEM] |

#### Estados da tela

| Estado | Quando ocorre | O que o usuário vê |
| --- | --- | --- |
| Carregando | [CONDIÇÃO] | [COMPORTAMENTO] |
| Vazio | [CONDIÇÃO] | [COMPORTAMENTO] |
| Erro | [CONDIÇÃO] | [COMPORTAMENTO] |
| Sem permissão | [CONDIÇÃO] | [COMPORTAMENTO] |

#### Efeitos colaterais

- [O QUE ACONTECE ALÉM DA TELA: GRAVAÇÃO, NOTIFICAÇÃO, AUDITORIA, INTEGRAÇÃO]

---

## Tabelas de decisão

Cada ponto de decisão da lógica da página vira uma linha. Uma condição, um resultado, uma fonte.

### RN-[DOMINIO]-[NNN] — [TÍTULO DA REGRA]

- **Tela:** [T-NN]
- **Status:** [confirmada / ⚠ inferida / a definir / revogada]
- **Origem:** [decisão do usuário / manual do negócio / inferida do código / legislação]

| Condição | Resultado | Fonte | Status |
| --- | --- | --- | --- |
| [CONDIÇÃO OBSERVÁVEL] | [O QUE O SISTEMA FAZ] | [ARQUIVO:LINHA] | [STATUS] |

- **Caso não previsto:** [O QUE ACONTECE QUANDO NENHUMA CONDIÇÃO CASA]
- **Motivo da regra:** [POR QUE O NEGÓCIO EXIGE ISSO]

---

## Regras por objeto / entidade

### E-[NOME] — [ENTIDADE]

- **Descrição:** [O QUE REPRESENTA NO NEGÓCIO]
- **Origem do dado:** [SISTEMA, TELA OU INTEGRAÇÃO]
- **Status:** [STATUS]

#### Ciclo de vida

| Estado atual | Evento | Condição | Estado destino | Quem pode | Regra |
| --- | --- | --- | --- | --- | --- |
| [ESTADO] | [EVENTO] | [CONDIÇÃO] | [ESTADO] | [PAPEL] | [RN-...] |

#### Invariantes

Condições que **nunca** podem ser violadas, em nenhuma tela ou endpoint.

| ID | Invariante | Onde é garantido | Status |
| --- | --- | --- | --- |
| [RN-...] | [CONDIÇÃO SEMPRE VERDADEIRA] | [BANCO / API / UI] | [STATUS] |

#### Campos calculados

| Campo | Fórmula | Quando recalcula | Status |
| --- | --- | --- | --- |
| [CAMPO] | [FÓRMULA] | [GATILHO] | [STATUS] |

---

## Regras transversais

### Matriz de permissões

| Papel | Recurso | Ler | Criar | Editar | Excluir | Observação |
| --- | --- | --- | --- | --- | --- | --- |
| [PAPEL] | [RECURSO] | [SIM/NÃO] | [SIM/NÃO] | [SIM/NÃO] | [SIM/NÃO] | [OBSERVAÇÃO] |

### Formatos e convenções

| Item | Regra |
| --- | --- |
| Fuso horário | [FUSO E COMO É ARMAZENADO] |
| Datas exibidas | [FORMATO] |
| Moeda | [MOEDA E ARREDONDAMENTO] |
| Números | [CASAS DECIMAIS E ARREDONDAMENTO] |
| Documentos | [CPF/CNPJ E OUTROS: FORMATO E VALIDAÇÃO] |
| Ordenação padrão | [REGRA] |
| Paginação | [TAMANHO E LIMITE] |

### Regras de cálculo

| ID | Cálculo | Fórmula | Aplicação | Status |
| --- | --- | --- | --- | --- |
| [RT-001] | [NOME] | [FÓRMULA] | [ONDE SE APLICA] | [STATUS] |

---

## Regras de integração

| Sistema externo | Dado recebido | Autoridade | Derivado localmente | Imutável após receber | Status |
| --- | --- | --- | --- | --- | --- |
| [SISTEMA] | [DADO] | [QUEM MANDA NO DADO] | [O QUE É CALCULADO AQUI] | [SIM/NÃO] | [STATUS] |

- **Conflito de dados:** [O QUE PREVALECE QUANDO O EXTERNO DIVERGE DO LOCAL]
- **Indisponibilidade:** [COMPORTAMENTO QUANDO A INTEGRAÇÃO FALHA]

---

## Rastreabilidade

| Regra | Implementada em | Teste que cobre | Verificada em |
| --- | --- | --- | --- |
| [RN-...] | [ARQUIVO:LINHA] | [ARQUIVO DE TESTE] | [DATA] |

Regra `confirmada` sem teste é dívida técnica — registrar em `docs/Progresso.md`.

---

## Regras pendentes e conflitos

### Pendentes de levantamento

| Item | Tela / entidade | O que falta decidir | Bloqueia |
| --- | --- | --- | --- |
| [ITEM] | [ONDE] | [PERGUNTA EM ABERTO] | [O QUE ESTÁ TRAVADO] |

### Conflitos detectados

Divergências entre o que o código faz e o que o negócio diz.

| ID | Regra | O que o código faz | O que o negócio espera | Situação |
| --- | --- | --- | --- | --- |
| [ID] | [RN-...] | [COMPORTAMENTO ATUAL] | [COMPORTAMENTO ESPERADO] | [em análise / aguardando decisão] |

---

## Histórico

| Data | Regra | Alteração | Motivo | Plano |
| --- | --- | --- | --- | --- |
| [DATA] | [RN-...] | [criada / alterada / revogada] | [MOTIVO] | [ARQUIVO DO PLANO] |
