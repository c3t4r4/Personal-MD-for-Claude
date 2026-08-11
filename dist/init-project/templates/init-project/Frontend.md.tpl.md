# Frontend — [NOME DO PROJETO]

> Consultar antes de criar componentes. Reutilizar o que já existe. Atualizar após alterações aprovadas.

## Stack

| Item | Versão / Detalhe |
| --- | --- |
| Linguagem | [LINGUAGEM] |
| Framework | [FRAMEWORK] |
| Bundler | [BUNDLER] |
| Roteamento | [ROTEADOR] |
| CSS | [TAILWIND / OUTRO / NÃO APLICÁVEL] |
| Componentes | [SHADCN-UI / OUTRO / PRÓPRIOS] |
| Gerenciador de estado | [SOLUÇÃO OU "estado local"] |
| Requisições | [CLIENTE HTTP] |
| Gerenciador de pacotes | [NPM / PNPM / YARN / BUN] |
| Runtime | [VERSÃO DO NODE OU EQUIVALENTE] |

## Design system

| Atributo | Valor |
| --- | --- |
| Cor primária | [COR] |
| Cor de destaque | [COR] |
| Cores de estado | [SUCESSO / ALERTA / ERRO / INFO] |
| Fonte principal | [FONTE] |
| Fonte monoespaçada | [FONTE] |
| Escala tipográfica | [ESCALA] |
| Espaçamento base | [VALOR] |
| Raio de borda | [VALOR] |
| Biblioteca de ícones | [BIBLIOTECA] |
| Tema | [CLARO / ESCURO / AMBOS] |

Regras visuais fixas:

- [REGRA, EX.: NÃO USAR EMOJI COMO ÍCONE]

## Estrutura de diretórios do frontend

```text
[MAPA REAL]
```

## Mapa de componentes

Consultar antes de criar qualquer componente. Se existir equivalente, reutilizar.

| Componente | Arquivo | Finalidade | Usado em | Reutilizável |
| --- | --- | --- | --- | --- |
| [NOME] | [ARQUIVO] | [FINALIDADE] | [TELAS] | [SIM/NÃO] |

## Telas e rotas

| Rota | Tela | Componente raiz | Acesso | Regras de negócio |
| --- | --- | --- | --- | --- |
| [ROTA] | [T-NN] | [ARQUIVO] | [PAPÉIS] | [RN-... — ver `docs/RegrasNegocio.md`] |

A lógica de decisão de cada tela é documentada em `docs/RegrasNegocio.md`, não aqui. Este arquivo trata da forma; aquele trata do comportamento.

## Padrões de estado da interface

| Estado | Componente padrão | Regra |
| --- | --- | --- |
| Carregando | [COMPONENTE] | [QUANDO USAR] |
| Vazio | [COMPONENTE] | [QUANDO USAR] |
| Erro | [COMPONENTE] | [QUANDO USAR] |
| Sem permissão | [COMPONENTE] | [QUANDO USAR] |

## Formulários e validação

- Biblioteca de formulário: [BIBLIOTECA]
- Validação de schema: [BIBLIOTECA]
- Exibição de erro: [PADRÃO]
- Regra: validação no cliente **nunca** substitui validação no servidor.

## Acessibilidade

- Contraste mínimo: [VALOR, PADRÃO 4.5:1]
- Foco visível obrigatório em elementos interativos.
- `aria-label` obrigatório em botões apenas com ícone.
- Navegação por teclado em todos os fluxos principais.
- [OUTROS REQUISITOS]

## Responsividade

| Breakpoint | Largura | Comportamento |
| --- | --- | --- |
| [NOME] | [VALOR] | [COMPORTAMENTO] |

## Testes de frontend

- Framework: [FRAMEWORK]
- Biblioteca de testes de componente: [BIBLIOTECA]
- Mock de rede: [FERRAMENTA]
- Comando: `[COMANDO]`

## Regras de alteração

1. Consultar este arquivo e o mapa de componentes.
2. Consultar `docs/RegrasNegocio.md` se a alteração muda comportamento ou regra de exibição.
3. Reutilizar componente existente sempre que possível.
4. Respeitar o design system.
5. Implementar.
6. Atualizar o mapa de componentes.
7. Atualizar as regras de negócio afetadas.
8. Atualizar ou criar testes.
9. Executar Validator, Tester e Security Specialist.

## Histórico

| Data | Componente / tela | Alteração | Motivo |
| --- | --- | --- | --- |
| [DATA] | [ITEM] | [ALTERAÇÃO] | [MOTIVO] |
