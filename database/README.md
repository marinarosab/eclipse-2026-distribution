# Modelo de dados

Este diretório contém o modelo de dados do Eclipse 2026 Distribution.

O objetivo deste modelo não é apenas guardar informação: é representar as principais regras do produto e criar uma base consistente para a operação.

## Visão geral

```text
Organization
   │
   ├── Distribution Points
   │       ├── Inventory
   │       └── Point Access
   │
   ├── Staff Profiles
   │
   └── Participants
           ├── NIF hash
           ├── Consents
           ├── QR Token
           └── Claims
```

## Entidades principais

### Organizations
Representa a organização responsável pela campanha.

### Distribution Points
Representa cada ponto físico onde os óculos podem ser levantados.

Um ponto pertence a uma organização e tem o seu próprio stock e equipa autorizada.

### Profiles
Representa utilizadores internos autenticados da plataforma.

Existem três funções principais:

- **Organizer** — visão global da campanha;
- **Manager** — gestão de um ou mais pontos autorizados;
- **Operator** — execução da operação de levantamento.

Um participante não precisa de criar uma conta interna.

### Point Access
Liga utilizadores internos aos pontos de distribuição a que podem aceder.

Isto permite que a autorização seja definida por função **e** por contexto.

### Participants
Representa uma inscrição individual válida na campanha e a respetiva autorização de levantamento.

O NIF é utilizado como identificador de unicidade da campanha, mas o modelo não o guarda em texto simples: guarda um hash criptográfico para permitir a validação de duplicados sem expor desnecessariamente o documento na base de dados.

O participante recebe um `participant_code`, que não é uma credencial de acesso ao backoffice.

### Consents
Regista os consentimentos associados à inscrição, incluindo a versão da informação/política aceite.

### QR Tokens
Representa a autorização digital de levantamento.

O modelo prevê que seja guardado apenas o **hash do token**, e não o token original em texto simples.

Cada inscrição tem um único token. Se o participante perder o email, o mesmo token pode ser reenviado; não é criado um segundo token.

O token pode assumir estados como:

- `active`
- `used`
- `revoked`
- `expired`

### Claims
Representa a entrega efetiva dos óculos.

A base de dados permite apenas um levantamento **confirmado** por participante. Uma correção administrativa pode reverter esse registo, mantendo o histórico em vez de apagar a operação.

A reversão não transforma o participante numa nova inscrição nem cria um novo QR Code.

### Inventory
Representa o stock associado a cada ponto.

A estrutura inicial permite distinguir quantidade inicial, recebimentos, ajustes e unidades entregues.

Uma alteração do ponto de levantamento só deve ser permitida enquanto não existir um levantamento confirmado e deve respeitar a disponibilidade de stock do novo ponto.

### Audit Logs
Regista ações relevantes para permitir rastreabilidade da operação, incluindo ações administrativas como reversões.

### Email Events
Regista eventos relacionados com emails transacionais sem transformar o histórico de email num mecanismo de autenticação.

## Regras de negócio acordadas

1. **Uma inscrição válida = uma autorização de levantamento.**
2. O NIF identifica a unicidade da inscrição na campanha.
3. O NIF não é colocado no QR Code nem precisa de ser armazenado em texto simples.
4. Cada participante tem um único QR token.
5. Perder o email não gera um segundo token: o sistema pode reenviar o mesmo token enquanto este estiver válido.
6. Um QR já utilizado não pode ser utilizado novamente.
7. O ponto de levantamento pode ser alterado enquanto o participante ainda não tiver levantado os óculos.
8. A alteração de ponto depende de existir stock disponível no novo ponto.
9. Depois de um levantamento confirmado, o ponto fica bloqueado para essa inscrição.
10. Um operador pode executar o levantamento apenas nos pontos a que está autorizado.
11. Uma reversão de levantamento é uma ação administrativa e não deve ficar disponível ao operador comum.
12. O manager autorizado do ponto pode efetuar uma reversão administrativa, com motivo obrigatório e registo de auditoria.
13. O organizer mantém visão global da campanha.
14. Dados pessoais não são colocados diretamente no QR Code.
15. As regras de acesso serão posteriormente reforçadas através de Row Level Security no Supabase.

## PostgreSQL / Supabase

O ficheiro `schema.sql` utiliza PostgreSQL e foi escrito para poder ser aplicado num projeto Supabase.

A aplicação das políticas de Row Level Security ficará numa etapa própria, depois de o projeto Supabase estar criado e o modelo de autenticação confirmado.

Isto permite separar duas decisões:

**Modelo de negócio → autorização técnica**

Primeiro definimos quem pode fazer o quê. Depois traduzimos essas regras para as policies da base de dados.

## Nota sobre evolução

Este é o primeiro modelo do produto, não um contrato definitivo.

À medida que o fluxo de inscrição, levantamento, stock, emails e dashboards for implementado, o schema será evoluído através de alterações versionadas.
