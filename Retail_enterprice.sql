use retail_enterprice;
go
select * from Product;
select * from Calender;
select * from Fullfilment;
select * from OrderLine;
select * from Promotion;
select * from Returns;
select * from orderheader;

select a.SeasonalityTag,
round(sum(b.linecost),2) as Total_cost,
round(sum(b.linerevenue),2) as Total_Revenue,
ROUND(sum(b.LineRevenue-b.LineCost),2) as Profit from product a join orderline b 
on a.productid=b.productid group by SeasonalityTag;

#negative_profits
select top 10
b.subcategory as Item,
round(sum(a.LineRevenue-a.linecost),2) as revenue 
from orderline a join Product b 
on a.productid=b.ProductID 
group by a.productid,b.Subcategory order by revenue;

Possitivev profits
select top 10
b.subcategory as Item,
round(sum(a.LineRevenue-a.linecost),2) as revenue 
from orderline a join Product b 
on a.productid=b.ProductID 
group by a.productid,b.Subcategory order by revenue desc;

select a.vendor,ROUND(sum(b.LineRevenue-b.LineCost),2) as Profit from product a join orderline b 
on a.productid=b.productid group by vendor order by profit;

with cte as
(select a.productid,a.vendor,
round(sum(a.msrp-a.standardcost),2) as revenue,count(b.productid*b.qty) as volume
from product a join orderline b on a.productid=b.productid
group by a.vendor,a.ProductID)
select vendor,sum(revenue*volume) as actual_revenue,sum(volume) as total_vol from cte
group by vendor order by actual_revenue desc;

with cte as
(select a.productid,a.vendor,
round(sum(a.msrp-a.standardcost),2) as revenue,count(b.productid*b.qty) as volume
from product a join orderline b on a.productid=b.productid
group by a.vendor,a.ProductID)
select vendor,sum(revenue*volume) as actual_revenue,sum(volume) as total_vol from cte
group by vendor order by actual_revenue desc;


select campaigntype,count(name) as promotions,round(sum(PlannedLift),2) AS lift,sum(plannedbudget) as budget
from promotion group by CampaignType;

select a.campaigntype,sum(a.plannedbudget) as budget,count(b.orderid) as toatal_orders,
round(sum(c.linecost),2) as Total_cost,
round(sum(c.linerevenue),2) as Total_Revenue,
ROUND(sum(c.LineRevenue-c.LineCost),2) as Profit
from promotion a join orderheader b on a.PromotionID=b.promotionid
join OrderLine c on b.orderid=c.OrderID
group by a.CampaignType;

select a.DiscountType,count(b.orderid) as toatal_orders,
round(sum(c.linecost),2) as Total_cost,
round(sum(c.linerevenue),2) as Total_Revenue,
ROUND(sum(c.LineRevenue-c.LineCost),2) as Profit
from promotion a join orderheader b on a.PromotionID=b.promotionid
join OrderLine c on b.orderid=c.OrderID
group by a.DiscountType order by Profit desc;

select targetsegment,
count(campaigntype) as campaigns,
round(sum(plannedlift),2) as lift,
sum(plannedbudget) as budget
from promotion group by targetsegment;

SELECT 
    cast(round((COUNT(DISTINCT b.OrderLineID) * 1.0 
    / COUNT(DISTINCT a.OrderLineID))*100,2) as decimal(10,2)) AS Avg_Returns
FROM orderline a
LEFT JOIN Returns b
    ON a.OrderLineID = b.OrderLineID;


select b.seasonalitytag,
cast(round(count(distinct c.orderlineId)*100.0/count(distinct a.orderlineid),2) as decimal(10,2)) as total_returns
from orderline a
JOIN product b on a.productid=b.productid
left join returns c on a.orderlineid=c.orderlineid
group by b.SeasonalityTag

select b.seasonalitytag,
round(sum(c.Refund),2) as total_refund
from orderline a
JOIN product b on a.productid=b.productid
left join returns c on a.orderlineid=c.orderlineid
where c.Disposition='write-off'
group by b.SeasonalityTag


select b.Category,
cast(round(count(distinct c.orderlineId)*100.0/count(distinct a.orderlineid),2) as decimal(10,2)) as total_returns 
from orderline a
JOIN product b on a.productid=b.productid
left join returns c on a.orderlineid=c.orderlineid
group by b.Category order by total_returns desc


select reasoncode, count(reasoncode) as Total,
round(sum(refund),2) as refund 
from Returns where Disposition='Write-off'
group by ReasonCode order by total desc

select  
count(case when b.deliverystatus='late' then 1 end) as late_deliveries,
count(distinct c.OrderLineID) as total_returns,
round(sum(c.refund),2) as total_refund
from orderline a join Fullfilment B 
on a.orderid=b.orderid 
left join returns c 
on a.orderlineid=c.orderlineid
where DeliveryStatus='late'




with cte as
(select count(disposition) as total_count,
count(case when disposition='write-off' then 1 end) as writeoffs,
count(case when disposition='resell' then 1 end) as resell
from returns)
select sum(total_count) as returns,
cast(round(sum(writeoffs*1.0/total_count)*100,2) as decimal(10,2)) as writeoff_returns,
cast(round(sum(resell*1.0/total_count)*100,2) as decimal(10,2)) as resell_returns
from cte

select count(*) as total_returns,
cast(round
(count((case when disposition='write-off' then 1 end))*100.0/count(*)
,2) as decimal(10,2)) as avg_writeoff,
cast(round(
count((case when disposition='resell' then 1 end))*100.0/count(*)
,2) as decimal(10,2)) as avg_resell
from Returns


select count(*) as total_orders,
round(sum(shipcost),2) as delivery_cost,
cast(round
(count(case when deliverystatus='ontime' then 1 end)*100.0/count(*)
,2) as decimal(10,2))as ontime_deliveries,
cast(round
(count(case when deliverystatus='late' then 1 end)*100.0/count(*)
,2)as decimal(10,2)) as late_deliveries
from Fullfilment

select carrier,
count(*) as total_orders,
count(case when deliverystatus='ontime' then 1 end) as ontime_deliveries,
count(case when deliverystatus='late' then 1 end) as late_deliveries,
round(sum(shipcost),2) as total_cost,
round(avg(shipcost),2) as avg_cost
from Fullfilment
group by carrier order by total_orders

select
b.carrier,
count(case when b.deliverystatus='late' then 1 end) as late_deliveries,
count(case when c.ReasonCode='late delivery' then 1 end) as total_returns,
round(sum(c.refund),2) as total_refund
from orderline a join fullfilment b 
on a.orderid=b.orderid 
left join returns c
on a.orderlineid=c.orderlineid
group by b.Carrier order by total_refund desc;







