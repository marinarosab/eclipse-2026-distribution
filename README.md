# Eclipse 2026 Distribution 🌑

Um protótipo de produto que explora como necessidades de negócio, experiência do utilizador e tecnologia podem trabalhar em conjunto para resolver um desafio real de distribuição.

## De onde surgiu esta ideia? 💡
A ideia nasceu a partir de uma situação muito concreta: a elevada procura por óculos próprios para observar um eclipse solar em Portugal e a necessidade de distribuir uma quantidade limitada de unidades por vários pontos de levantamento.

A pergunta inicial foi:

> **Como garantir que cada pessoa recebe apenas um par de óculos, mesmo quando existem vários pontos de distribuição?**

A partir dessa pergunta, o problema deixou de ser apenas uma questão de stock e passou a envolver **jornada do utilizador, regras de negócio, prevenção de fraude, gestão de acessos, privacidade, operações e tecnologia**.

Este projeto é uma experiência prática para transformar esse problema num produto digital funcional.

## O problema 🎯

Quando uma campanha tem muitos pontos físicos de distribuição, alguns desafios aparecem rapidamente:

- Como identificar uma inscrição sem criar fricção para o participante?
- Como impedir que a mesma pessoa levante mais do que uma unidade?
- Como lidar com tentativas de reutilização de um QR Code?
- Como permitir que diferentes pontos trabalhem de forma independente, mas partilhem a mesma informação?
- Que informação precisa de estar disponível para um operador no momento da entrega?
- O que deve ficar reservado ao responsável pela gestão de cada ponto?
- Como pode o organizador acompanhar toda a operação?
- Como reduzir a quantidade de dados pessoais tratados?

O produto foi pensado para responder a estas perguntas antes de começar a pensar na tecnologia.

## A solução 🚀

O **Eclipse 2026 Distribution** organiza a experiência em quatro perspetivas principais:

### Participante 👤

Uma experiência simples para:
- realizar a inscrição;
- receber a confirmação;
- receber o seu QR Code;
- saber onde deverá levantar os óculos;
- utilizar o QR Code no momento da recolha.

O participante não tem acesso às áreas internas de operação ou gestão.

### Operador do ponto de distribuição 📷

Uma interface orientada para a operação do dia a dia:
- autenticação;
- leitura do QR Code através da câmara;
- validação da inscrição;
- confirmação da entrega;
- bloqueio imediato de uma segunda tentativa de levantamento.

A experiência é deliberadamente simples: **o operador precisa de conseguir validar e entregar, não de gerir toda a operação**.

### Responsável pelo ponto 🏪

Uma área protegida para acompanhar a operação do seu ponto:
- stock disponível;
- levantamentos realizados;
- histórico;
- operadores autorizados;
- indicadores relevantes para aquele ponto.

### Organizador 🌍

Uma visão global da campanha:
- inscrições;
- levantamentos;
- stock por ponto;
- stock global;
- tentativas bloqueadas;
- atividade dos diferentes pontos;
- gestão de pontos e utilizadores;
- auditoria da operação.

---

## Perspetiva de produto 🧭

Este projeto não começou por uma stack tecnológica. Começou por um **problema de negócio**.

A lógica seguida foi:
**Problema → necessidades → jornadas → regras de negócio → experiência → arquitetura → tecnologia**

É precisamente nesta interseção entre **negócio, pessoas e tecnologia** que este projeto pretende demonstrar valor.

## Decisões de produto 🧩

### QR Code em vez de NIF

Uma das primeiras ideias consideradas foi utilizar o NIF como identificador único.

A solução foi posteriormente simplificada: **o sistema não precisa de consultar a Autoridade Tributária para resolver este problema**.

Um identificador próprio da campanha associado a um token seguro permite cumprir o objetivo com menos complexidade e com menor tratamento de dados pessoais.

### Token de utilização única

Um QR Code não deve ser tratado como uma autorização permanente.

O sistema foi pensado para que o QR Code esteja associado a um token que, depois de utilizado, passe para um estado que impeça uma segunda utilização.

Isto reduz o risco de situações como:

> “Fiz um screenshot do QR Code e enviei-o para outra pessoa.”

### Separação de responsabilidades

Nem todas as pessoas envolvidas na operação precisam de ver a mesma informação.

Por isso, o produto separa as experiências de:

**Participante → Operador → Responsável do ponto → Organizador**

Esta decisão combina **segurança, privacidade e simplicidade operacional**.

### O operador não precisa de um dashboard complexo

No momento da entrega, a necessidade é objetiva: **ler, validar e entregar**.

Uma interface operacional simples reduz formação, erros e tempo de atendimento.

### Privacidade desde o desenho

O projeto segue uma abordagem de **privacy by design**: recolher apenas os dados necessários, limitar o acesso por função e evitar integrações externas quando não são necessárias para resolver o problema.

---

## 🔐 Dados pessoais e GDPR

A proteção de dados é considerada desde o desenho do produto e não apenas como uma etapa posterior.

A solução procura aplicar princípios como:

- minimização de dados;
- finalidade definida;
- controlo de acesso por função;
- separação entre dados do participante e dados operacionais;
- registo de consentimentos quando aplicável;
- auditoria de operações relevantes;
- não exposição de dados pessoais desnecessários através do QR Code.

> **Nota:** este projeto é um protótipo e não constitui, por si só, uma implementação certificada ou uma avaliação jurídica de conformidade com o RGPD.

---

## 🛣️ Estado do projeto

**Protótipo em desenvolvimento.**

A base de dados PostgreSQL já está criada no Supabase a partir de uma migration versionada no GitHub. A próxima fase é implementar autenticação, permissões e as experiências da aplicação sobre esta base.

### Roadmap

- [x] Definição do problema
- [x] Identificação dos principais perfis de utilizador
- [x] Definição inicial das regras de negócio
- [x] Protótipo inicial da jornada de inscrição
- [ ] Experiência final de inscrição
- [x] Modelo de dados PostgreSQL definido
- [x] Base de dados persistente criada no Supabase
- [ ] Row Level Security e políticas de acesso
- [ ] Autenticação e gestão de permissões
- [ ] QR Code e token de utilização única
- [ ] Área operacional para pontos de distribuição
- [ ] Gestão de stock
- [ ] Dashboard do responsável pelo ponto
- [ ] Dashboard global do organizador
- [ ] Envio de emails transacionais
- [ ] Auditoria e eventos da aplicação
- [ ] Revisão de privacidade e GDPR
- [ ] Deploy e demonstração online

---

## 👩‍💻 Para developers

A camada técnica existe para suportar as decisões de produto — não o contrário.

A arquitetura prevista inclui:

- aplicação web moderna;
- backend e base de dados relacional;
- autenticação;
- autorização baseada em funções e contexto;
- QR Codes e tokens seguros;
- gestão de stock;
- emails transacionais;
- registo de eventos e auditoria;
- deployment contínuo.

A implementação técnica será documentada à medida que o produto evoluir.

### Princípios técnicos

- validações críticas no backend;
- dados sensíveis nunca expostos desnecessariamente no frontend;
- tokens não reutilizáveis para operações de levantamento;
- autorização por função e por ponto de distribuição;
- variáveis e credenciais mantidas fora do código-fonte;
- separação entre configuração e lógica de negócio.

---

## 📁 Estrutura do projeto

```text
.
├── README.md
├── src/
├── database/
│   ├── schema.sql
│   └── README.md
├── supabase/
│   ├── migrations/
│   │   └── 20260814000000_initial_schema.sql
│   └── README.md
├── package.json
├── tsconfig.json
└── ...
```

A estrutura será mantida alinhada com a evolução efetivamente implementada do produto.

---

## 🌱 O que este projeto representa

Mais do que construir uma aplicação, este projeto é um exercício de **product thinking**.

A tecnologia é a ferramenta. O ponto de partida é perceber:

- qual é o problema;
- quem é afetado por ele;
- que comportamentos queremos incentivar ou evitar;
- quais são as regras necessárias;
- que experiência faz sentido para cada pessoa;
- que riscos precisamos de considerar;
- e só então como transformar tudo isto numa solução tecnológica.

É esta ligação entre **pessoas, negócio e tecnologia** que está no centro do projeto.

---

## 📌 Contexto

Este projeto foi inspirado no contexto do **eclipse solar de 12 de agosto de 2026 em Portugal** e desenvolvido como uma experiência de aprendizagem e prototipagem de produto.

Não representa uma plataforma oficial de nenhuma entidade envolvida na distribuição de óculos para o eclipse.

---

## 📄 Licença

A licença e as condições de utilização deste projeto serão definidas à medida que o protótipo evoluir.
