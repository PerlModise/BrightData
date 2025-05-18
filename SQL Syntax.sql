SELECT
  *

FROM
  "PRODUCT"."ANALYSIS"."SALES"
LIMIT
  10;

WITH Calculation_table AS (
    SELECT 
        Date,
        SUM(Sales) AS total_sales,
        SUM(Cost_of_Sales) AS total_cost,
        SUM(Quantity_Sold) AS total_quantity,
        SUM(Sales) / NULLIF(SUM(Quantity_Sold), 0) AS sales_price_per_unit,
        ((SUM(Sales) - SUM(Cost_of_Sales)) / NULLIF(SUM(Sales), 0)) * 100 AS gross_profit_percent,
        (SUM(Sales) - SUM(Cost_of_Sales)) / NULLIF(SUM(Quantity_Sold), 0) AS gross_profit_per_unit,
        ((SUM(Sales) - SUM(Cost_of_Sales)) / NULLIF(SUM(Sales), 0)) * 100 AS gross_profit_percent_per_unit
    FROM 
        PRODUCT.ANALYSIS.SALES
    GROUP BY 
        Date
),

Average_Price AS (
    SELECT 
        SUM(Sales) / NULLIF(SUM(Quantity_Sold), 0) AS avg_unit_sales_price
    FROM 
        PRODUCT.ANALYSIS.SALES
),

Promotions AS (
    SELECT 
        'Promo A' AS promo,
        (SELECT AVG(Sales / NULLIF(Quantity_Sold, 0)) FROM PRODUCT.ANALYSIS.SALES WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN TO_DATE('01/03/2014', 'DD/MM/YYYY') AND TO_DATE('15/03/2014', 'DD/MM/YYYY')) AS promo_price,
        (SELECT AVG(Quantity_Sold) FROM PRODUCT.ANALYSIS.SALES WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN TO_DATE('01/03/2014', 'DD/MM/YYYY') AND TO_DATE('15/03/2014', 'DD/MM/YYYY')) AS promo_qty,
        (SELECT AVG(Sales / NULLIF(Quantity_Sold, 0)) FROM PRODUCT.ANALYSIS.SALES WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN TO_DATE('14/02/2014', 'DD/MM/YYYY') AND TO_DATE('28/02/2014', 'DD/MM/YYYY')) AS base_price,
        (SELECT AVG(Quantity_Sold) FROM PRODUCT.ANALYSIS.SALES WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN TO_DATE('14/02/2014', 'DD/MM/YYYY') AND TO_DATE('28/02/2014', 'DD/MM/YYYY')) AS base_qty
    FROM dual
    UNION ALL
    SELECT 
        'Promo B',
        (SELECT AVG(Sales / NULLIF(Quantity_Sold, 0)) FROM PRODUCT.ANALYSIS.SALES WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN TO_DATE('10/07/2015', 'DD/MM/YYYY') AND TO_DATE('25/07/2015', 'DD/MM/YYYY')),
        (SELECT AVG(Quantity_Sold) FROM PRODUCT.ANALYSIS.SALES WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN TO_DATE('10/07/2015', 'DD/MM/YYYY') AND TO_DATE('25/07/2015', 'DD/MM/YYYY')),
        (SELECT AVG(Sales / NULLIF(Quantity_Sold, 0)) FROM PRODUCT.ANALYSIS.SALES WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN TO_DATE('25/06/2015', 'DD/MM/YYYY') AND TO_DATE('09/07/2015', 'DD/MM/YYYY')),
        (SELECT AVG(Quantity_Sold) FROM PRODUCT.ANALYSIS.SALES WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN TO_DATE('25/06/2015', 'DD/MM/YYYY') AND TO_DATE('09/07/2015', 'DD/MM/YYYY'))
    FROM dual
    UNION ALL
    SELECT 
        'Promo C',
        (SELECT AVG(Sales / NULLIF(Quantity_Sold, 0)) FROM PRODUCT.ANALYSIS.SALES WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN TO_DATE('05/01/2016', 'DD/MM/YYYY') AND TO_DATE('20/01/2016', 'DD/MM/YYYY')),
        (SELECT AVG(Quantity_Sold) FROM PRODUCT.ANALYSIS.SALES WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN TO_DATE('05/01/2016', 'DD/MM/YYYY') AND TO_DATE('20/01/2016', 'DD/MM/YYYY')),
        (SELECT AVG(Sales / NULLIF(Quantity_Sold, 0)) FROM PRODUCT.ANALYSIS.SALES WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN TO_DATE('21/12/2015', 'DD/MM/YYYY') AND TO_DATE('04/01/2016', 'DD/MM/YYYY')),
        (SELECT AVG(Quantity_Sold) FROM PRODUCT.ANALYSIS.SALES WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN TO_DATE('21/12/2015', 'DD/MM/YYYY') AND TO_DATE('04/01/2016', 'DD/MM/YYYY'))
    FROM dual
),

PED AS (
    SELECT 
        promo,
        base_price,
        promo_price,
        base_qty,
        promo_qty,
        CASE 
            WHEN base_price != 0 AND base_qty != 0 THEN
                ((promo_qty - base_qty) / base_qty) /
                ((promo_price - base_price) / base_price)
            ELSE NULL
        END AS price_elasticity
    FROM Promotions
)

-- Final SELECT: Daily metrics ordered by date DESC
SELECT * 
FROM Calculation_table
ORDER BY TO_DATE(Date, 'DD/MM/YYYY') DESC;

-------Price Elasticity------
WITH promo_analysis AS (
    SELECT 
        'Promo A' AS promo,
        (SELECT AVG(Sales / NULLIF(Quantity_Sold, 0)) 
         FROM PRODUCT.ANALYSIS.SALES 
         WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN '2014-03-01' AND '2014-03-15') AS promo_price,
        (SELECT AVG(Quantity_Sold) 
         FROM PRODUCT.ANALYSIS.SALES 
         WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN '2014-03-01' AND '2014-03-15') AS promo_qty,
        (SELECT AVG(Sales / NULLIF(Quantity_Sold, 0)) 
         FROM PRODUCT.ANALYSIS.SALES 
         WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN '2014-02-14' AND '2014-02-28') AS base_price,
        (SELECT AVG(Quantity_Sold) 
         FROM PRODUCT.ANALYSIS.SALES 
         WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN '2014-02-14' AND '2014-02-28') AS base_qty
    UNION ALL
    SELECT 
        'Promo B',
        (SELECT AVG(Sales / NULLIF(Quantity_Sold, 0)) 
         FROM PRODUCT.ANALYSIS.SALES 
         WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN '2015-07-10' AND '2015-07-25'),
        (SELECT AVG(Quantity_Sold) 
         FROM PRODUCT.ANALYSIS.SALES 
         WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN '2015-07-10' AND '2015-07-25'),
        (SELECT AVG(Sales / NULLIF(Quantity_Sold, 0)) 
         FROM PRODUCT.ANALYSIS.SALES 
         WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN '2015-06-25' AND '2015-07-09'),
        (SELECT AVG(Quantity_Sold) 
         FROM PRODUCT.ANALYSIS.SALES 
         WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN '2015-06-25' AND '2015-07-09')
    UNION ALL
    SELECT 
        'Promo C',
        (SELECT AVG(Sales / NULLIF(Quantity_Sold, 0)) 
         FROM PRODUCT.ANALYSIS.SALES 
         WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN '2016-01-05' AND '2016-01-20'),
        (SELECT AVG(Quantity_Sold) 
         FROM PRODUCT.ANALYSIS.SALES 
         WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN '2016-01-05' AND '2016-01-20'),
        (SELECT AVG(Sales / NULLIF(Quantity_Sold, 0)) 
         FROM PRODUCT.ANALYSIS.SALES 
         WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN '2015-12-21' AND '2016-01-04'),
        (SELECT AVG(Quantity_Sold) 
         FROM PRODUCT.ANALYSIS.SALES 
         WHERE TO_DATE(Date, 'DD/MM/YYYY') BETWEEN '2015-12-21' AND '2016-01-04')
),

elasticity AS (
    SELECT 
        promo,
        base_price,
        promo_price,
        base_qty,
        promo_qty,
        CASE 
            WHEN base_price != 0 AND base_qty != 0 THEN
                ((promo_qty - base_qty) / base_qty) /
                ((promo_price - base_price) / base_price)
            ELSE NULL
        END AS price_elasticity
    FROM promo_analysis
)

SELECT 
    promo,
    price_elasticity
FROM elasticity;