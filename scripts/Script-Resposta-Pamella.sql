
-- 5.3 Crie uma coluna calculada que concatene o nome do cliente com o ID do pedido
SELECT c.nome ||'- Pedido'|| o.order_id AS cliente_pedido
FROM customers c 
JOIN orders o ON o.customer_id = c.customer_id 

-- 6.1 Mostrar apenas o ano da data de cadastro dos clientes
SELECT customer_id,
	   nome,
	   STRFTIME('%Y', dt_cadastro) AS ano_cadastro
FROM customers;

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
