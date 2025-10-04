
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