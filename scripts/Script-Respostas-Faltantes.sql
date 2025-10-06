
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

-- 3.2 Crie uma Tabela temporária
CREATE TEMP TABLE Clientes_30dias AS
SELECT DISTINCT
    o.customer_id AS ID_Cliente
FROM
    orders o
WHERE
    o.dt_pedido >= DATE('now', '-30 day');

-- 4.1 Liste todos os produtos e indique se foram ou não vendidos (LEFT JOIN)
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