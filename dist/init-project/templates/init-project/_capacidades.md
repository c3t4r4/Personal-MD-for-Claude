# Capacidades — fallback e instalação

Ler **somente quando a FASE 0.5 detectar uma capacidade ausente que seja relevante para este projeto**. Se está tudo disponível, este arquivo não é lido.

O `/init-project` **nunca instala nada**. Não roda `/plugin`, não edita `settings.json`, não baixa arquivo. Apresenta a instrução e segue com o fallback.

## Regra geral

Capacidade ausente **degrada, nunca interrompe**. O comando conclui em qualquer ambiente. O que faltou é registrado em `docs/RAG.md` e no resumo final, para que a decisão de instalar fique com o usuário.

## MCP `claude-mem`

| | |
| --- | --- |
| Para que serve | Corpora do projeto, `smart_search`/`smart_outline`/`smart_unfold` (busca AST sem indexação), `observation_search`, `timeline` |
| Como detectar | Chamar `list_corpora`. Se a ferramenta não existir, está ausente |
| Fallback | `Glob` e `Grep` com escopo. Registrar em `docs/RAG.md`: "sem backend de RAG — recuperação por busca textual" |

Instalar:

```text
/plugin marketplace add thedotmack/claude-mem
/plugin install claude-mem@thedotmack
```

Sem ele, a FASE 7 não constrói corpus nenhum e o protocolo *retrieval-first* de `docs/RAG.md` passa a começar direto pelo `docs/RegrasNegocio.md` e pela busca textual.

## Skill `graphify`

| | |
| --- | --- |
| Para que serve | Grafo de conhecimento do projeto (`graphify-out/`), consultas por travessia |
| Como detectar | `~/.claude/skills/graphify/SKILL.md` existe; ou já há `graphify-out/` no projeto |
| Fallback | Seguir sem grafo. `docs/RAG.md` registra "grafo indisponível" |

Instalar: é uma skill de usuário, não vem de marketplace. Colocar o `SKILL.md` do projeto graphify em `~/.claude/skills/graphify/`. O pacote Python `graphifyy` é instalado pela própria skill na primeira execução.

Lembrete: `/graphify` em repositório grande é caro. Continua sendo **opt-in**, mesmo quando disponível.

## Agentes do harness

| | |
| --- | --- |
| Para que serve | Planner, Coder, Validator, Tester e Security Specialist com contexto isolado |
| Como detectar | `_scan.sh capacidades`, seção `[AGENTES]` |
| Fallback | Executar os papéis inline, na conversa principal. O fluxo e o protocolo `APPROVED`/`REJECTED` não mudam |

Agentes esperados: `planner`, `coder`, `code-reviewer`, `test-engineer`, `security-auditor`.

Criar um agente ausente: arquivo `.md` em `~/.claude/agents/`, com `name:` e `description:` **no primeiro nível** do frontmatter:

```markdown
---
name: test-engineer
description: Quando usar este agente, em uma frase objetiva.
tools: Read, Write, Edit, Bash
---

Instruções do agente.
```

Erro comum: colocar a descrição dentro de `metadata:`. O agente não carrega e some da lista sem aviso. O `_scan.sh capacidades` marca esse caso como `INVALIDO`.

Marketplace com agentes prontos:

```text
/plugin marketplace add wshobson/agents
```

## Skill `ui-ux-pro-max`

| | |
| --- | --- |
| Para que serve | Apoio ao `docs/Frontend.md`: design system, paletas, tipografia, componentes |
| Como detectar | `_scan.sh capacidades`, seção `[SKILLS]` |
| Fallback | Preencher `docs/Frontend.md` apenas com o que a entrevista confirmou; o não decidido vira `a definir` |

Instalar:

```text
/plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill
/plugin install ui-ux-pro-max@ui-ux-pro-max-skill
```

Só é relevante quando o projeto tem frontend.

## Skill `/learn-codebase` (vem com `claude-mem`)

Lê **todo arquivo-fonte na íntegra**. Custa muito em repositório grande.

Nunca executar automaticamente. Oferecer como sugestão no resumo final, com o custo declarado, e deixar a decisão com o usuário.

## Como reportar

Na FASE 0.5, apresentar uma tabela com uma linha por capacidade — `disponível` ou `ausente`, e o fallback que será usado. Repetir no resumo final e gravar em `docs/RAG.md`, datada. Mencionar instalação **apenas** para o que é relevante a este projeto: sem frontend, não sugerir `ui-ux-pro-max`.
