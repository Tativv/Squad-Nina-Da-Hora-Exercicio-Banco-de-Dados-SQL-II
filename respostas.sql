
--1.1 Liste o valor médio gasto por cliente
WITH total_por_cliente AS (
    SELECT
        o.customer_id,
        SUM(o.valor_total) AS total_gasto,
        COUNT(o.order_id) AS qtd_pedidos
    FROM orders o
    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.nome,
    ROUND(t.total_gasto * 1.0 / t.qtd_pedidos, 2) AS valor_medio_gasto
FROM customers c
JOIN total_por_cliente t ON c.customer_id = t.customer_id;

-- 1.2 CTE recursiva para gerar uma sequência de datas
WITH RECURSIVE meses(dt) AS (
    SELECT date('now', 'start of month', '-11 months') -- primeiro mês (12 meses atrás)
    UNION ALL
    SELECT date(dt, '+1 month')
    FROM meses
    WHERE dt < date('now', 'start of month')
),
pedidos_por_mes AS (
    SELECT
        strftime('%Y-%m', dt_pedido) AS ano_mes,
        SUM(valor_total) AS total_vendas
    FROM orders
    GROUP BY strftime('%Y-%m', dt_pedido)
)
SELECT
    strftime('%Y-%m', m.dt) AS ano_mes,
    COALESCE(p.total_vendas, 0) AS total_vendas
FROM meses m
LEFT JOIN pedidos_por_mes p ON strftime('%Y-%m', m.dt) = p.ano_mes
ORDER BY ano_mes;

--2.1 Para cada cliente, mostre o valor do pedido e o rank dos pedidos (maior → menor)
	SELECT 
    c.nome AS cliente,
    o.order_id,
    o.valor_total,
    RANK() OVER (PARTITION BY c.customer_id ORDER BY o.valor_total DESC) AS posicao_rank -- o rank vai rankear para cada cliente
    -- separando os dados por cliente atraves do PARTITION BY, dentro de cada cliente, os pedidos sao ordenados pelo valor do maior para o menor
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id -- liga clientes e pedidos pelo campo em comum
WHERE o.status = 'Pago' -- considera só pedidos Pagos
ORDER BY c.nome, posicao_rank; -- vai mostrar os clientes em ordem alfabetica e pela posição do Rank (maior para menor)

-- 2.2 Média móvel de 3 pedidos para cada cliente
SELECT
    o.customer_id AS ID_Cliente,
    o.order_id AS ID_Pedido,         
    o.valor_total AS Valor_Pedido,    
    ROUND(AVG(o.valor_total) OVER (
            PARTITION BY o.customer_id
            ORDER BY o.dt_pedido       
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS Media_Movel_3
FROM orders o
ORDER BY
    o.customer_id,
    o.dt_pedido;

--2.3 Mostre o valor do primeiro e do último pedido de cada cliente usando FIRST_VALUE e LAST_VALUE
SELECT customer_id, primeiro_pedido, ultimo_pedido
FROM (
  SELECT
    customer_id,
    FIRST_VALUE(valor_total) OVER ( -- vai buscar o primeiro pedido de cada cliente
      PARTITION BY customer_id
      ORDER BY dt_pedido ASC -- do mais antigo para o mais novo
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING -- verificando todas as linhas
    ) AS primeiro_pedido,
    LAST_VALUE(valor_total) OVER ( -- vai buscar o último pedido de cada cliente
      PARTITION BY customer_id
      ORDER BY dt_pedido ASC
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS ultimo_pedido,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY dt_pedido ASC) AS rn -- vai numerar os pedidos	de cada cliente e o mais antigo vai receber 1
  FROM orders
  WHERE status <> 'Cancelado' -- não considera os pedidos cancelados
) t
WHERE rn = 1; -- filtra pelo rn para mostrar só a primeira linha

--3.1 Crie uma View que mostre o faturamento diário consolidado
CREATE VIEW IF NOT EXISTS faturamento_diario AS
SELECT
  o.dt_pedido AS dia, -- vai pegar as datas dos pedidos
  SUM(i.quantidade * i.preco_unitario) AS faturamento_total, -- agrupamento por dia somando quantidade * preço unitário
  COUNT(DISTINCT o.order_id) AS qtd_pedidos -- quantos pedidos distintos teve no dia, para que cada pedido seja contado apenas 1x
FROM orders o
JOIN order_items i ON o.order_id = i.order_id
WHERE o.status <> 'Cancelado' -- nao entra no calculo os pedidos cancelados
GROUP BY o.dt_pedido; -- agrupa as linhas por data do pedido

SELECT * FROM faturamento_diario;

-- 3.2 Crie uma Tabela temporária
CREATE TEMP TABLE Clientes_30dias AS
SELECT DISTINCT
    o.customer_id AS ID_Cliente
FROM
    orders o
WHERE
    o.dt_pedido >= DATE('now', '-30 day');

- 4.1 Liste todos os produtos e indique se foram ou não vendidos (LEFT JOIN)
SELECT
    p.product_id AS ID_Produto,
    p.nome AS Nome_Produto,
    CASE
        WHEN oi.order_item_id IS NULL THEN 'Não vendido'
        ELSE 'Vendido'
    END AS Status_Venda
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id;

-- 4.2 Clientes que compraram todos os produtos de uma categoria
SELECT c.customer_id, c.nome AS Nome_Cliente
FROM customers c
WHERE NOT EXISTS (
   SELECT 1
   FROM products p
   WHERE p.categoria = 'Tecnologia'
     AND NOT EXISTS (
         SELECT 1
         FROM orders o
         JOIN order_items oi ON o.order_id = oi.order_id
         WHERE o.customer_id = c.customer_id
           AND oi.product_id = p.product_id
     ));

-- 4.3 Relatório de clientes que compraram um produto, mas nunca outro
WITH categorias AS (
    SELECT DISTINCT categoria FROM products
),
comprou AS (
    SELECT 
        c.customer_id,
        c.nome AS Nome_Cliente,
        p.categoria
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY c.customer_id, p.categoria
),
nao_comprou AS (
    SELECT 
        c.customer_id,
        GROUP_CONCAT(DISTINCT p.categoria) AS Categorias_Nunca_Compradas
    FROM customers c
    CROSS JOIN categorias p
    WHERE NOT EXISTS (
        SELECT 1
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        JOIN products pr ON oi.product_id = pr.product_id
        WHERE o.customer_id = c.customer_id
          AND pr.categoria = p.categoria
    )
    GROUP BY c.customer_id
)
SELECT 
    c.customer_id,
    c.nome AS Nome_Cliente,
    GROUP_CONCAT(DISTINCT comprou.categoria) AS Categorias_Compradas,
    nc.Categorias_Nunca_Compradas
FROM customers c
LEFT JOIN comprou ON c.customer_id = comprou.customer_id
LEFT JOIN nao_comprou nc ON c.customer_id = nc.customer_id
GROUP BY c.customer_id, c.nome, nc.Categorias_Nunca_Compradas;

-- 5.1 Mostre apenas o domínio do e-mail dos clientes (parte depois do @)
SELECT
    SUBSTR(email, INSTR(email, '@') + 1) AS Dominio_Email
FROM 
    customers;

-- 5.2 Converta o nome dos clientes para MAIÚSCULAS
SELECT
    UPPER(nome) AS Nome_Maiusculo
FROM
    customers;

-- 5.3 Crie uma coluna calculada que concatene o nome do cliente com o ID do pedido
SELECT c.nome ||'- Pedido'|| o.order_id AS cliente_pedido
FROM customers c 
JOIN orders o ON o.customer_id = c.customer_id 

-- 6.1 Mostrar apenas o ano da data de cadastro dos clientes
SELECT customer_id,
	   nome,
	   STRFTIME('%Y', dt_cadastro) AS ano_cadastro
FROM customers;

--6.2 Calcular quantos dias se passaram desde o pedido
SELECT 
	o.order_id,
	o.dt_pedido AS 'Data Pedido',
	ROUND(JULIANDAY('now') - JULIANDAY(dt_pedido)) AS 'Dias Passados'
	FROM orders o;

--6.3 Adicionar 7 dias à data do pedido (ex.: prazo de entrega)
SELECT 
	o.order_id,
	o.dt_pedido AS 'Data Pedido',
	DATE(o.dt_pedido, '+7 days') AS 'Prazo de Entrega'
FROM orders o;

-- 7.1 Crie um índice em orders (customer_id, dt_pedido) e explique quando ele será usado
CREATE INDEX idx_orders_customer_data
ON orders(customer_id,dt_pedido)

-- O index será usando quando utilizar joins, filtros e orderna pelo customer_id e dt_pedido

-- 7.2 Compare uma query que faz JOIN com EXISTS E analise qual é mais performática
EXPLAIN QUERY PLAN
SELECT 
	DISTINCT c.nome AS Cliente
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id;

EXPLAIN QUERY PLAN
SELECT
	c.nome AS Cliente
FROM customers c 
WHERE EXISTS (SELECT *
			FROM orders o
			WHERE c.customer_id = o.customer_id); 

/* A query com EXISTS tende a ser mais performática
porque verifica apenas a existência de pedidos para cada cliente
sem precisar unir todas as linhas de orders. */


-- 7.3 Identifique consultas que podem ser reescritas usando CTE materializada para melhorar a performance
-- Faturamento por cliente
WITH pedidos_pagos AS MATERIALIZED (
    SELECT *
    FROM orders
    WHERE status = 'Pago'
)
SELECT 
	c.nome, 
	SUM(p.valor_total) AS total_gasto
FROM customers c
JOIN pedidos_pagos p ON c.customer_id = p.customer_id
GROUP BY c.nome;

-- 8.1 Use CASE WHEN para classificar pedidos em: "Baixo" (<100), "Médio" (100-500), "Alto" (>500)
SELECT order_id,
       customer_id,
       CASE 
       		WHEN (valor_total) < 100 THEN 'Baixo'
       		WHEN (valor_total) < 500 THEN 'Médio'
       		ELSE 'Alto'
       END AS categoria
FROM orders
WHERE status = 'Pago';

--8.2 Crie uma coluna calculada que mostre se o cliente está Ativo (pedido nos últimos 6 meses) ou Inativo
SELECT
	   c.nome,
	 CASE
	  	 WHEN JULIANDAY('now') - JULIANDAY(MAX(o.dt_pedido)) <= 180
	  	 THEN 'Ativo'
	  	 ELSE 'Inativo'
	 END AS Status	
FROM  orders o
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.nome, c.customer_id;

-- 8.3 Em um relatório de pedidos, mostre NULL como "Sem valor informado"
SELECT
   o.order_id AS ID_Pedido,
   o.customer_id AS ID_Cliente,
   CASE
       WHEN o.valor_total IS NULL OR o.valor_total = 0 THEN 'Sem valor informado'
       ELSE CAST(o.valor_total AS TEXT)
   END AS Valor_Pedido,
   o.dt_pedido AS Data_Pedido
FROM
   orders o;