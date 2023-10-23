
--Inspecting the data 

SELECT * 
FROM [SALES PROJECT].[dbo].[sales_data_sample]

--Checking unique values

select distinct status from [SALES PROJECT].[dbo].[sales_data_sample] -- plottable on Tableau
select distinct year_id from [SALES PROJECT].[dbo].[sales_data_sample]
select distinct PRODUCTLINE from [SALES PROJECT].[dbo].[sales_data_sample]-- plottable
select distinct COUNTRY from [SALES PROJECT].[dbo].[sales_data_sample] --plottable
select distinct DEALSIZE from [SALES PROJECT].[dbo].[sales_data_sample] --plottable
select distinct TERRITORY from [SALES PROJECT].[dbo].[sales_data_sample] -- plottable



--ANALYSIS

--Grouping sales by Productline
select PRODUCTLINE, SUM(sales) Revenue
from [SALES PROJECT].[dbo].[sales_data_sample]
GROUP BY PRODUCTLINE
ORDER BY 2 DESC

--Grouping sales by Year
select YEAR_ID, SUM(sales) Revenue
from [SALES PROJECT].[dbo].[sales_data_sample]
GROUP BY YEAR_ID
ORDER BY 2 DESC

--To find how many months they operated that year (2005) since it was the month with the least sales 
select distinct MONTH_ID from [SALES PROJECT].[dbo].[sales_data_sample]
where YEAR_ID = 2005

--To find operation months across board(years)

--2004
select distinct MONTH_ID from [SALES PROJECT].[dbo].[sales_data_sample]
where YEAR_ID = 2004
--They worked all year long...12 months

--2003 
select distinct MONTH_ID from [SALES PROJECT].[dbo].[sales_data_sample]
where YEAR_ID = 2003
--They worked all year long

--They had a full year operation for two years(2003 and 2004) and 5 months in 2005

--Grouping sales by DealSize
select DEALSIZE, SUM(sales) Revenue
from [SALES PROJECT].[dbo].[sales_data_sample]
GROUP BY DEALSIZE
ORDER BY 2 DESC

-- We see that the Medium size had the highest sales among the deal sizes


--What was the best month for sales in a specific year? How much was earned that month

--2003
select MONTH_ID, SUM(sales) Revenue, COUNT(ORDERNUMBER) Frequency
from [SALES PROJECT].[dbo].[sales_data_sample]
where YEAR_ID = 2003
GROUP BY MONTH_ID
ORDER BY 2 DESC

--November was the best month in 2003 with $1029837.7 and 296 orders 

--2004
select MONTH_ID, SUM(sales) Revenue, COUNT(ORDERNUMBER) Frequency
from [SALES PROJECT].[dbo].[sales_data_sample]
where YEAR_ID = 2004
GROUP BY MONTH_ID
ORDER BY 2 DESC

--November was the best month in 2004 as well with $1089048 and 301 orders

--2005
select MONTH_ID, SUM(sales) Revenue, COUNT(ORDERNUMBER) Frequency
from [SALES PROJECT].[dbo].[sales_data_sample]
where YEAR_ID = 2005
GROUP BY MONTH_ID
ORDER BY 2 DESC

--November seems to be the month, what product did they sell most of in November 
select MONTH_ID, PRODUCTLINE, SUM(sales) Revenue, COUNT(ORDERNUMBER) Frequency
from [SALES PROJECT].[dbo].[sales_data_sample]
where YEAR_ID = 2003 AND MONTH_ID=11
GROUP BY MONTH_ID, PRODUCTLINE
ORDER BY 3 DESC

--They sold Classic Cars the most in November

--RFM ANALYSIS 
-- WHO IS OUR BEST CUSTOMER?

DROP TABLE IF EXISTS #rfm
;with rfm as
(
	select
		CUSTOMERNAME,
		SUM(sales) Monetary_Value,
		AVG(sales) Avg_Monetary_Value,
		COUNT(ORDERNUMBER) Frequency,
		MAX(ORDERDATE) Last_Order_Date,
		(select MAX(ORDERDATE) from [SALES PROJECT].[dbo].[sales_data_sample]) Max_Order_Date,
		DATEDIFF(DD, MAX(ORDERDATE), (select MAX(ORDERDATE) from [SALES PROJECT].[dbo].[sales_data_sample])) Recency

	FROM [SALES PROJECT].dbo.sales_data_sample
	GROUP BY CUSTOMERNAME
),
rfm_calc as
(

	select r.*,
		NTILE(4) OVER (ORDER BY Recency desc) rfm_Recency,
		NTILE(4) OVER (ORDER BY Frequency) rfm_Frequency,
		NTILE(4) OVER (ORDER BY Monetary_Value) rfm_Monetary
	from rfm r
)
select 
	C.*, rfm_Recency + rfm_Frequency + rfm_Monetary as rfm_cell,
	CAST(rfm_Recency as varchar) + CAST(rfm_Frequency as varchar) + CAST(rfm_Monetary as varchar)rfm_cell_string
into #rfm
from rfm_calc C

--testing...
select CUSTOMERNAME, rfm_Recency, rfm_Frequency, rfm_Monetary,
	case
		when rfm_cell_string in (111,112,121,122,123,132,211,212,114,141) then 'Lost customers'
		when rfm_cell_string in (133,134,143,244,334,343,344,144) then 'Slipping away, cannot lose' --Big spenders who haven't purchased in a while 
		when rfm_cell_string in (311,411,331) then 'New Customers'
		when rfm_cell_string in (222,223,233,322) then 'Potential Churners'
		when rfm_cell_string in (323,333,321,422,332,432) then 'active' --Customers who buy often and recently
		when rfm_cell_string in (433,434,443,444) then 'loyal'
	end rfm_segment

from #rfm

--What products are most often sold together
--select * from [SALES PROJECT].[dbo].[sales_data_sample] where ORDERNUMBER = 10411

select distinct OrderNumber, STUFF(

	(select ',' + PRODUCTCODE
	from [SALES PROJECT].[dbo].[sales_data_sample] p
	where ORDERNUMBER IN 
		(


			select ORDERNUMBER
			from(
				select ORDERNUMBER, COUNT(*) rn
				from [SALES PROJECT].[dbo].[sales_data_sample]
				where STATUS = 'Shipped'
				group by ORDERNUMBER
			)m
			where rn = 3
		)
		and p.ORDERNUMBER = s.ORDERNUMBER
		for xml path ('')), 
		1,1, '') ProductCodes

from [SALES PROJECT].dbo.sales_data_sample s
order by 2 desc


