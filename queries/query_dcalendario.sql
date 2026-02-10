create or replace temporary table source_horizon.fdw.tmp_calendar_dimension as
with cte_my_date as
(
select trim(dateadd(day, seq4(), '2000-01-01'))::date date
from table(generator(rowcount=>36525)) -- number of days after reference date in previous line
)
select
date
,year(date) year
,month(date) month
,to_varchar(date, 'mmmm') month_name
,to_varchar(date, 'yyyy-mm') period
,to_varchar(date, 'mm-dd') dt_period
,day(date) day
,dayofweek(date) day_week
,case
    when dayofweek(date) = 0 then 'Sábado'
    when dayofweek(date) = 1 then 'Domingo'
    when dayofweek(date) = 2 then 'Segunda-feira'
    when dayofweek(date) = 3 then 'Terça-feira'
    when dayofweek(date) = 4 then 'Quarta-feira'
    when dayofweek(date) = 5 then 'Quinta-feira'
    when dayofweek(date) = 6 then 'Sexta-feira'
end week_name
,weekofyear(date) week_year
,dayofyear(date) day_of_year
,WEEKOFYEAR(date) - WEEKOFYEAR(CAST(date_trunc('MONTH',date) AS DATE))+1 week_of_month
,case
when month(date) = 11 and dayofweek(date) = 5 and max(weekofyear(date)) over (partition by year(date), month(date), dayofweek(date) order by weekofyear(date) desc) = weekofyear(date)
when month(date) = 5 and dayofweek(date) = 1 and ( WEEKOFYEAR(date) - WEEKOFYEAR(CAST(date_trunc('MONTH',date) AS DATE))+1 ) = 2 then 'Dia das mães'
else ''
end day_type
from cte_my_date;;