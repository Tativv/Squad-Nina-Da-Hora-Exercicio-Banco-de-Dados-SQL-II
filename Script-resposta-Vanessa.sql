
-- Indice em Orders
CREATE INDEX idx_orders_customer_data
ON orders(customer_id,dt_pedido)

-- O index será usando quando utilizar joins, filtros e orderna pelo customer_id e dt_pedido

-- Análise consulta mais perfomatica
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

-- Identifique consultas que podem ser reescritas usando CTE materializada para melhorar a performance.
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