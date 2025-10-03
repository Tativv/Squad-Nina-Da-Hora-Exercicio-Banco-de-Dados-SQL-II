
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