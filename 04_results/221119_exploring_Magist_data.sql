
-- How many review are in each score category?
SELECT
	review_score
    , COUNT(*) AS nr_scores
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;
-- Answer (numbers for each score)
-- '1','11571'
-- '2','3158'
-- '3','8120'
-- '4','18929'
-- '5','56593'

SELECT 
	review_score
    , YEAR(review_creation_date) AS year_
    , COUNT(*) AS nr_scores

FROM order_reviews o_rev
INNER JOIN order_items oi
ON o_rev.order_id = oi.order_id
INNER JOIN products p 
ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation pr_trans
ON p.product_category_name = pr_trans.product_category_name

WHERE review_score <= 3 AND product_category_name_english = 'computers_accessories' OR 'electronics'  OR 'pc_games'

 
GROUP BY review_score, year_ 
ORDER BY review_score, year_;



-- 
SELECT
	review_score
    , YEAR(review_creation_date) AS year_ 
    , COUNT(*) AS nr_scores
FROM order_reviews o_rev
INNER JOIN order_items oi
ON o_rev.order_id = oi.order_id

GROUP BY  year_, review_score
ORDER BY  review_score, year_;