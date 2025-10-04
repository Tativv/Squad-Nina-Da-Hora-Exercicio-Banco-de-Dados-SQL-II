# Squad Nina Da Hora - Exercício Banco de Dados SQL II
 Bootcamp Business Intelligence - Instituto Localiza
Este repositório contém o banco de dados utilizado no **Exercício Banco de Dados SQL II** do **Bootcamp Business Intelligence - Instituto Localiza**, pelo squad **Nina Da Hora**.

## 📂 Arquivo
- `DB_Desafio_Loja.db` → Base de dados SQLite contendo todas as tabelas e dados de exemplo.

## 🗄️ Estrutura das Tabelas
- **COSTUMERS** → Armazena os dados dos clientes (ID, nome, email, data de cadastro). 
- **ORDERS** → Contém a lista de produtos (ID, nome, preço, categoria).
- **PRODUCTS** → Informações sobre pedidos (ID, cliente, data, valor total, status).
- **ORDER_ITEMS** → Tabela de ligação que detalha os itens de cada pedido (ID do item, pedido, produto, quantidade, preço unitário).   

## 📝 Exercícios
O banco de dados foi usado para praticar consultas SQL avançadas:
### 1. CTE (Common Table Expressions)
1. Valor médio gasto por cliente usando CTE. 
2. CTE recursiva para gerar sequência de datas e LEFT JOIN com pedidos.

### 2. Window Functions
1. Valor do pedido e rank dos pedidos por cliente.  
2. Média móvel de 3 pedidos para cada cliente. 
3. Valor do primeiro e último pedido de cada cliente usando FIRST_VALUE e LAST_VALUE.

### 3. Estruturas de apoio
1. View de faturamento diário consolidado.
2. Tabela temporária com clientes que compraram nos últimos 30 dias. 

### 4. Joins Avançados
1. Liste todos os produtos e indique se foram vendidos (LEFT JOIN).
2. Clientes que compraram todos os produtos de uma categoria (NOT EXISTS).
3. Clientes que compraram um produto, mas nunca outro (ex.: Eletrônicos vs Roupas).

### 5. Manipulação de Strings e Conversão
1. Mostrar apenas domínio do e-mail dos clientes.
2. Converter nomes dos clientes para MAIÚSCULAS.
3. Criar coluna calculada concatenando nome do cliente e ID do pedido.

### 6. Manipulação de Datas
1. Mostrar apenas o ano da data de cadastro.
2. Calcular dias desde o pedido.
3. Adicionar 7 dias à data do pedido.

### 7. Performance e Otimização
1. Criar índice em orders (customer_id, dt_pedido) e explicar uso.
2. Comparar query com JOIN vs EXISTS.
3. Identificar consultas que podem usar CTE materializada.

### 8. Manipulação de Strings e Conversão
1. Classificar pedidos com CASE WHEN: "Baixo", "Médio", "Alto".
2. Coluna calculada: cliente Ativo ou Inativo.
3. Mostrar NULL como "Sem valor informado".

## 🚀 Como usar
1. Baixe o arquivo `DB_Desafio_Loja.db`.  
2. Abra no [DBeaver](https://dbeaver.io/) ou outro cliente SQLite.  
3. Execute as consultas SQL para praticar e testar o banco.

## 👥 Equipe
**Squad Nina Da Hora**  
## Integrantes
1. Bruna  de Avila Pospiesz
2. Tatiana Varona Villavicencio
3. Vanessa Simão da Costa
4. Pâmella Oliveira
5. Francielle Cristina da C. Silva
6. Ingrid Costa Ferreira
7. Luana Jaime Tocchio
8. Vanelle Rabelo do Nascimento
9. Gisela Keidel
