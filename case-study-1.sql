-- the link to the challenge is on this following website : https://8weeksqlchallenge.com/case-study-1/

/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?


SELECT
  	customer_id,
    SUM(price)
FROM dannys_diner.menu
left join dannys_diner.sales using (product_id)
group by customer_id
order by customer_id

/*
Outcome : 

customer_id	sum
A	76
B	74
C	36
*/

-- 2. How many days has each customer visited the restaurant?

SELECT
  	customer_id,
    count(distinct order_date)
FROM dannys_diner.sales
group by customer_id

/*
Outcome : 

customer_id	count
A	4
B	6
C	2
*/

-- 3. What was the first item from the menu purchased by each customer?

select distinct on (customer_id) customer_id, order_date, product_id
from dannys_diner.sales
order by customer_id,order_date, product_id

/*
Outcome : 

customer_id	order_date	product_id
A	2021-01-01T00:00:00.000Z	1
B	2021-01-01T00:00:00.000Z	2
C	2021-01-01T00:00:00.000Z	3
*/

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select product_id,count(product_id)
from dannys_diner.sales
group by product_id
order by count(product_id) desc
limit 1

/*
Outcome : 

product_id	count
3	8 
*/

-- 5. Which item was the most popular for each customer?

with cte as 
(
 select customer_id, product_id,count(product_id) count_product_id, rank() over (partition by customer_id order by count(product_id) desc )
from dannys_diner.sales
group by customer_id,product_id
order by customer_id,count(product_id) desc
)

select customer_id, product_id
from cte 
where rank=1
order by customer_id, product_id

/*
Outcome : 

customer_id	product_id
A	3
B	1
B	2
B	3
C	3 
*/

-- 6. Which item was purchased first by the customer after they became a member?

with cte as 
(
 select sales.customer_id, order_date, join_date, product_id,
case when order_date >= join_date then 'yes' else 'no' end as test_date
from dannys_diner.sales sales
left join dannys_diner.members members on members.customer_id = sales.customer_id
)
  
select distinct on (customer_id) customer_id, order_date, join_date, product_id
from cte
where test_date='yes'
order by customer_id, order_date


/*
Outcome : 

customer_id	order_date	join_date	product_id
A	2021-01-07T00:00:00.000Z	2021-01-07T00:00:00.000Z	2
B	2021-01-11T00:00:00.000Z	2021-01-09T00:00:00.000Z	1
*/

-- 7. Which item was purchased just before the customer became a member?

with cte as 
(
 select sales.customer_id, order_date, join_date, product_id,
case when order_date >= join_date then 'yes' else 'no' end as test_date
from dannys_diner.sales sales
left join dannys_diner.members members on members.customer_id = sales.customer_id
)
  
select distinct on (customer_id) customer_id, order_date, join_date, product_id
from cte
where test_date='no'
order by customer_id, order_date desc

/*
Outcome : 

customer_id	order_date	join_date	product_id
A	2021-01-01T00:00:00.000Z	2021-01-07T00:00:00.000Z	1
B	2021-01-04T00:00:00.000Z	2021-01-09T00:00:00.000Z	1
C	2021-01-07T00:00:00.000Z	null	3

*/


-- 8. What is the total items and amount spent for each member before they became a member?

- items bought before became a member

	with cte as 
	(
	 select sales.customer_id, order_date, join_date, product_id,
	case when order_date >= join_date then 'yes' else 'no' end as test_date
	from dannys_diner.sales sales
	left join dannys_diner.members members on members.customer_id = sales.customer_id
	)
	  
	select customer_id, product_id , count( product_id)
	from cte
	where test_date='no'
	group by customer_id, product_id


/*
Outcome : 

	customer_id	product_id	count
	A	1	1
	A	2	1
	B	1	1
	B	2	2
	C	3	3
*/


-total amount spent before became a member

	with cte as 
	(
	 select sales.customer_id, order_date, join_date, product_id,
	case when order_date >= join_date then 'yes' else 'no' end as test_date
	from dannys_diner.sales sales
	left join dannys_diner.members members on members.customer_id = sales.customer_id
	)
	  
	select customer_id,  sum( price)
	from cte
	left join dannys_diner.menu menu on menu.product_id = cte.product_id
	where test_date='no'
	group by cte.customer_id
	order by cte.customer_id

/*
Outcome : 

	customer_id	sum
	A	25
	B	40
	C	36
*/

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

	with cte as 
	(
	 select sales.customer_id, order_date, join_date, product_id
	from dannys_diner.sales sales
	left join dannys_diner.members members on members.customer_id = sales.customer_id
	)

	, cte2 as 
	(
	select customer_id, cte.product_id, sum( price) as total_price_product
	from cte
	left join dannys_diner.menu menu on menu.product_id = cte.product_id
	group by cte.customer_id,cte.product_id
	order by cte.customer_id
	  )
	  
	  select customer_id, 
	  SUM(case  when product_id=1 then 2 * 10 *total_price_product else 1*10* total_price_product end)
	  from cte2
	  group by customer_id

/*
Outcome : 

	customer_id	sum
	A	860
	B	940
	C	360
*/

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?



-- Bonus



	 with cte as 
	 (select sales.customer_id, order_date,product_name,price, 
		case when order_date >= join_date then 'Y' else 'N' end as member
	  from dannys_diner.sales sales
	left join dannys_diner.members members on members.customer_id = sales.customer_id
	left join dannys_diner.menu menu  on menu.product_id = sales.product_id
	order by customer_id, order_date
	  )
	  
	  select customer_id ,     case when member='Y' then dense_rank() over (partition by customer_id, member order by order_date ) else null  end  as rank_

	  from cte
	  
/*
Outcome : 
  
	customer_id	rank_
	A	null
	A	null
	A	1
	A	2
	A	3
	A	3
	B	null
	B	null
	B	null
	B	1
	B	2
	B	3
	C	null
	C	null
	C	null

    */