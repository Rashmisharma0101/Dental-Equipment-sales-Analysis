-- DATA VALIDATION
-- Are there NULL VALUES

select count(*) filter (where clinic_id is null) as null_clinic,
count(*) filter (where product_id is null) as null_product,
count(*) filter (where order_date is null) as null_order_date
from orders

-- Are there duplicate orders
select order_id, count(*) from orders
group by order_id
having count(*) > 1

-- 3 duplicate orders

-- Invalid cost FORMAT
select * from products
where cost_price !~ '^[0-9]+$';

-- Invalid date formats
select * from orders
where order_date !~ '^/d{4}/d{2}/d{2}$';

-- Check Logical errors

select * from orders
where quantity < 0 or delivery_time < 0;

select * from orders 
where order_date > '31/12/2025';

------------------------------------------------------------------------
drop table orders_cleaned;
create table orders_cleaned as
select * from orders;


select * from orders_cleaned;

-- Negative quantity - convert to 0
update orders_cleaned
set quantity = 0
where quantity  < 0

-- Category Value check
update orders_cleaned
set category = lower(category)


-- Remove Duplicate orders 

with cte1 as (select ctid, order_id, row_number() over (partition by order_id order by order_id) as rn  from orders_cleaned)
delete from orders_cleaned where ctid in (select ctid from cte1 where rn> 1)

select order_id, count(*) from orders_cleaned
group by order_id
having count(*) > 1

-- Clean Date format
alter table orders_cleaned add column order_date_clean date;


update orders_cleaned
set order_date = replace(order_date, '/', '-')
where order_date like '%/%'

select * from orders_cleaned

update orders_cleaned
set order_date =  to_date(order_date, 'MM-DD-YYYY')
where order_date ~ '^\d{1,2}-\d{1,2}-\d{4}$';



















