# Cardápio Virtual

## Informações do Projeto

| Campo | Informação |
|---|---|
| **Disciplina** | Desenvolvimento para Ambientes Móveis |
| **Entrega** | Capstone — Entrega Final |
| **Squad** | 3 |

---

## Integrantes

| Nome |
|---|
| Victor Henrique Santana de Souza |
| Felipe Cunha Ferreira |
| Emanuelle Grace dos Santos Alves Paim |
| João Vitor Pereira Ribeiro |

---

## Acesso para Avaliação

| Perfil | E-mail | Senha |
|---|---|---|
| Administrador | admin@gmail.com | 123456 |
| Cliente | cliente@gmail.com | 123456 |

> Utilize essas credenciais para acessar o sistema com permissões de administrador e avaliar as funcionalidades restritas ao perfil admin (gestão de produtos, pedidos e relatórios).

---

## Links

| Recurso | Link |
|---|---|
| Repositório GitHub | https://github.com/VictorHSSouza/app_cardapio_virtual |
| Demo Web (GitHub Pages) | https://victorhssouza.github.io/app_cardapio_virtual/ |
| Protótipo Figma | https://humid-ethics-80897019.figma.site/ |

---

## Visão Geral da Solução

O **Cardápio Virtual** é um aplicativo mobile desenvolvido em Flutter com backend Firebase, que oferece uma solução completa para gestão de pedidos em restaurantes — tanto para consumo presencial quanto para entregas em domicílio.

### Problema

Restaurantes que operam com cardápios físicos enfrentam dificuldades como erros em pedidos, filas no atendimento e ausência de controle sobre estoque e histórico de vendas. Este aplicativo digitaliza todo o fluxo — do cardápio ao pedido — para clientes e administradores, com dados sincronizados em tempo real via Cloud Firestore.

---

## Tecnologias Utilizadas

| Tecnologia | Finalidade |
|---|---|
| Flutter / Dart | Framework principal — iOS, Android e Web |
| Firebase Authentication | Autenticação de usuários |
| Cloud Firestore | Banco de dados NoSQL em tempo real |
| flutter_local_notifications | Notificações locais sobre status do pedido |
| Material Design 3 | Interface do usuário |

---

## Requisitos Implementados

| # | Requisito | Status |
|---|---|---|
| RF01 | Cadastro de clientes com nome, telefone e e-mail | Implementado |
| RF02 | Autenticação de clientes e administradores | Implementado |
| RF03 | Gestão de produtos pelo administrador (cadastrar, editar, excluir) | Implementado |
| RF04 | Visualização do cardápio com descrição, preço e imagem | Implementado |
| RF05 | Realização de pedidos pelo cliente | Implementado |
| RF06 | Carrinho com adição, remoção e alteração de quantidade | Implementado |
| RF07 | Seleção de forma de pagamento (cartão, PIX, dinheiro) | Implementado |
| RF08 | Acompanhamento de status do pedido pelo cliente | Implementado |
| RF09 | Gestão e atualização de status dos pedidos pelo administrador | Implementado |
| RF10 | Controle de estoque automático conforme pedidos realizados | Implementado |
| RF11 | Relatórios de vendas com filtro por período | Implementado |
| RF12 | Notificações locais sobre mudança de status do pedido | Implementado |
| RF13 | Histórico de pedidos do cliente | Implementado |
| RF14 | Cancelamento de pedido antes do início do preparo | Implementado |

---

## Funcionalidades por Perfil

### Cliente

- Cadastro e autenticação com e-mail e senha
- Visualização do cardápio com filtro por categoria e campo de busca
- Adição de produtos ao carrinho com seleção de quantidade
- Alteração de quantidade e remoção de itens no carrinho
- Escolha entre consumo no local (número da mesa) ou entrega em domicílio (endereço)
- Seleção da forma de pagamento: cartão, PIX ou dinheiro
- Acompanhamento do status do pedido em tempo real
- Recebimento de notificações locais ao ocorrer mudança de status
- Cancelamento de pedido enquanto o status for "aguardando"
- Visualização do histórico de pedidos anteriores
- Visualização dos dados do perfil (nome, e-mail, telefone)

### Administrador

- Acesso ao cardápio completo em modo visualização, sem possibilidade de realizar pedidos
- Gerenciamento de produtos: cadastro, edição e exclusão de itens com nome, descrição, categoria, preço, imagem e estoque
- Visualização de todos os pedidos em tempo real
- Atualização do status dos pedidos (aguardando, em preparo, pronto, entregue, cancelado)
- Acesso a relatórios de vendas com filtro por período (total de vendas, quantidade de pedidos e ticket médio)

> Para promover um usuário a administrador, cadastre-o normalmente e altere o campo `tipo` para `"admin"` diretamente no Firebase Firestore.

---

## Estrutura do Banco de Dados (Cloud Firestore)

```
/usuarios/{uid}
    nome: string
    email: string
    telefone: string
    tipo: "cliente" | "admin"

/produtos/{docId}
    nome: string
    descricao: string
    categoria: string
    preco: number
    imagemUrl: string
    estoque: number

/pedidos/{docId}
    usuarioId: string
    status: "aguardando" | "em preparo" | "pronto" | "entregue" | "cancelado"
    cancelavel: boolean
    valorTotal: number
    tipoAtendimento: "restaurante" | "entrega"
    enderecoEntrega: string
    metodoPagamento: string
    dataPedido: timestamp
    itens: array
```

---

## Instruções de Execução

### Pré-requisitos

- Flutter SDK `^3.11.5`
- Dart SDK
- Android Studio ou Visual Studio Code com extensão Flutter
- Conta Firebase com projeto configurado

### 1. Clonar o repositório

```bash
git clone https://github.com/VictorHSSouza/app_cardapio_virtual.git
cd app_cardapio_virtual
```

### 2. Instalar as dependências

```bash
flutter pub get
```

### 3. Configurar o Firebase

- Adicione o arquivo `google-services.json` em `android/app/`
- As credenciais web já estão configuradas em `lib/main.dart`
- Configure as regras de segurança no Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /usuarios/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    match /produtos/{id} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    match /pedidos/{id} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 4. Executar a aplicação

```bash
# Android ou iOS
flutter run

# Web
flutter run -d chrome
```

### 5. Deploy para GitHub Pages

Execute o script disponível na raiz do projeto:

```bash
deploy_gh_pages.bat
```

---

## Estrutura do Projeto

```
lib/
├── main.dart
├── models/
│   ├── Pessoa.dart
│   ├── Produto.dart
│   └── Pedido.dart
├── services/
│   ├── usuario_service.dart
│   ├── pedido_service.dart
│   └── notificacao_service.dart
└── screens/
    ├── login_screen.dart
    ├── registro_screen.dart
    ├── home_screen.dart
    ├── carrinho_screen.dart
    ├── pagamento_screen.dart
    ├── historico_screen.dart
    ├── admin_produtos_screen.dart
    ├── admin_pedidos_screen.dart
    └── relatorios_screen.dart
```

---

## Desafios Encontrados e Soluções Adotadas

| Desafio | Solução |
|---|---|
| Firebase não inicializando na Web | Configuração manual das `FirebaseOptions` com detecção via `kIsWeb` |
| Permissões negadas no Firestore | Definição de regras de segurança por UID autenticado |
| Controle de estoque com acesso concorrente | Uso de `runTransaction` para garantir atomicidade nas operações |
| Separação de perfis cliente e administrador | Campo `tipo` no Firestore carregado no login |
| Notificações indisponíveis na Web | Detecção de plataforma via `kIsWeb` para uso exclusivo em dispositivos nativos |
| Inconsistência no campo de categoria dos produtos | Leitura com fallback `data['categoria'] ?? data['category']` |

---

## Possíveis Melhorias e Evoluções Futuras

- Integração com gateway de pagamento real (ex.: Stripe, Mercado Pago)
- Notificações push via Firebase Cloud Messaging (FCM)
- Suporte a múltiplos restaurantes em uma mesma plataforma
- Sistema de avaliação e comentários de produtos
- Programa de fidelidade com cupons e descontos
- Impressão de comanda para a cozinha via Bluetooth
- Dashboard com gráficos de vendas por categoria e período
- Modo offline com sincronização automática ao restabelecer conexão

---

## Licença

Projeto acadêmico desenvolvido para a disciplina de Desenvolvimento para Ambientes Móveis. Uso restrito à avaliação institucional.
