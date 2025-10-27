
-- 1) Recyclable and Low Fat Products
select product_id  from Products
where low_fats ='Y' and recyclable ='Y'
---------------------------------------------
-- 2) Rising Temperature
SELECT w1.id
FROM Weather w1
JOIN Weather w2 ON w1.recordDate = DATEADD(day, 1, w2.recordDate)
WHERE w1.temperature > w2.temperature 
---------------------------------------------
-- 3) Big Countries
select name, population,area
from World 
where area >= 3000000 or population>= 25000000
---------------------------------------------
-- 4) Article Views-I
select distinct author_id as id from Views
where author_id=viewer_id order by author_id 
---------------------------------------------
-- 5) Invalid Tweets
select tweet_id from Tweets
where len(content)>15
---------------------------------------------
-- 6) Replace Employee ID With The Unique Identifier
select unique_id,name
from Employees as e left outer join EmployeeUNI as i on e.id=i.id 
---------------------------------------------
-- 7) Product Sales Analysis I
select product_name, year,price 
from Sales s join Product p on s.product_id=p.product_id   
---------------------------------------------
-- 8) Customer Who Visited but Did Not Make Any Transactions
select distinct customer_id,count(customer_id) count_no_trans 
from Visits v
where v.visit_id not in (select visit_id from Transactions)
group by customer_id
---------------------------------------------
--9) Rising Temperature
with target_table as ( 
	select	id,
		(lag(temperature) over(order by recordDate)) as [prevday_temp],
        temperature,
		(lag(recordDate) over(order by recordDate)) as [prevday_day],
        recordDate  
	from Weather )
SELECT 
    id
FROM
    target_table
WHERE
    temperature > prevday_temp
    and DATEDIFF(day, prevday_day, recordDate)=1;
---------------------------------------------
-- 10) Average Time of Process per Machine
WITH START_T
AS
(
    SELECT  machine_id,process_id,timestamp
    from Activity
    where activity_type='start'
),
END_T
AS
(
    SELECT machine_id,process_id,timestamp
    from Activity
    where activity_type='end'
)

select START_T.machine_id,round(avg(END_T.timestamp-START_T.timestamp),3) as processing_time
from START_T join END_T on END_T.machine_id=START_T.machine_id
group by START_T.machine_id;

-------------------------------------------------------------------------
-- 11) Employee Bonus
select name,bonus
from Employee E left outer join Bonus B on E.empId=B.empId
where B.bonus<1000 or B.bonus is null
-------------------------------------------------------------------------
-- 12) Students and Examinations
select s.student_id,s.student_name,su.subject_name,count(e.subject_name) as attended_exams
from Students s cross join Subjects su left outer join Examinations e on s.student_id=e.student_id and su.subject_name=e.subject_name
group by s.student_id,s.student_name,su.subject_name
order by s.student_id 
-------------------------------------------------------------------------
-- 13) Managers with at Least 5 Direct Reports
select name 
from Employee
where id = (select managerID  from Employee 
where managerID is not null
group by managerID
having count(managerID)>=5)
--------------------------------------------------------------------------
-- 14) Confirmation Rate
WITH target_t AS (
    SELECT
        s.user_id,
        CAST(SUM(CASE WHEN c.action = 'confirmed' THEN 1 ELSE 0 END) AS decimal(4,2)) AS confirmed_actions,
        CAST(COUNT(c.action) AS DECIMAL(4, 2)) AS total 
    FROM
        Signups s LEFT OUTER JOIN Confirmations c 
		ON s.user_id = c.user_id
    GROUP BY
        s.user_id )
SELECT
    user_id,
    ROUND(IIF(total = 0,0.00,(confirmed_actions/total) ),2 ) AS confirmation_rate 
FROM
    target_t;
----------------------------------------------------------------------------------
-- 15) Not Boring Movies
select id,movie,description,rating
from Cinema 
where id % 2 = 1 and description!='boring'
order by rating desc
----------------------------------------------------------------------------------
-- 16) Average Selling Price
select p.product_id,round(case
                        WHEN coalesce(SUM(u.units),0)=0 then 0
                        ELSE SUM(p.price * u.units)*1.0 /SUM(u.units)  
                        END                  
                        ,2) as average_price 
from Prices p left join UnitsSold u 
on p.product_id=u.product_id and
u.purchase_date between p.start_date and p.end_date 
group by p.product_id
----------------------------------------------------------------------------------
-- 17) Project Employees I
select p.product_id,round(case
                        WHEN coalesce(SUM(u.units),0)=0 then 0
                        ELSE SUM(p.price * u.units)*1.0 /SUM(u.units)  
                        END                  
                        ,2) as average_price 
from Prices p left join UnitsSold u 
on p.product_id=u.product_id and
u.purchase_date between p.start_date and p.end_date 
group by p.product_id
----------------------------------------------------------------------------------
-- 18) Percentage of Users Attended a Contest
select 
contest_id, 
round(count(distinct user_id) * 100 /(select count(user_id) from Users) ,2) as percentage
from  Register
group by contest_id
order by percentage desc,contest_id
----------------------------------------------------------------------------------
-- 19) Queries Quality and Percentage
select query_name ,round(sum(rating*1.0/position)/count(rating),2) as quality  
                  ,round(sum(case
				  when rating<3 then 1 else 0 end )*100.00
				  /count(rating),2) as poor_query_percentage 
from Queries
group by query_name 
----------------------------------------------------------------------------------
-- 20) Monthly Transactions I
select format(trans_date,'yyyy-MM') as month ,
	   country,
	   count(id) as trans_count ,
	   sum(case
	   when state='approved'  then 1 else 0
	   end)  as approved_count ,
	   sum(amount) as trans_total_amount,
	   sum(case
	   when state='approved'  then amount else 0
	   end)  as approved_total_amount 
from Transactions 
group by format(trans_date,'yyyy-MM'),country
order by format(trans_date,'yyyy-MM'),country desc
----------------------------------------------------------------------------------
-- 21) Immediate Food Delivery II
with ordered_table
as(select customer_id,min(order_date) as first_order
from Delivery
group by customer_id )

select round(
    ( count(d.customer_id)*100.00
    /(select count(distinct customer_id) from Delivery) )
    ,2) as immediate_percentage 
from Delivery d join ordered_table o 
on d.customer_id=o.customer_id 
where order_date=customer_pref_delivery_date 
and order_date=first_order
----------------------------------------------------------------------------------
-- 22) Game Play Analysis IV	
with t 
as (
	select player_id,
	min(event_date)as first_day	
	from Activity
	group by player_id
	)
select round(sum(case
	   when a.event_date is not null then 1 else 0
	   end )*1.00/(select count(distinct player_id) from Activity ),2) as fraction
from t left join Activity a 
on t.player_id=a.player_id and a.event_date=DATEADD(day,1,t.first_day)
----------------------------------------------------------------------------------
-- 23) Number of Unique Subjects Taught by Each Teacher
select teacher_id, count(distinct subject_id) as cnt
from Teacher
group by teacher_id  
----------------------------------------------------------------------------------
-- 24) User Activity for the Past 30 Days I
select activity_date as day,count(distinct user_id) as active_users 
from activity 
where (activity_date > DATEADD(day,-30,'2019-07-27') ) 
and(activity_date <= '2019-07-27') 
group by activity_date
order by activity_date
----------------------------------------------------------------------------------
-- 25) Product Sales Analysis III
WITH F_YEAR
AS (
	SELECT product_id,
	[YEAR],
	quantity,
    price,
    DENSE_RANK()over(partition by product_id order by [year]) as DN 
	FROM SALES)
SELECT product_id,[year] as first_year,quantity,price 
FROM F_YEAR 
where DN=1
----------------------------------------------------------------------------------
--26) Classes With at Least 5 Students
with table_a
as (select class,count(student) as no
	from Courses 
	group by class
	)
select class
from table_a
where no>=5
----------------------------------------------------------------------------------
--27) Find Followers Count
select user_id,count(follower_id) as followers_count
from Followers
group by user_id
----------------------------------------------------------------------------------
--28) Biggest Single Number
with tt
as(select num,count( num)as count_num 
from MyNumbers
group by num)
select max(num) as num
from tt
where count_num=1
----------------------------------------------------------------------------------
--29) Customers Who Bought All Productsfgd ssx
select customer_id 
from customer
group by customer_id
having(count(distinct product_key))=(select count(product_key ) from Product) 
----------------------------------------------------------------------------------
--30) The Number of Employees Which Report to Each Employee
with tab as
	(select reports_to,
           count(employee_id) as  reports_count ,
		   ceiling(avg(age*1.00)) as average_age
	from Employees	
	--where reports_to is not null
	group by reports_to)
select employee_id,name,reports_count,average_age
from Employees e join tab 
on e.employee_id=tab.reports_to
----------------------------------------------------------------------------------
--31) Primary Department for Each Employe
with tab as
		  (select employee_id as aa
	   	   from Employee
		   group by employee_id
		   having (count(department_id))=1)

select employee_id,department_id 
from  Employee 
where primary_flag='Y' or employee_id in (select aa from tab) 
----------------------------------------------------------------------------------
--32) Triangle Judgement
SELECT   x,y,z ,case
                when (x+y>z)and(x+z>y)and(y+z>x) 
                then 'Yes'
                else 'No'
                end as triangle
from Triangle
----------------------------------------------------------------------------------
-- 33) Consecutive Numbers
SELECT DISTINCT num AS ConsecutiveNums
FROM (
  SELECT num,
         LAG(num,1) OVER (ORDER BY id) AS prev1,
         LAG(num,2) OVER (ORDER BY id) AS prev2
  FROM logs
) t
WHERE num = prev1 AND num = prev2;
----
WITH tab AS (
    SELECT *,
           LEAD(id,2) OVER(PARTITION BY num ORDER BY id) AS lead_by2
    FROM logs
)
SELECT DISTINCT num AS ConsecutiveNums
FROM tab
WHERE lead_by2 - id = 2;
----------------------------------------------------------------------------------
-- 34) Product Price at a Given Date
with tab as(
select Product_id,max(change_date) as max_date
from Products
where change_date<='2019-08-16'
group by Product_id )

select A.product_id,new_price as price
from Products A join tab 
on A.Product_id=tab.Product_id and change_date=tab.max_date
union 
select Product_id, 10 as price
from Products
where change_date >'2019-08-16' and Product_id not in (select Product_id from tab)
----------------------------------------------------------------------------------
 -- 35) Last Person to Fit in the Bus
 with tab as(
            select *,sum(weight)over(order by turn) as sum_weight
			from Queue 
			)

select top(1) person_name
from tab 
where sum_weight<=1000
order by turn desc
----------------------------------------------------------------------------------
 -- 36) Count Salary Categories
with tab as(
         select *,case
				  when (income<20000) then 'Low Salary'
				  when (income between 20000 and 50000 ) then 'Average Salary'
				  else 'High Salary'
				  end as category
		 from Accounts),

cat as(select'Low Salary' as category
       union select 'Average Salary' 
       union select 'High Salary' )

select cat.category,count(tab.account_id)as accounts_count 
from cat left join tab 
on  cat.category=tab.category
group by cat.category    
----------------------------------------------------------------------------------
 -- 37) Employees Whose Manager Left the Company
select employee_id  
from  Employees
where(salary<30000) and manager_id not in (select employee_id from Employees)
order by employee_id
----------------------------------------------------------------------------------
 -- 38) Exchange Seats
			lead(student)over(order by id) as name_of_next,
			lag(student)over(order by id) as name_of_prev
			from seat) 
select id,case
		  when (id%2=1)and(name_of_next is not null) then(name_of_next) 
		  when (id%2=0) then(name_of_prev) 
		  else student
		  end as student 
from tab
----------------------------------------------------------------------------------
 -- 39) Movie Rating
-- 📌 In SQL Server, you cannot use ORDER BY inside a subquery that is part of a UNION
-- unless that subquery also uses TOP or OFFSET/FETCH.
-- To fix this, we wrap each subquery in an outer SELECT and give it an alias (e.g., AS top_user).
-- This makes ORDER BY valid and avoids syntax errors.
SELECT results
FROM (SELECT TOP 1 u.name AS results
FROM users u JOIN movierating m
ON u.user_id=m.user_id
GROUP BY u.user_id, u.name
ORDER BY COUNT(u.user_id) DESC, u.name ASC ) AS USER_TABLE

union ALL 

SELECT results
FROM (SELECT TOP 1 title AS results
FROM movierating mr JOIN Movies m
ON mr.movie_id = m.movie_id 
WHERE (created_at >='2020-02-01') and (created_at <'2020-03-01')
GROUP BY mr.movie_id,title
ORDER BY AVG(rating*1.00) DESC ,title ASC) AS MOVIE_TABLE;
----------------------------------------------------------------------------------
 -- 40) Restaurant Growth
WITH DailyTotals AS (
					SELECT visited_on,SUM(amount) AS daily_amount
					FROM Customer
					GROUP BY visited_on ),

TARGET_T as  (SELECT visited_on,
				   sum(daily_amount)over( order by visited_on rows between 6 preceding  and current row) as amount,
				   round(avg(daily_amount*1.00)over(order by visited_on rows between 6 preceding  and current row),2) as average_amount ,
				   count(visited_on)over(order by visited_on rows between 6 preceding  and current row) as counts
			FROM DailyTotals)
select visited_on ,amount , average_amount
from TARGET_T
where counts=7
----------------------------------------------------------------------------------
 -- 41) Friend Requests II: Who Has the Most Friends

WITH TAB_A AS(
           SELECT accepter_id,COUNT(requester_id) as num
	   	   FROM RequestAccepted 
		   GROUP BY accepter_id),

TAB_B AS  (SELECT requester_id,COUNT(accepter_id) as num 
	       FROM RequestAccepted 
		   GROUP BY requester_id),

TOTAL AS  (	SELECT accepter_id AS id , num
			from TAB_A
			union all
			SELECT requester_id AS id , num
			from TAB_B)
SELECT TOP 1 id with ties,sum(num) AS num
FROM TOTAL 
GROUP BY id 
order by num desc
----------
--Simpler Approach 
WITH all_users AS (
    SELECT requester_id AS id FROM RequestAccepted
    UNION ALL
    SELECT accepter_id AS id FROM RequestAccepted
)
SELECT TOP 1 WITH TIES id, COUNT(*) AS num
FROM all_users
GROUP BY id
ORDER BY num DESC;
----------------------------------------------------------------------------------
 -- 42) Investments in 2016

with inv_state AS(select*,
				  count(tiv_2015)over(partition by  tiv_2015) as no_similar_inv15,
				  count(lat )over(partition by  lat,lon) as  no_of_loc
				  from 
				  Insurance
				  )
select round(sum(tiv_2016),2) as tiv_2016
from inv_state
where (no_similar_inv15>1)
and (no_of_loc=1)
 ----------------------------------------------------------------------------------
 -- 43) Department Top Three Salaries

WITH TAB AS(
			SELECT *,DENSE_RANK()OVER (PARTITION BY departmentId ORDER BY salary DESC) AS DN
			FROM Employee
			)
SELECT  D.name,T.name as Employee,T.Salary 
FROM tab T JOIN Department D
ON T.departmentId=D.id
where DN<=3
  ----------------------------------------------------------------------------------
 -- 44) Fix Names in a Table

select user_id,UPPER(left(name,1))+LOWER(substring( name,2,len(name) ) )
from Users
order by user_id
  ----------------------------------------------------------------------------------
 -- 45) Patients With a Condition

with taba as
			(
			SELECT P.*,seperated_val.value as seperated_val
			FROM Patients P
			CROSS APPLY string_split(P.conditions,' ') seperated_val	
			)
SELECT distinct patient_id,patient_name,conditions
FROM taba
where CHARINDEX('DIAB1',seperated_val)=1
  ----------------------------------------------------------------------------------
 -- 46) Delete Duplicate Emails

 with tab as ( select *,ROW_NUMBER()over(partition by Email order by id ) as no 
              from person )
delete from person 
where id in (select id from tab where no>1)

  ----------------------------------------------------------------------------------
 -- 47) Second Highest Salary

select max(salary) as [SecondHighestSalary]
from(select *,dense_rank()over(order by salary desc) as orderr
     from Employee) as tab_a
where orderr=2
--> use max() to return null if there is no value 

  ----------------------------------------------------------------------------------
 -- 48) Group Sold Products By The Date

with tab as (
			 select  distinct Product ,
			 sell_date
			 from Activities)

select sell_date,count(Product) num_sold  ,STRING_AGG(Product,',') as products        
from tab
group by sell_date
order by sell_date ,num_sold desc, products
  ----------------------------------------------------------------------------------
 -- 49) List the Products Ordered in a Period

select p.product_name,sum(o.unit) as unit
from Products p join Orders o
on p.product_id=o.product_id
where ( year(o.order_date)=2020 ) and (month(o.order_date)=2)
group by p.product_name
having sum(o.unit)>=100
order by sum(o.unit) desc
  ----------------------------------------------------------------------------------
 -- 50) Find Users With Valid E-Mails
 select *
from Users
where (mail like '[a-zA-Z]%@leetcode.com')
and SUBSTRING(mail,1, CHARINDEX('@', mail) - 1) not like '%[^A-Za-z0-9_.-]%'

----------------------------------------------------------------------------------

