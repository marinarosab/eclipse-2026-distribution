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
           ├── Consents
           ├── QR Token
           └── Claim
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
Representa uma inscrição na campanha.

O participante recebe um `participant_code`, mas esse código não deve ser confundido com uma credencial de acesso ao backoffice.

### Consents
Regista os consentimentos associados à inscrição, incluindo a versão da informação/política aceite.

### QR Tokens
Representa a autorização digital de levantamento.

O modelo prevê que seja guardado apenas o **hash do token**, e não o token original em texto simples.

O token pode assumir estados como:

- `active`
- `used`
- `revoked`
- `expired`

### Claims
Representa a entrega efetiva dos óculos.

Existe uma constraint de base de dados que impede mais do que um registo de levantamento confirmado para o mesmo participante.

Isto é deliberado: a regra de “um participante, um levantamento” não pode depender apenas do frontend.

### Inventory
Representa o stock associado a cada ponto.

A estrutura inicial permite distinguir quantidade inicial, recebimentos, ajustes e unidades entregues.

### Audit Logs
Regista ações relevantes para permitir rastreabilidade da operação.

### Email Events
Regista eventos relacionados com emails transacionais sem transformar o histórico de email num mecanismo de autenticação.

## Regras de negócio representadas no modelo

1. Cada participante está associado a um ponto de levantamento.
2. Cada participante pode ter um único QR token.
3. Um token utilizado deixa de poder ser utilizado novamente.
4. Um participante pode ter, no máximo, um levantamento confirmado.
5. Um operador só deverá conseguir executar operações nos pontos a que está autorizado.
6. Um manager só deverá conseguir gerir os pontos que lhe estão atribuídos.
7. O organizer tem uma visão global da organização.
8. Dados pessoais não são colocados diretamente no QR Code.
9. O acesso a dados e operações será posteriormente protegido através de Row Level Security no Supabase.

## PostgreSQL / Supabase

O ficheiro `schema.sql` utiliza PostgreSQL e foi escrito para poder ser aplicado num projeto Supabase.

A aplicação das políticas de Row Level Security ficará numa etapa própria, depois de o projeto Supabase estar criado e o modelo de autenticação confirmado.

Isto permite separar duas decisões:

**Modelo de negócio → autorização técnica**

Primeiro definimos quem pode fazer o quê. Depois traduzimos essas regras para as policies da base de dados.

## Nota sobre evolução

Este é o primeiro modelo do produto, não um contrato definitivo.

À medida que o fluxo de inscrição, levantamento, stock, emails e dashboards for implementado, o schema será evoluído através de alterações versionadas.
