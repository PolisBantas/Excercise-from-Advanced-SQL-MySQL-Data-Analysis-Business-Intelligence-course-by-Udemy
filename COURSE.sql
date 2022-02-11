use mavenfuzzyfactory;

SELECT 
    *
FROM
    website_sessions
WHERE
    website_session_id = 1059;
    
SELECT 
    *
FROM
    website_pageviews
WHERE
    website_session_id = 1059;
    
    
SELECT 
    *
FROM
    orders
WHERE
    website_session_id = 1059;
    
SELECT DISTINCT
    utm_source, utm_campaign
FROM
    website_sessions;
    
SELECT 
    website_sessions.utm_content,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_convrt
FROM
    website_sessions
        LEFT JOIN
    orders ON orders.website_session_id = website_sessions.website_session_id
WHERE
    website_sessions.website_session_id BETWEEN 1000 AND 2000
GROUP BY 1
ORDER BY 2 DESC;


SELECT 
    utm_source,
    utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE
    created_at < '2012-04-12'
GROUP BY 1 , 2 , 3
ORDER BY 4 DESC;

SELECT 
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS session_to_order_convrt
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON o.website_session_id = ws.website_session_id
WHERE
    ws.created_at < '2012-04-14'
        AND ws.utm_source = 'gsearch'
        AND ws.utm_campaign = 'nonbrand';
        

SELECT 
    YEAR(created_at),
    WEEK(created_at),
    MIN(DATE(created_at)) AS week_start,
    COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE
    website_session_id BETWEEN 100000 AND 115000
GROUP BY 1 , 2;


SELECT 
    primary_product_id,
    COUNT(DISTINCT CASE
            WHEN items_purchased = 1 THEN order_id
            ELSE NULL
        END) AS count_single_item_orders,
    COUNT(DISTINCT CASE
            WHEN items_purchased = 2 THEN order_id
            ELSE NULL
        END) AS count_two_item_orders
FROM
    orders
WHERE
    order_id BETWEEN 31000 AND 32000
GROUP BY 1;


SELECT 
    -- WEEK(created_at),
    MIN(DATE(created_at)) AS week_start,
    COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE
    created_at < '2012-05-10'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY week(created_at);


SELECT 
    w.device_type,
    COUNT(DISTINCT w.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT w.website_session_id) AS session_to_order_conv_rate
FROM
    website_sessions w
        LEFT JOIN
    orders o ON o.website_session_id = w.website_session_id
WHERE
    w.created_at < '2012-05-11'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY device_type
ORDER BY device_type DESC;


SELECT 
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE
            WHEN device_type = 'desktop' THEN website_session_id
            ELSE NULL
        END) AS dtop_sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) AS dtop_sessions
FROM
    website_sessions
WHERE
    created_at < '2012-06-09'
        AND created_at > '2012-04-15'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);


SELECT 
    pageview_url, COUNT(DISTINCT website_pageview_id) AS pvs
FROM
    website_pageviews
WHERE
    website_pageview_id < 1000
GROUP BY 1
ORDER BY 2 DESC;


create temporary table first_pageview
SELECT 
    website_session_id, MIN(website_pageview_id) AS min_pvs_id
FROM
    website_pageviews
WHERE
    website_pageview_id < 1000
GROUP BY 1;

SELECT 
    w.pageview_url AS entry_page,
    COUNT(DISTINCT f.website_session_id) AS sessions_hitting_this_lander
FROM
    first_pageview f
        LEFT JOIN
    website_pageviews w ON f.min_pvs_id = w.website_pageview_id
GROUP BY 1;


SELECT 
    pageview_url, COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_pageviews
WHERE
    created_at < '2012-06-09'
GROUP BY 1
ORDER BY 2 DESC;


create temporary table tem_table
SELECT 
    website_session_id, MIN(website_pageview_id) AS min_pvs_id
FROM
    website_pageviews
where created_at < '2012-06-12'
group by 1;

SELECT 
    w.pageview_url AS landing_page,
    COUNT(DISTINCT w.website_session_id) AS sessions_hitting_this_landing_page
FROM
    tem_table t
        LEFT JOIN
    website_pageviews w ON t.min_pvs_id = w.website_pageview_id
GROUP BY 1;


-- STEP 1: find the first website_pageview_id for relevant sessions
-- STEP 2: identify the landing page for each session
-- STEP 3: counting pageviews for each sessions, to identify bounces
-- STEP 4: summarizing total sessions and bounced sessions, by LP

SELECT 
    wp.website_session_id,
    MIN(wp.website_pageview_id) AS min_pageview_id
FROM
    website_pageviews wp
        INNER JOIN
    website_sessions ws ON ws.website_session_id = wp.website_session_id
WHERE
    ws.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY wp.website_session_id;

-- same as above but storing the result in a temporary table

create temporary table first_pageviews_demo
SELECT 
    wp.website_session_id,
    MIN(wp.website_pageview_id) AS min_pageview_id
FROM
    website_pageviews wp
        INNER JOIN
    website_sessions ws ON ws.website_session_id = wp.website_session_id
WHERE
    ws.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY wp.website_session_id;

-- next we'll bring in the landing page to each session

create temporary table sessions_w_landing_pages_demo
select f.website_session_id,
wp.pageview_url as landing_page
from first_pageviews_demo f
left join website_pageviews wp 
on wp.website_pageview_id = f.min_pageview_id;

create temporary table bounced_sessions_only
SELECT 
    s.website_session_id,
    s.landing_page,
    COUNT(wp.website_pageview_id) AS count_of_pages_viewed
FROM
    sessions_w_landing_pages_demo s
        LEFT JOIN
    website_pageviews wp ON wp.website_session_id = s.website_session_id
GROUP BY 1 , 2
HAVING COUNT(wp.website_pageview_id) = 1;

SELECT 
    s.landing_page,
    COUNT(DISTINCT s.website_session_id) AS sessions,
    COUNT(DISTINCT b.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT b.website_session_id) / COUNT(DISTINCT s.website_session_id) AS bounce_rate
FROM
    sessions_w_landing_pages_demo s
        LEFT JOIN
    bounced_sessions_only b ON s.website_session_id = b.website_session_id
GROUP BY 1
ORDER BY 1;

-------------------------------------------------


create temporary table first_pageviews
SELECT 
    wp.website_session_id,
    MIN(wp.website_pageview_id) AS min_pageview_id
FROM
    website_pageviews wp
        INNER JOIN
    website_sessions ws ON ws.website_session_id = wp.website_session_id
WHERE
    ws.created_at < '2012-06-14'
GROUP BY wp.website_session_id;

create temporary table sessions_w_landing_pages
select f.website_session_id,
wp.pageview_url as landing_page
from first_pageviews f
left join website_pageviews wp 
on wp.website_pageview_id = f.min_pageview_id
where wp.pageview_url = '/home';

create temporary table bounced_sessions
SELECT 
    s.website_session_id,
    s.landing_page,
    COUNT(wp.website_pageview_id) AS count_of_pages_viewed
FROM
    sessions_w_landing_pages s
        LEFT JOIN
    website_pageviews wp ON wp.website_session_id = s.website_session_id
GROUP BY 1 , 2
HAVING COUNT(wp.website_pageview_id) = 1;

SELECT 
    COUNT(DISTINCT s.website_session_id) AS sessions,
    COUNT(DISTINCT b.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT b.website_session_id) / COUNT(DISTINCT s.website_session_id) AS bounce_rate
FROM
    sessions_w_landing_pages s
        LEFT JOIN
    bounced_sessions b ON s.website_session_id = b.website_session_id;
    
-------------------------------------
    
    
SELECT 
    MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pageview_id
FROM
    website_pageviews
WHERE
    pageview_url = '/lander-1'
        AND created_at IS NOT NULL;
        
create temporary table first_pageviews
SELECT 
    wp.website_session_id,
    MIN(wp.website_pageview_id) AS min_pageview_id
FROM
    website_pageviews wp
        INNER JOIN
    website_sessions ws ON ws.website_session_id = wp.website_session_id
WHERE
    ws.created_at between '2012-06-01' and '2012-08-31'
    
GROUP BY wp.website_session_id;

create temporary table sessions_w_landing_pages
select f.website_session_id,
wp.pageview_url as landing_page
from first_pageviews f
left join website_pageviews wp 
on wp.website_pageview_id = f.min_pageview_id
where wp.pageview_url in ('/home', '/lander-1');

create temporary table bounced_sessions
SELECT 
    s.website_session_id,
    s.landing_page,
    COUNT(wp.website_pageview_id) AS count_of_pages_viewed
FROM
    sessions_w_landing_pages s
        LEFT JOIN
    website_pageviews wp ON wp.website_session_id = s.website_session_id
GROUP BY 1 , 2
HAVING COUNT(wp.website_pageview_id) = 1;


SELECT 
    s.landing_page,
    COUNT(DISTINCT s.website_session_id) AS total_sessions,
    COUNT(DISTINCT b.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT b.website_session_id) / COUNT(DISTINCT s.website_session_id) AS bounce_rate
FROM
    sessions_w_landing_pages s
        LEFT JOIN
    bounced_sessions b ON s.website_session_id = b.website_session_id
GROUP BY 1;

------------------------------------------------


create temporary table first_pageviews_and_count_views
SELECT 
    ws.website_session_id,
    MIN(wp.website_pageview_id) AS first_pageview_id,
    count(wp.website_pageview_id) as count_pageviews
FROM
    website_sessions ws
        INNER JOIN
    website_pageviews wp ON ws.website_session_id = wp.website_session_id
WHERE
    ws.created_at between '2012-06-01' and '2012-08-31'
    and ws.utm_source = 'gsearch'
    and ws.utm_campaign = 'nonbrand'
GROUP BY ws.website_session_id;

create temporary table sessions_w_count_lander_and_created_at
select 
f.website_session_id,
f.first_pageview_id,
f.count_pageviews,
wp.pageview_url as landing_page,
wp.created_at as session_created_at
from first_pageviews_and_count_views f
left join website_pageviews wp on f.first_pageview_id = wp.website_pageview_id;

SELECT 
    MIN(DATE(session_created_at)) AS week_start_date,
    COUNT(DISTINCT CASE
            WHEN count_pageviews = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(website_session_id) AS bounce_rate,
    COUNT(DISTINCT CASE
            WHEN landing_page = '/home' THEN website_session_id
            ELSE NULL
        END) AS home_sessions,
    COUNT(DISTINCT CASE
            WHEN landing_page = '/lander-1' THEN website_session_id
            ELSE NULL
        END) AS lander_sessions
FROM
    sessions_w_count_lander_and_created_at
GROUP BY YEARWEEK(session_created_at);


---------------------------------

SELECT 
        website_sessions.website_session_id,
            website_pageviews.pageview_url,
            website_pageviews.created_at AS pageview_created_at,
            CASE
                WHEN website_pageviews.pageview_url = '/products' THEN 1
                ELSE 0
            END AS products_page,
            CASE
                WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1
                ELSE 0
            END AS mrfuzzy_page,
            CASE
                WHEN website_pageviews.pageview_url = '/cart' THEN 1
                ELSE 0
            END AS cart_page
    FROM
        website_sessions
    LEFT JOIN website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
    WHERE
        website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
            AND website_pageviews.pageview_url IN ('/home' , '/products', '/the-original-mr-fuzzy', '/cart')
    ORDER BY website_sessions.website_session_id , website_pageviews.created_at;



-- now subquerry

SELECT 
    website_session_id,
    MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it
FROM
    (SELECT 
        website_sessions.website_session_id,
            website_pageviews.pageview_url,
            website_pageviews.created_at AS pageview_created_at,
            CASE
                WHEN website_pageviews.pageview_url = '/products' THEN 1
                ELSE 0
            END AS products_page,
            CASE
                WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1
                ELSE 0
            END AS mrfuzzy_page,
            CASE
                WHEN website_pageviews.pageview_url = '/cart' THEN 1
                ELSE 0
            END AS cart_page
    FROM
        website_sessions
    LEFT JOIN website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
    WHERE
        website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
            AND website_pageviews.pageview_url IN ('/home' , '/products', '/the-original-mr-fuzzy', '/cart')
    ORDER BY website_sessions.website_session_id , website_pageviews.created_at) AS pageview_level
GROUP BY website_session_id;

-- now we create a temporary table


create temporary table session_level_made_it_flags_demo
SELECT 
    website_session_id,
    MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it
FROM
    (SELECT 
        website_sessions.website_session_id,
            website_pageviews.pageview_url,
            website_pageviews.created_at AS pageview_created_at,
            CASE
                WHEN website_pageviews.pageview_url = '/products' THEN 1
                ELSE 0
            END AS products_page,
            CASE
                WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1
                ELSE 0
            END AS mrfuzzy_page,
            CASE
                WHEN website_pageviews.pageview_url = '/cart' THEN 1
                ELSE 0
            END AS cart_page
    FROM
        website_sessions
    LEFT JOIN website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
    WHERE
        website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
            AND website_pageviews.pageview_url IN ('/home' , '/products', '/the-original-mr-fuzzy', '/cart')
    ORDER BY website_sessions.website_session_id , website_pageviews.created_at) AS pageview_level
GROUP BY website_session_id;

SELECT 
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE
            WHEN product_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_products,
    COUNT(DISTINCT CASE
            WHEN mrfuzzy_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_cart
FROM
    session_level_made_it_flags_demo;   
    
    


  SELECT 
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE
            WHEN product_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS clicked_to_products,
    COUNT(DISTINCT CASE
            WHEN mrfuzzy_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS clicked_to_mrfuzzy,
    COUNT(DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS clicked_to_cart
FROM
    session_level_made_it_flags_demo;    
    
---------------------- ORRRRRR

SELECT 
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE
            WHEN product_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_products,
    COUNT(DISTINCT CASE
            WHEN mrfuzzy_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_cart
FROM
    (SELECT 
        website_session_id,
            MAX(products_page) AS product_made_it,
            MAX(mrfuzzy_page) AS mrfuzzy_made_it,
            MAX(cart_page) AS cart_made_it
    FROM
        (SELECT 
        website_sessions.website_session_id,
            website_pageviews.pageview_url,
            website_pageviews.created_at AS pageview_created_at,
            CASE
                WHEN website_pageviews.pageview_url = '/products' THEN 1
                ELSE 0
            END AS products_page,
            CASE
                WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1
                ELSE 0
            END AS mrfuzzy_page,
            CASE
                WHEN website_pageviews.pageview_url = '/cart' THEN 1
                ELSE 0
            END AS cart_page
    FROM
        website_sessions
    LEFT JOIN website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
    WHERE
        website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
            AND website_pageviews.pageview_url IN ('/home' , '/products', '/the-original-mr-fuzzy', '/cart')
    ORDER BY website_sessions.website_session_id , website_pageviews.created_at) AS pageview_level
    GROUP BY website_session_id) AS llllllllll;
    
    --------------------
    
    SELECT 
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE
            WHEN product_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS clicked_to_products,
    COUNT(DISTINCT CASE
            WHEN mrfuzzy_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS clicked_to_mrfuzzy,
    COUNT(DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS clicked_to_cart
FROM
    (SELECT 
        website_session_id,
            MAX(products_page) AS product_made_it,
            MAX(mrfuzzy_page) AS mrfuzzy_made_it,
            MAX(cart_page) AS cart_made_it
    FROM
        (SELECT 
        website_sessions.website_session_id,
            website_pageviews.pageview_url,
            website_pageviews.created_at AS pageview_created_at,
            CASE
                WHEN website_pageviews.pageview_url = '/products' THEN 1
                ELSE 0
            END AS products_page,
            CASE
                WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1
                ELSE 0
            END AS mrfuzzy_page,
            CASE
                WHEN website_pageviews.pageview_url = '/cart' THEN 1
                ELSE 0
            END AS cart_page
    FROM
        website_sessions
    LEFT JOIN website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
    WHERE
        website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
            AND website_pageviews.pageview_url IN ('/home' , '/products', '/the-original-mr-fuzzy', '/cart')
    ORDER BY website_sessions.website_session_id , website_pageviews.created_at) AS pageview_level
    GROUP BY website_session_id) AS llllllllll;
    
    ----------------
    
    

SELECT 
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE
            WHEN product_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_products,
    COUNT(DISTINCT CASE
            WHEN mrfuzzy_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_cart,
    COUNT(DISTINCT CASE
            WHEN shipping_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_shipping,
    COUNT(DISTINCT CASE
            WHEN billing_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_billing,
    COUNT(DISTINCT CASE
            WHEN thankyou_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_thankyou
FROM
    (SELECT 
        website_session_id,
            MAX(products_page) AS product_made_it,
            MAX(mrfuzzy_page) AS mrfuzzy_made_it,
            MAX(cart_page) AS cart_made_it,
            MAX(shipping_page) AS shipping_made_it,
            MAX(billing_page) AS billing_made_it,
            MAX(thankyou_page) AS thankyou_made_it
    FROM
        (SELECT 
        website_sessions.website_session_id,
            website_pageviews.pageview_url,
            website_pageviews.created_at AS pageview_created_at,
            CASE
                WHEN website_pageviews.pageview_url = '/products' THEN 1
                ELSE 0
            END AS products_page,
            CASE
                WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1
                ELSE 0
            END AS mrfuzzy_page,
            CASE
                WHEN website_pageviews.pageview_url = '/cart' THEN 1
                ELSE 0
            END AS cart_page,
            CASE
                WHEN website_pageviews.pageview_url = '/shipping' THEN 1
                ELSE 0
            END AS shipping_page,
            CASE
                WHEN website_pageviews.pageview_url = '/billing' THEN 1
                ELSE 0
            END AS billing_page,
            CASE
                WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1
                ELSE 0
            END AS thankyou_page
    FROM
        website_sessions
    LEFT JOIN website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
    WHERE
        website_sessions.utm_source = 'gsearch'
            AND website_sessions.utm_campaign = 'nonbrand'
            AND website_sessions.created_at BETWEEN '2012-08-05' AND '2012-09-05'
    ORDER BY website_sessions.website_session_id , website_pageviews.created_at) AS pageview_level
    GROUP BY website_session_id) AS llllllllllllllllll;
    
    
    SELECT 
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE
            WHEN product_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS clicked_products,
    COUNT(DISTINCT CASE
            WHEN mrfuzzy_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS clicked_mrfuzzy,
    COUNT(DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS clicked_cart,
    COUNT(DISTINCT CASE
            WHEN shipping_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS clicked_shipping,
    COUNT(DISTINCT CASE
            WHEN billing_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS clicked_billing,
    COUNT(DISTINCT CASE
            WHEN thankyou_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS clicked_thankyou
FROM
    (SELECT 
        website_session_id,
            MAX(products_page) AS product_made_it,
            MAX(mrfuzzy_page) AS mrfuzzy_made_it,
            MAX(cart_page) AS cart_made_it,
            MAX(shipping_page) AS shipping_made_it,
            MAX(billing_page) AS billing_made_it,
            MAX(thankyou_page) AS thankyou_made_it
    FROM
        (SELECT 
        website_sessions.website_session_id,
            website_pageviews.pageview_url,
            website_pageviews.created_at AS pageview_created_at,
            CASE
                WHEN website_pageviews.pageview_url = '/products' THEN 1
                ELSE 0
            END AS products_page,
            CASE
                WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1
                ELSE 0
            END AS mrfuzzy_page,
            CASE
                WHEN website_pageviews.pageview_url = '/cart' THEN 1
                ELSE 0
            END AS cart_page,
            CASE
                WHEN website_pageviews.pageview_url = '/shipping' THEN 1
                ELSE 0
            END AS shipping_page,
            CASE
                WHEN website_pageviews.pageview_url = '/billing' THEN 1
                ELSE 0
            END AS billing_page,
            CASE
                WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1
                ELSE 0
            END AS thankyou_page
    FROM
        website_sessions
    LEFT JOIN website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
    WHERE
        website_sessions.utm_source = 'gsearch'
            AND website_sessions.utm_campaign = 'nonbrand'
            AND website_sessions.created_at BETWEEN '2012-08-05' AND '2012-09-05'
    ORDER BY website_sessions.website_session_id , website_pageviews.created_at) AS pageview_level
    GROUP BY website_session_id) AS llllllllllllllllll;
    
    
    ------------------------------
    
    
    
    SELECT 
    MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pageview_id
FROM
    website_pageviews
WHERE
    pageview_url = '/billing-2'
        AND created_at IS NOT NULL;
        


SELECT 
    billing_version_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS billing_to_order_rt
FROM
    (SELECT 
        wp.website_session_id,
            wp.pageview_url AS billing_version_seen,
            o.order_id
    FROM
        website_pageviews wp
    LEFT JOIN orders o ON o.website_session_id = wp.website_session_id
    WHERE
        wp.website_pageview_id >= 53550
            AND wp.created_at < '2012-11-10'
            AND wp.pageview_url IN ('/billing' , '/billing-2')) AS to_orders
GROUP BY 1;


-------------------------------------



SELECT 
    utm_content,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rt
FROM
    website_sessions
        LEFT JOIN
    orders ON orders.website_session_id = website_sessions.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY 1
ORDER BY 2 DESC;


-------------------------------


SELECT 
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE
            WHEN utm_source = 'gsearch' THEN website_session_id
            ELSE NULL
        END) AS gsearch_sessions,
    COUNT(DISTINCT CASE
            WHEN utm_source = 'bsearch' THEN website_session_id
            ELSE NULL
        END) AS bsearch_sessions
FROM
    website_sessions
WHERE
    created_at < '2012-11-29'
        AND created_at > '2012-08-22'
        AND utm_campaign = 'nonbrand'
GROUP BY YEARWEEK(created_at);


--------------------------------


SELECT 
    utm_source,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) AS mobile_sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS pct_mobile
FROM
    website_sessions
WHERE
    created_at > '2012-08-22'
        AND created_at < '2012-11-30'
        AND utm_campaign = 'nonbrand'
GROUP BY 1;


-------------------------------------



SELECT 
    website_sessions.device_type AS device_type,
    website_sessions.utm_source AS utm_source,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rt
FROM
    website_sessions
        LEFT JOIN
    orders ON orders.website_session_id = website_sessions.website_session_id
WHERE
    website_sessions.created_at >= '2012-08-22'
        AND website_sessions.created_at <= '2012-09-18'
        AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1 , 2;


-----------------------------

SELECT 
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND device_type = 'desktop'
            THEN
                website_session_id
            ELSE NULL
        END) AS g_dtop_sessions,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND device_type = 'desktop'
            THEN
                website_session_id
            ELSE NULL
        END) AS b_dtop_sessions,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND device_type = 'desktop'
            THEN
                website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND device_type = 'desktop'
            THEN
                website_session_id
            ELSE NULL
        END) AS b_pct_of_g_dtop,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) AS g_mob_sessions,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) AS b_mob_sessions,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) AS b_pct_of_g_mobile
FROM
    website_sessions
WHERE
    website_sessions.created_at > '2012-11-04'
        AND website_sessions.created_at < '2012-12-22'
        AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY YEARWEEK(created_at);



---------------------------



SELECT 
    CASE
        WHEN http_referer IS NULL THEN 'direct_type_in'
        WHEN
            http_referer = 'https://www.gsearch.com'
                AND utm_source IS NULL
        THEN
            'gsearch_organic'
        WHEN
            http_referer = 'https://www.bsearch.com'
                AND utm_source IS NULL
        THEN
            'bsearch_organic'
        ELSE 'other'
    END AS case1,
    COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE
    website_session_id BETWEEN 100000 AND 115000
GROUP BY 1
ORDER BY 2 DESC;


--------------------------


SELECT 
    YEAR(created_at),
    MONTH(created_at),
    COUNT(DISTINCT CASE
            WHEN utm_campaign = 'nonbrand' THEN website_session_id
            ELSE NULL
        END) AS nonbrand,
    COUNT(DISTINCT CASE
            WHEN utm_campaign = 'brand' THEN website_session_id
            ELSE NULL
        END) AS brand,
    COUNT(DISTINCT CASE
            WHEN utm_campaign = 'brand' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN utm_campaign = 'nonbrand' THEN website_session_id
            ELSE NULL
        END) AS brand_pct_of_nonbrand,
    COUNT(DISTINCT CASE
            WHEN http_referer IS NULL THEN website_session_id
            ELSE NULL
        END) AS direct,
    COUNT(DISTINCT CASE
            WHEN http_referer IS NULL THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN utm_campaign = 'nonbrand' THEN website_session_id
            ELSE NULL
        END) AS direct_pct_of_nonbrand,
    COUNT(DISTINCT CASE
            WHEN
                utm_campaign IS NULL
                    AND http_referer IS NOT NULL
            THEN
                website_session_id
            ELSE NULL
        END) AS organic,
    COUNT(DISTINCT CASE
            WHEN
                utm_campaign IS NULL
                    AND http_referer IS NOT NULL
            THEN
                website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN utm_campaign = 'nonbrand' THEN website_session_id
            ELSE NULL
        END) AS direct_pct_of_nonbrand
FROM
    website_sessions
WHERE
    created_at < '2012-12-23'
GROUP BY 1 , 2;


---------------------------------------



SELECT 
    website_session_id,
    created_at,
    HOUR(created_at) AS hr,
    WEEKDAY(created_at) AS wday,
    QUARTER(created_at) AS qtr
FROM
    website_sessions
WHERE
    website_session_id BETWEEN 150000 AND 155000;
    
    
    
----------------------


SELECT 
    YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM
    website_sessions
        LEFT JOIN
    orders ON orders.website_session_id = website_sessions.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2012-01-01' AND '2012-12-31'
GROUP BY 1 , 2;



SELECT 
    MIN(DATE(website_sessions.created_at)) AS week_start_date,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM
    website_sessions
        LEFT JOIN
    orders ON orders.website_session_id = website_sessions.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2012-01-01' AND '2012-12-31'
GROUP BY YEARWEEK(website_sessions.created_at);


------------------------

SELECT 
    hr,
  --  ROUND(AVG(website_sessions), 1) AS avg_sessions,
    ROUND(AVG(CASE
                WHEN wday = 0 THEN website_sessions
                ELSE NULL
            END),
            1) AS mon,
    ROUND(AVG(CASE
                WHEN wday = 1 THEN website_sessions
                ELSE NULL
            END),
            1) AS tues,
    ROUND(AVG(CASE
                WHEN wday = 2 THEN website_sessions
                ELSE NULL
            END),
            1) AS wen,
    ROUND(AVG(CASE
                WHEN wday = 3 THEN website_sessions
                ELSE NULL
            END),
            1) AS thur,
    ROUND(AVG(CASE
                WHEN wday = 4 THEN website_sessions
                ELSE NULL
            END),
            1) AS fri,
    ROUND(AVG(CASE
                WHEN wday = 5 THEN website_sessions
                ELSE NULL
            END),
            1) AS sat,
    ROUND(AVG(CASE
                WHEN wday = 6 THEN website_sessions
                ELSE NULL
            END),
            1) AS sun
FROM
    (SELECT 
        DATE(created_at) AS created_date,
            WEEKDAY(created_at) AS wday,
            HOUR(created_at) AS hr,
            COUNT(DISTINCT website_session_id) AS website_sessions
    FROM
        website_sessions
    WHERE
        created_at BETWEEN '2012-09-15' AND '2012-11-15'
    GROUP BY 1 , 2 , 3) AS daily_hourly_sessions
GROUP BY 1;


--------------------------------



SELECT 
    primary_product_id,
    COUNT(order_id) AS orders,
    SUM(price_usd) AS revenue,
    SUM(price_usd - cogs_usd) AS margin,
    ROUND(AVG(price_usd), 2) AS aov
FROM
    orders
WHERE
    order_id BETWEEN 10000 AND 11000
GROUP BY 1
ORDER BY 2 DESC;



------------------------------------



SELECT 
    YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    COUNT(order_id) AS number_of_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin
FROM
    orders
WHERE
    created_at < '2013-01-04'
GROUP BY 1 , 2;



----------------------



SELECT 
    YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rt,
    SUM(orders.price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session,
    COUNT(DISTINCT CASE
            WHEN orders.primary_product_id = 1 THEN orders.order_id
            ELSE NULL
        END) AS product_one_orders,
    COUNT(DISTINCT CASE
            WHEN orders.primary_product_id = 2 THEN orders.order_id
            ELSE NULL
        END) AS product_two_orders
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2012-04-01' AND '2013-04-05'
GROUP BY 1 , 2;


------------------------------


SELECT 
    pageview_url
FROM
    website_pageviews
WHERE
    created_at BETWEEN '2013-02-01' AND '2013-03-01';



SELECT 
    pageview_url,
    COUNT(DISTINCT website_pageviews.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_pageviews.website_session_id) as conv_rt
FROM
    website_pageviews
        LEFT JOIN
    orders ON orders.website_session_id = website_pageviews.website_session_id
WHERE
    website_pageviews.created_at BETWEEN '2013-02-01' AND '2013-03-01'
        AND pageview_url IN ('/the-original-mr-fuzzy' , '/the-forever-love-bear')
GROUP BY 1;



------------------------------------



create temporary table products_pageviews
SELECT 
    website_session_id,
    website_pageview_id,
    created_at,
    CASE
        WHEN created_at < '2013-01-06' THEN 'Pre_product_2'
        WHEN created_at > '2013-01-06' THEN 'Post_product_2'
        ELSE 'oohh'
    END AS time_period
FROM
    website_pageviews
WHERE
    created_at BETWEEN '2012-10-06' AND '2013-04-06'
        AND pageview_url = '/products';
        

create temporary table sessions_w_next_pageview_id      
SELECT 
    products_pageviews.time_period,
    products_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_next_pageview_id
FROM
    products_pageviews
        LEFT JOIN
    website_pageviews ON website_pageviews.website_session_id = products_pageviews.website_session_id
        AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id
GROUP BY 1 , 2;



create temporary table sessions_w_next_pageview_url
SELECT 
    sessions_w_next_pageview_id.time_period,
    sessions_w_next_pageview_id.website_session_id,
    website_pageviews.pageview_url AS next_pageview_url
FROM
    sessions_w_next_pageview_id
        LEFT JOIN
    website_pageviews ON website_pageviews.website_pageview_id = sessions_w_next_pageview_id.min_next_pageview_id;
    
    
    SELECT 
    time_period,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE
            WHEN next_pageview_url IS NOT NULL THEN website_session_id
            ELSE NULL
        END) AS w_next_pg,
    COUNT(DISTINCT CASE
            WHEN next_pageview_url IS NOT NULL THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS pct_w_next_page,
    COUNT(DISTINCT CASE
            WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id
            ELSE NULL
        END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE
            WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS pct_to_mrfuzzy,
    COUNT(DISTINCT CASE
            WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id
            ELSE NULL
        END) AS to_lovebear,
    COUNT(DISTINCT CASE
            WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS pct_to_lovebear
FROM
    sessions_w_next_pageview_url
GROUP BY 1
ORDER BY 1 DESC;



------------------------------------


create temporary table sessions_seen_product_pages
SELECT 
    website_session_id,
    website_pageview_id,
    pageview_url AS product_page_seen
FROM
    website_pageviews
WHERE
    created_at BETWEEN '2013-01-06' AND '2013-04-10'
        AND pageview_url IN ('/the-original-mr-fuzzy' , '/the-forever-love-bear');
        
        
SELECT 
    website_pageviews.pageview_url
FROM
    sessions_seen_product_pages
        LEFT JOIN
    website_pageviews ON website_pageviews.website_session_id = sessions_seen_product_pages.website_session_id
        AND website_pageviews.website_pageview_id > sessions_seen_product_pages.website_pageview_id;
        
        
        
create temporary table sessions_product_level_made_it_flag      
SELECT 
    website_session_id,
    CASE
        WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'mrfuzzy'
        WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
        ELSE 'oohh'
    END AS product_seen,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM
    (SELECT 
        sessions_seen_product_pages.website_session_id,
            sessions_seen_product_pages.product_page_seen,
            CASE
                WHEN pageview_url = '/cart' THEN 1
                ELSE 0
            END AS cart_page,
            CASE
                WHEN pageview_url = '/shipping' THEN 1
                ELSE 0
            END AS shipping_page,
            CASE
                WHEN pageview_url = '/billing-2' THEN 1
                ELSE 0
            END AS billing_page,
            CASE
                WHEN pageview_url = '/thank-you-for-your-order' THEN 1
                ELSE 0
            END AS thankyou_page
    FROM
        sessions_seen_product_pages
    LEFT JOIN website_pageviews ON website_pageviews.website_session_id = sessions_seen_product_pages.website_session_id
        AND website_pageviews.website_pageview_id > sessions_seen_product_pages.website_pageview_id
    ORDER BY 1 , website_pageviews.created_at) AS pageview_level
GROUP BY 1 , 2;



SELECT 
    product_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_cart,
    COUNT(DISTINCT CASE
            WHEN shipping_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_shipping,
    COUNT(DISTINCT CASE
            WHEN billing_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_billing,
    COUNT(DISTINCT CASE
            WHEN thankyou_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_thankyou
FROM
    sessions_product_level_made_it_flag
GROUP BY 1;



SELECT 
    product_seen,
    COUNT(DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS product_page_click_rt,
    COUNT(DISTINCT CASE
            WHEN shipping_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS cart_click_rt,
    COUNT(DISTINCT CASE
            WHEN billing_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN shipping_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS shipping_click_rt,
    COUNT(DISTINCT CASE
            WHEN thankyou_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN billing_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS billing_click_rt
FROM
    sessions_product_level_made_it_flag
GROUP BY 1;



---------------------------------




SELECT 
    orders.primary_product_id,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT CASE
            WHEN order_items.product_id = 1 THEN orders.order_id
            ELSE NULL
        END) AS x_sell_prod1,
    COUNT(DISTINCT CASE
            WHEN order_items.product_id = 2 THEN orders.order_id
            ELSE NULL
        END) AS x_sell_prod2,
    COUNT(DISTINCT CASE
            WHEN order_items.product_id = 3 THEN orders.order_id
            ELSE NULL
        END) AS x_sell_prod3,
    COUNT(DISTINCT CASE
            WHEN order_items.product_id = 1 THEN orders.order_id
            ELSE NULL
        END) / COUNT(DISTINCT orders.order_id) AS x_sell_prod1_rt,
    COUNT(DISTINCT CASE
            WHEN order_items.product_id = 2 THEN orders.order_id
            ELSE NULL
        END) / COUNT(DISTINCT orders.order_id) AS x_sell_prod2_rt,
    COUNT(DISTINCT CASE
            WHEN order_items.product_id = 3 THEN orders.order_id
            ELSE NULL
        END) / COUNT(DISTINCT orders.order_id) AS x_sell_prod3_rt
FROM
    orders
        LEFT JOIN
    order_items ON order_items.order_id = orders.order_id
        AND order_items.is_primary_item = 0
WHERE
    orders.order_id BETWEEN 10000 AND 11000
GROUP BY 1;



--------------------------------------------



create temporary table sessions_seeing_cart
SELECT 
    CASE
        WHEN created_at < '2013-09-25' THEN 'A. Pre_Cross_Sell'
        WHEN created_at >= '2013-09-25' THEN 'B. Post_Cross_Sell'
        ELSE ' oohhh'
    END AS time_period,
    website_session_id AS cart_session_id,
    website_pageview_id AS cart_pageview_id
FROM
    website_pageviews
WHERE
    created_at BETWEEN '2013-08-25' AND '2013-10-25'
        AND pageview_url = '/cart';
        
        
create temporary table cart_sessions_seeing_another_page
SELECT 
    sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    MIN(website_pageviews.website_pageview_id) AS pv_id_after_cart
FROM
    sessions_seeing_cart
        LEFT JOIN
    website_pageviews ON website_pageviews.website_session_id = sessions_seeing_cart.cart_session_id
        AND website_pageviews.website_pageview_id > sessions_seeing_cart.cart_pageview_id
GROUP BY 1 , 2
HAVING MIN(website_pageviews.website_pageview_id) IS NOT NULL;



create temporary table pre_post_sessions_orders
SELECT 
    time_period,
    cart_session_id,
    order_id,
    items_purchased,
    price_usd
FROM
    sessions_seeing_cart
        INNER JOIN
    orders ON sessions_seeing_cart.cart_session_id = orders.website_session_id;
    
    
    
SELECT 
    time_period,
    COUNT(DISTINCT cart_session_id) AS cart_sessions,
    SUM(clicked_to_another_page) AS clickthroughs,
    SUM(clicked_to_another_page) / COUNT(DISTINCT cart_session_id) AS cart_crt,
    SUM(items_purchased) / SUM(placed_order) AS products_per_order,
    SUM(price_usd) / SUM(placed_order) AS aov,
    SUM(price_usd) / COUNT(DISTINCT cart_session_id) asrev_per_cart_session
FROM
    (SELECT 
        sessions_seeing_cart.time_period,
            sessions_seeing_cart.cart_session_id,
            CASE
                WHEN cart_sessions_seeing_another_page.cart_session_id IS NULL THEN 0
                ELSE 1
            END AS clicked_to_another_page,
            CASE
                WHEN pre_post_sessions_orders.order_id IS NULL THEN 0
                ELSE 1
            END AS placed_order,
            pre_post_sessions_orders.items_purchased,
            pre_post_sessions_orders.price_usd
    FROM
        sessions_seeing_cart
    LEFT JOIN cart_sessions_seeing_another_page ON sessions_seeing_cart.cart_session_id = cart_sessions_seeing_another_page.cart_session_id
    LEFT JOIN pre_post_sessions_orders ON sessions_seeing_cart.cart_session_id = pre_post_sessions_orders.cart_session_id
    GROUP BY 2) AS full_data
GROUP BY 1;



---------------------------------



SELECT 
    CASE
        WHEN website_sessions.created_at < '2013-12-12' THEN 'A. Pre_Birthday_Bear'
        WHEN website_sessions.created_at >= '2013-12-12' THEN 'B. Post_Birthdat_Bear'
        ELSE 'oohh'
    END AS time_period,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rt,
    SUM(orders.price_usd) AS total_revenue,
    SUM(orders.items_purchased) AS total_products_sold,
    SUM(orders.price_usd) / COUNT(DISTINCT orders.order_id) AS average_order_value,
    SUM(orders.items_purchased) / COUNT(DISTINCT orders.order_id) AS products_per_order,
    SUM(orders.price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM
    website_sessions
        LEFT JOIN
    orders ON orders.website_session_id = website_sessions.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2013-11-12' AND '2014-01-12'
GROUP BY 1;



---------------------------------



SELECT 
    order_items.order_id,
    order_items.order_item_id,
    order_items.price_usd AS price_paid_usd,
    order_items.created_at,
    order_item_refunds.order_item_refund_id,
    order_item_refunds.refund_amount_usd,
    order_item_refunds.created_at
FROM
    order_items
        LEFT JOIN
    order_item_refunds ON order_item_refunds.order_item_id = order_items.order_item_id
WHERE
    order_items.order_id IN ('3489' , '32049', '27061');
    
    
    
    
--------------------------------



SELECT 
    YEAR(order_items.created_at) AS yr,
    MONTH(order_items.created_at) AS mo,
    COUNT(DISTINCT CASE
            WHEN product_id = 1 THEN order_items.order_item_id
            ELSE NULL
        END) AS p1_orders,
    COUNT(DISTINCT CASE
            WHEN product_id = 1 THEN order_item_refunds.order_item_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN order_items.product_id = 1 THEN order_items.order_item_id
            ELSE NULL
        END) AS p1_refund_rt,
    COUNT(DISTINCT CASE
            WHEN product_id = 2 THEN order_items.order_item_id
            ELSE NULL
        END) AS p2_orders,
    COUNT(DISTINCT CASE
            WHEN product_id = 2 THEN order_item_refunds.order_item_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN order_items.product_id = 2 THEN order_items.order_item_id
            ELSE NULL
        END) AS p2_refund_rt,
    COUNT(DISTINCT CASE
            WHEN product_id = 3 THEN order_items.order_item_id
            ELSE NULL
        END) AS p3_orders,
    COUNT(DISTINCT CASE
            WHEN product_id = 3 THEN order_item_refunds.order_item_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN order_items.product_id = 3 THEN order_items.order_item_id
            ELSE NULL
        END) AS p3_refund_rt,
    COUNT(DISTINCT CASE
            WHEN product_id = 4 THEN order_items.order_item_id
            ELSE NULL
        END) AS p4_orders,
    COUNT(DISTINCT CASE
            WHEN product_id = 4 THEN order_item_refunds.order_item_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN order_items.product_id = 4 THEN order_items.order_item_id
            ELSE NULL
        END) AS p4_refund_rt
FROM
    order_items
        LEFT JOIN
    order_item_refunds ON order_items.order_item_id = order_item_refunds.order_item_id
WHERE
    order_items.created_at < '2014-10-15'
GROUP BY 1 , 2;



----------------------------------



create temporary table sessions_w_repeat
SELECT 
    new_sessions.user_id,
    new_sessions.website_session_id AS new_session_id,
    website_sessions.website_session_id AS repeat_session_id
FROM
    (SELECT 
        user_id, website_session_id
    FROM
        website_sessions
    WHERE
        created_at BETWEEN '2014-01-01' AND '2014-11-01'
            AND is_repeat_session = 0) AS new_sessions
        LEFT JOIN
    website_sessions ON website_sessions.user_id = new_sessions.user_id
        AND website_sessions.is_repeat_session = 1
        AND website_sessions.website_session_id > new_sessions.website_session_id
        AND created_at BETWEEN '2014-01-01' AND '2014-11-01';



SELECT 
    repeat_sessions, COUNT(DISTINCT user_id) AS users
FROM
    (SELECT 
        user_id,
            COUNT(DISTINCT new_session_id) AS new_sessions,
            COUNT(DISTINCT repeat_session_id) AS repeat_sessions
    FROM
        sessions_w_repeat
    GROUP BY 1
    ORDER BY 3 DESC) AS user_level
GROUP BY 1;



---------------------------------



create temporary table sessions_w_repeat_for_time_dif
SELECT 
        new_sessions.user_id,
            new_sessions.website_session_id AS new_session_id,
            new_sessions.created_at AS new_session_created_at,
            website_sessions.website_session_id AS repeat_session_id,
            website_sessions.created_at AS repeat_created_at
    FROM
        (SELECT 
        user_id, website_session_id, created_at
    FROM
        website_sessions
    WHERE
        created_at BETWEEN '2014-01-01' AND '2014-11-01'
            AND is_repeat_session = 0) AS new_sessions
    LEFT JOIN website_sessions ON website_sessions.user_id = new_sessions.user_id
        AND website_sessions.is_repeat_session = 1
        AND website_sessions.website_session_id > new_sessions.website_session_id
        AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-11-01';
        
        
        


create temporary table users_first_to_second
SELECT 
    user_id,
    DATEDIFF(second_session_created_at,
            new_session_created_at) AS days_first_to_second_session
FROM
    (SELECT 
        user_id,
            new_session_id,
            new_session_created_at,
            MIN(repeat_session_id) AS second_session_id,
            MIN(repeat_created_at) AS second_session_created_at
    FROM
        sessions_w_repeat_for_time_dif
    WHERE
        repeat_session_id IS NOT NULL
    GROUP BY 1 , 2 , 3) AS first_second;
    
    
    

SELECT 
    AVG(days_first_to_second_session) AS avg_days_first_to_second,
    MIN(days_first_to_second_session) AS min_days_first_to_second,
    MAX(days_first_to_second_session) AS max_days_first_to_second
FROM
    users_first_to_second;
    
    
    
    
---------------------------------------




SELECT 
    CASE
        WHEN
            utm_source IS NULL
                AND http_referer IS NOT NULL
        THEN
            'organic_search'
        WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
        WHEN utm_campaign = 'brand' THEN 'paid_brand'
        WHEN
            utm_source IS NULL
                AND http_referer IS NULL
        THEN
            'direct_type_in'
        WHEN utm_source = 'socialbook' THEN 'paid_social'
    END AS channel_group,
    COUNT(CASE
        WHEN is_repeat_session = 0 THEN website_session_id
        ELSE NULL
    END) AS new_sessions,
    COUNT(CASE
        WHEN is_repeat_session = 1 THEN website_session_id
        ELSE NULL
    END) AS repeat_sessions
FROM
    website_sessions
WHERE
    created_at BETWEEN '2014-01-01' AND '2014-11-05'
GROUP BY 1
ORDER BY 2;



--------------------------------



SELECT 
    CASE
        WHEN website_sessions.is_repeat_session = 0 THEN '0'
        WHEN website_sessions.is_repeat_session = 1 THEN '1'
    END AS is_repeat_session,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rt,
    SUM(orders.price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS rvn_per_session
FROM
    website_sessions
        LEFT JOIN
    orders ON orders.website_session_id = website_sessions.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2014-01-01' AND '2014-11-08'
GROUP BY 1
ORDER BY 1;



---------------------------------------




