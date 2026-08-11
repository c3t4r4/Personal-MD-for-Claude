# Checklist de cobertura da entrevista

Não é um roteiro linear. É o critério de completude: a entrevista só termina quando cada item estiver **respondido, detectado ou marcado `a definir`**.

O que a FASE 2 já detectou não vira pergunta — vira confirmação. Blocos inteiros que não se apliquem são pulados: sem frontend, nenhuma pergunta de frontend; sem API, nenhuma pergunta de API.

## Projeto

Objetivo de negócio; frontend; backend; monorepo; estrutura a preservar; restrições técnicas, operacionais ou de negócio.

## Regras de negócio

Domínio e glossário; telas principais; papéis de usuário; objetos centrais e seus estados; regras que nunca podem ser violadas; fonte da verdade das regras (manual, legislação, decisão interna); regras que já se sabe estarem em disputa.

## Frontend

Linguagem; framework; gerenciador de pacotes; Tailwind CSS; shadcn/ui; design system existente; componentes a preservar; tema claro/escuro; requisitos de acessibilidade; regras visuais fixas.

Se shadcn/ui não for tecnicamente compatível, explicar a limitação e perguntar a alternativa.

## Backend

Linguagem; framework; arquitetura; banco de dados; ORM ou camada de acesso; filas e jobs; cache; armazenamento de arquivos; migrações a preservar.

## Autenticação

Há login; usuário e senha; OAuth/SSO/social; sessões; JWT; refresh token; recuperação de senha; MFA; perfis, papéis e permissões; recursos que exigem autorização.

Senhas armazenadas localmente: Argon2id é obrigatório. Nunca MD5, SHA-1 ou SHA-256 puro. Nunca texto puro. Nunca em log ou mensagem de erro. Argon2id é hashing de senha, não criptografia reversível.

## API própria

Expõe API; tipo (REST/GraphQL/WebSocket/RPC); consumida pelo frontend; consumida por terceiros; versionamento e padrão; formato de sucesso; formato de erro; autenticação; endpoints sem documentação; OpenAPI ou Swagger.

## APIs externas

Serviços consumidos; finalidade de cada integração; autenticação; onde ficam os segredos; timeout; retry; limite de uso; ambientes separados; documentação específica exigida.

## Banco de dados

Banco; roda em Docker; ORM; migrações versionadas; banco separado para testes; seed; dados que nunca podem ser removidos; regras específicas sobre migrações.

Migrações nunca são removidas ou alteradas sem autorização explícita.

## Infraestrutura

Docker em desenvolvimento, testes e deploy; Docker Compose; Compose como stack Swarm; deploy por Portainer; redes externas; volumes persistentes; Docker Secrets; healthchecks; Traefik ou outro proxy reverso; requisitos de nomes de redes, volumes e secrets; configuração de variáveis de ambiente.

Nunca registrar valores reais de secrets.

## Testes

Framework; testes unitários; integração; end-to-end; dentro do Docker; cobertura mínima; comandos que validam o projeto.

## RAG

Indexar o projeto agora; executar `/learn-codebase` (caro, opt-in); usar `graphify`; caminhos que nunca podem ser indexados além dos padrões.

## Git

Já possui histórico; existe remote; branch principal `main`; branch de desenvolvimento `dev`; criar commit inicial se novo; regras de pull request; branch protegida.

## Organização

Criar ou atualizar README; LICENSE; CONTRIBUTING; SECURITY; documentação de deploy; documentação de variáveis de ambiente; requisitos de LGPD, auditoria ou compliance.

---

Resposta desconhecida vira `a definir`. Nunca invenção.
