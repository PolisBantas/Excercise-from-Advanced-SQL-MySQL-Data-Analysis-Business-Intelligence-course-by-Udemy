-- FINAL COURSE PROJECT
-- 1 ----------------------------


SELECT 
    YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS quarters,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at < '2015-03-20'
GROUP BY 1 , 2
ORDER BY 1 , 2;



-- 2 ------------------------------------


SELECT 
    YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS quarters,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rt,
    SUM(orders.price_usd) / COUNT(DISTINCT orders.order_id) AS revenue_per_order,
    SUM(orders.price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at < '2015-03-20'
GROUP BY 1 , 2
ORDER BY 1 , 2;



-- 3 ----------------------------



SELECT 
    YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS quarters,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND utm_campaign = 'nonbrand'
            THEN
                orders.order_id
            ELSE NULL
        END) AS gsearch_orders,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND utm_campaign = 'nonbrand'
            THEN
                orders.order_id
            ELSE NULL
        END) AS bsearch_orders,
    COUNT(DISTINCT CASE
            WHEN utm_campaign = 'brand' THEN orders.order_id
            ELSE NULL
        END) AS brand_overall_orders,
    COUNT(DISTINCT CASE
            WHEN
                utm_source IS NULL
                    AND http_referer IS NOT NULL
            THEN
                orders.order_id
            ELSE NULL
        END) AS organic_search_orders,
    COUNT(DISTINCT CASE
            WHEN
                utm_source IS NULL
                    AND http_referer IS NULL
            THEN
                orders.order_id
            ELSE NULL
        END) AS direct_type_in_orders
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at < '2015-03-20'
GROUP BY 1 , 2
ORDER BY 1 , 2;



-- 4 -------------------------------------------------




SELECT 
    YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS quarters,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND utm_campaign = 'nonbrand'
            THEN
                orders.order_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND utm_campaign = 'nonbrand'
            THEN
                website_sessions.website_session_id
            ELSE NULL
        END) AS gsearch_orders_conv_rt,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND utm_campaign = 'nonbrand'
            THEN
                orders.order_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND utm_campaign = 'nonbrand'
            THEN
                website_sessions.website_session_id
            ELSE NULL
        END) AS bsearch_orders_conv_rt,
    COUNT(DISTINCT CASE
            WHEN utm_campaign = 'brand' THEN orders.order_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id
            ELSE NULL
        END) AS brand_overall_orders_conv_rt,
    COUNT(DISTINCT CASE
            WHEN
                utm_source IS NULL
                    AND http_referer IS NOT NULL
            THEN
                orders.order_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN
                utm_source IS NULL
                    AND http_referer IS NOT NULL
            THEN
                website_sessions.website_session_id
            ELSE NULL
        END) AS organic_search_orders_con_rt,
    COUNT(DISTINCT CASE
            WHEN
                utm_source IS NULL
                    AND http_referer IS NULL
            THEN
                orders.order_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN
                utm_source IS NULL
                    AND http_referer IS NULL
            THEN
                website_sessions.website_session_id
            ELSE NULL
        END) AS direct_type_in_orders_conv_rt
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at < '2015-03-20'
GROUP BY 1 , 2
ORDER BY 1 , 2;



-- 5 -------------------------------------------



SELECT 
    YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    SUM(CASE
        WHEN product_id = 1 THEN price_usd
        ELSE NULL
    END) AS mrfuzzy_rvn,
    SUM(CASE
        WHEN product_id = 1 THEN price_usd - cogs_usd
        ELSE NULL
    END) AS mrfuzzy_marg,
    SUM(CASE
        WHEN product_id = 2 THEN price_usd
        ELSE NULL
    END) AS lovebear_rvn,
    SUM(CASE
        WHEN product_id = 2 THEN price_usd - cogs_usd
        ELSE NULL
    END) AS lovebear_marg,
    SUM(CASE
        WHEN product_id = 3 THEN price_usd
        ELSE NULL
    END) AS birthday_rvn,
    SUM(CASE
        WHEN product_id = 3 THEN price_usd - cogs_usd
        ELSE NULL
    END) AS birthday_marg,
    SUM(CASE
        WHEN product_id = 4 THEN price_usd
        ELSE NULL
    END) AS minibear_rvn,
    SUM(CASE
        WHEN product_id = 4 THEN price_usd - cogs_usd
        ELSE NULL
    END) AS minibear_marg,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin
FROM
    order_items
WHERE
    created_at < '2015-03-20'
GROUP BY 1 , 2
ORDER BY 1 , 2;



-- 6-------------------------------



create temporary table products_pageviews
SELECT 
    website_session_id,
    website_pageview_id,
    created_at AS saw_product_page_at
FROM
    website_pageviews
WHERE
    pageview_url = '/products';
    
    
    
    
SELECT 
    YEAR(saw_product_page_at) AS yr,
    MONTH(saw_product_page_at) AS mo,
    COUNT(DISTINCT products_pageviews.website_session_id) AS sessions_to_product_page,
    COUNT(DISTINCT website_pageviews.website_session_id) AS clicked_to_next_page,
    COUNT(DISTINCT website_pageviews.website_session_id) / COUNT(DISTINCT products_pageviews.website_session_id) AS clickthrough_rt,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT products_pageviews.website_session_id) AS products_to_order_rt
FROM
    products_pageviews
        LEFT JOIN
    website_pageviews ON website_pageviews.website_session_id = products_pageviews.website_session_id
        AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id
        LEFT JOIN
    orders ON orders.website_session_id = products_pageviews.website_session_id
GROUP BY 1 , 2;



-- 7 ----------------------------------------




create temporary table primary_products
SELECT 
    order_id, primary_product_id, created_at AS ordered_at
FROM
    orders
WHERE
    created_at > '2014-12-05';
    
    
    

SELECT 
    primary_product_id,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE
            WHEN cross_sell_product_id = 1 THEN order_id
            ELSE NULL
        END) AS xsold_p1,
    COUNT(DISTINCT CASE
            WHEN cross_sell_product_id = 2 THEN order_id
            ELSE NULL
        END) AS xsold_p2,
    COUNT(DISTINCT CASE
            WHEN cross_sell_product_id = 3 THEN order_id
            ELSE NULL
        END) AS xsold_p3,
    COUNT(DISTINCT CASE
            WHEN cross_sell_product_id = 4 THEN order_id
            ELSE NULL
        END) AS xsold_p4,
    COUNT(DISTINCT CASE
            WHEN cross_sell_product_id = 1 THEN order_id
            ELSE NULL
        END) / COUNT(DISTINCT order_id) AS p1_xseel_rt,
    COUNT(DISTINCT CASE
            WHEN cross_sell_product_id = 2 THEN order_id
            ELSE NULL
        END) / COUNT(DISTINCT order_id) AS p2_xseel_rt,
    COUNT(DISTINCT CASE
            WHEN cross_sell_product_id = 3 THEN order_id
            ELSE NULL
        END) / COUNT(DISTINCT order_id) AS p3_xseel_rt,
    COUNT(DISTINCT CASE
            WHEN cross_sell_product_id = 4 THEN order_id
            ELSE NULL
        END) / COUNT(DISTINCT order_id) AS p4_xseel_rt
FROM
    (SELECT 
        primary_products.*,
            order_items.product_id AS cross_sell_product_id
    FROM
        primary_products
    LEFT JOIN order_items ON order_items.order_id = primary_products.order_id
        AND order_items.is_primary_item = 0) AS primary_w_cross_sell
GROUP BY 1;



-- 8 -----------------------------------------




