-- =========================================================
-- Part 3 – Zero to Snowflake
-- AISQL Functions for Customer Review Analysis
-- =========================================================

ALTER SESSION SET query_tag =
'{"project":"zero-to-snowflake","part":3,"type":"aisql-analysis"}';

USE ROLE tb_analyst;
USE DATABASE tb_101;
USE WAREHOUSE tb_analyst_wh;

-- =========================================================
-- 1. Sentiment Analysis at Scale
-- =========================================================

-- Analyze customer sentiment across truck brands
SELECT
    truck_brand_name,
    COUNT(*) AS total_reviews,
    AVG(CASE WHEN sentiment >= 0.5 THEN sentiment END) AS avg_positive_score,
    AVG(CASE WHEN sentiment BETWEEN -0.5 AND 0.5 THEN sentiment END) AS avg_neutral_score,
    AVG(CASE WHEN sentiment <= -0.5 THEN sentiment END) AS avg_negative_score
FROM (
    SELECT
        truck_brand_name,
        SNOWFLAKE.CORTEX.SENTIMENT(review) AS sentiment
    FROM harmonized.truck_reviews_v
    WHERE language ILIKE '%en%'
      AND review IS NOT NULL
    LIMIT 10000
)
GROUP BY truck_brand_name
ORDER BY total_reviews DESC;

-- =========================================================
-- 2. AI Classification of Customer Feedback
-- =========================================================

WITH classified_reviews AS (
    SELECT
        truck_brand_name,
        AI_CLASSIFY(
            review,
            ['Food Quality', 'Pricing', 'Service Experience', 'Staff Behavior']
        ):labels[0] AS feedback_category
    FROM harmonized.truck_reviews_v
    WHERE language ILIKE '%en%'
      AND review IS NOT NULL
      AND LENGTH(review) > 30
    LIMIT 10000
)

SELECT
    truck_brand_name,
    feedback_category,
    COUNT(*) AS number_of_reviews
FROM classified_reviews
GROUP BY truck_brand_name, feedback_category
ORDER BY truck_brand_name, number_of_reviews DESC;

-- =========================================================
-- 3. Extract Specific Feedback from Reviews
-- =========================================================

SELECT
    truck_brand_name,
    primary_city,
    LEFT(review, 100) || '...' AS review_preview,
    SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
        review,
        'What specific improvement or complaint is mentioned in this review?'
    ) AS specific_feedback
FROM harmonized.truck_reviews_v
WHERE language = 'en'
  AND review IS NOT NULL
  AND LENGTH(review) > 50
ORDER BY truck_brand_name, primary_city
LIMIT 10000;

-- =========================================================
-- 4. AI-Generated Executive Summaries
-- =========================================================

SELECT
    truck_brand_name,
    AI_SUMMARIZE_AGG(review) AS review_summary
FROM (
    SELECT
        truck_brand_name,
        review
    FROM harmonized.truck_reviews_v
    LIMIT 100
)
GROUP BY truck_brand_name;

-- =========================================================
-- END OF PIPELINE
-- =========================================================
