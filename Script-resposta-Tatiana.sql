
-- Calcular quantos dias se passaram desde o pedido
SELECT 
	o.order_id,
	o.dt_pedido AS 'Data Pedido',
	ROUND(JULIANDAY('now') - JULIANDAY(dt_pedido)) AS 'Dias Passados'
	FROM orders o;

-- Adicionar 7 dias à data do pedido
SELECT 
	o.order_id,
	o.dt_pedido AS 'Data Pedido',
	DATE(o.dt_pedido, '+7 days') AS 'Prazo de Entrega'
FROM orders o;

-- Crie uma coluna calculada que mostre se o cliente está Ativo (pedido nos últimos 6 meses) ou Inativo
SELECT
	   c.nome AS 'Cliente',
	 CASE
	  	 WHEN JULIANDAY('now') - JULIANDAY(MAX(o.dt_pedido)) <= 180
	  	 THEN 'Ativo'
	  	 ELSE 'Inativo'
	 END AS Status	
FROM  orders o
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.nome, c.customer_id;