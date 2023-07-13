CREATE TABLE plans (
    plan_id INT PRIMARY KEY,
    plan_name VARCHAR(100),
    price numeric
);

INSERT INTO plans (plan_id, plan_name, price)
VALUES (0, 'trial', 0),
       (1, 'basic monthly', 9.90),
       (2, 'pro monthly', 19.90),
       (3, 'pro annual', 199),
       (4, 'churn', null);

select * from plans;

drop table subscriptions;

CREATE TABLE subscriptions (
    customer_id INT,
    plan_id INT,
    start_date DATE,
    PRIMARY KEY (customer_id, plan_id),
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);

INSERT INTO subscriptions (customer_id, plan_id, start_date)
VALUES (1, 0, '2020-08-01'),
       (1, 1, '2020-08-08'),
       (2, 0, '2020-09-20'),
       (2, 3, '2020-09-27'),
       (11, 0, '2020-11-19'),
       (11, 4, '2020-11-26'),
       (13, 0, '2020-12-15'),
       (13, 1, '2020-12-22'),
       (13, 2, '2020-03-29'),
       (15, 0, '2020-03-17'),
       (15, 2, '2020-03-24'),
       (15, 4, '2020-04-29'),
       (16, 0, '2020-05-31'),
       (16, 1, '2020-06-07'),
       (16, 3, '2020-10-21'),
	   (18, 0, '2020-07-06'),
       (18, 2, '2020-07-13'),
       (19, 0, '2020-06-22'),
       (19, 2, '2020-06-29'),
       (19, 3, '2020-08-29');
       
-- Based off the 8 sample customers provided in the sample subscriptions table below, write a brief description about each customer’s onboarding journey.

select s.customer_id,s.plan_id, plan_name, start_date from subscriptions as s left outer join plans as p on s.plan_id = p.plan_id;

-- Based off the 8 sample customers provided in the sample subscriptions table below, write a brief description about how much each customer’s spends.

select customer_id, sum(price) as Total from subscriptions as s left outer join plans as p on s.plan_id = p.plan_id group by customer_id;

-- Based off the 8 sample customers provided in the sample subscriptions table below, which subscription type is most purchased by customers.

 select s.plan_id, plan_name, count(*) as Total from subscriptions as s left outer join plans as p on s.plan_id = p.plan_id group by plan_id;

-- Based off the 8 sample customers provided in the sample subscriptions table below, which customes purchared which subscription type is first purchased by which customers.
 
 With subscription_sales as(
 select s.plan_id, plan_name, customer_id, start_date, dense_rank() over (partition by plan_id order by start_date) as Ranks from subscriptions as s left outer join plans as p on s.plan_id = p.plan_id)
 
 select plan_id, plan_name, customer_id, start_date from subscription_sales where ranks=1;
 
 -- How many customers has Foodie-Fi ever had?
 
 select count(distinct(customer_id)) as Total_Customers from subscriptions;
 
 -- What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
 
 Select customer_id,count(customer_id) as TotalSub ,s.plan_id, plan_name, start_date, date_format(start_date, '%d') as Dated, date_format(start_date, '%b') as Monthly from subscriptions as s 
 left outer join plans as p on s.plan_id = p.plan_id where s.plan_id =0 group by date_format(start_date, '%b') order by date_format(start_date, '%m');
 
 -- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
 

 select count( distinct (customer_id))  as Total_Churn, ROUND(100.0 * COUNT(s.customer_id)/ (SELECT COUNT(DISTINCT customer_id) FROM subscriptions),1) AS churn_percentage from subscriptions as s 
 left outer join plans as p on s.plan_id = p.plan_id where s.plan_id=4;
 
-- What is the number and percentage of customer plans after their initial free trial?

select s.customer_id, s.plan_id, plan_name, start_date, dense_rank() over (partition by customer_id order by plan_id) from subscriptions as s left outer join plans as p on s.plan_id=p.plan_id order by s.customer_id;

WITH next_plans AS (
SELECT customer_id, plan_id, LEAD(plan_id) OVER(PARTITION BY customer_id ORDER BY plan_id) as next_plan_id FROM subscriptions)

SELECT  next_plan_id AS plan_id, COUNT(customer_id) AS converted_customers,ROUND(100 * COUNT(customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions),1) AS conversion_percentage
FROM next_plans WHERE next_plan_id IS NOT NULL AND plan_id = 0 GROUP BY next_plan_id ORDER BY next_plan_id;

-- What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

WITH next_dates AS (
SELECT customer_id, plan_id, start_date, LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_date FROM subscriptions WHERE start_date <= '2020-12-31')

SELECT plan_id, COUNT(DISTINCT customer_id) AS customers, ROUND(100.0 * COUNT(DISTINCT customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions),1) AS percentage
FROM next_dates WHERE next_date IS NULL GROUP BY plan_id;

-- How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

WITH ranked_cte AS (
select s.customer_id, s.plan_id, plan_name, start_date, lead(s.plan_id) over(partition by customer_id order by start_date) as next_plan_id from subscriptions as s left outer join plans as p on s.plan_id = p.plan_id
where date_format(start_date,'%Y')=2020)

Select customer_id from ranked_cte where plan_id=2 and next_plan_id in (1,0,4);






