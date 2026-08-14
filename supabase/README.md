# Supabase

Esta pasta contém a infraestrutura versionada do projeto Eclipse 2026 Distribution para PostgreSQL/Supabase.

## Estrutura

```text
supabase/
├── migrations/
│   └── 20260814000000_initial_schema.sql
└── README.md
```

## Migration inicial

A migration inicial cria o modelo relacional definido para o MVP, incluindo participantes, pontos de levantamento, perfis internos, acessos, consentimentos, QR tokens, levantamentos, stock, auditoria e eventos de email.

O ficheiro executável desta pasta é mantido em paralelo com o modelo de referência em `database/schema.sql`.

## Regra de evolução

Depois de o Supabase estar ligado ao repositório, alterações estruturais à base de dados devem ser feitas através de novas migrations versionadas.

Evitar alterações manuais directamente na base de dados de produção, porque isso cria divergência entre o estado real do Supabase e o histórico versionado no GitHub.

Fluxo esperado:

```text
Decisão de produto
      ↓
Migration SQL
      ↓
GitHub
      ↓
Supabase
      ↓
Base de dados
```

A documentação oficial do Supabase recomenda este modelo de migrations para manter o schema sincronizado e rastreável.

## Próximas migrations previstas

- RLS e policies por função e ponto de distribuição;
- funções transacionais para inscrição e levantamento;
- regras de alteração de ponto;
- mecanismos de reversão administrativa;
- estruturas auxiliares para dashboards;
- eventualmente seeds para dados de demonstração.
