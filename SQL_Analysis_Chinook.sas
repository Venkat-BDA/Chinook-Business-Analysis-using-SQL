libname chinook "C:\Users\vjayanarasimhan\OneDrive - IESEG\Venkat_Jayanarasimhan\MSc Big Data Analytics For Business
\1.Semester\5.Business Reporting Tools\Session 2_SQL\Assignment_2\Chinook Dataset";

/*** Venkat JAYANARASIMHAN - Individual Assignment Business Reporting Tools - CHINOOK COMPANY ***/

/*** Complete Overview Of the CHINOOK Company ***/

/*** A. FINANCIAL ASPECTS ***/

/* 1a. What about company sales (and the evolution over the years, or eg. per month)?
	  Make sure to accuratley sort your results */

PROC SQL;

title "Company Sales - Evolution Over the Years";
SELECT  year(datepart(InvoiceDate)) as Year, sum(Total) as Sales /*Selecting the Year, Month & Total Sales*/
FROM CHINOOK.INVOICES /*From Invoices Table*/
GROUP BY 1 /*Group by Year*/
ORDER BY 1 ASC; /*Sort by Year*/

QUIT;

/* 1b. What about company sales (and the evolution over the years, or eg. per month)?
	  Make sure to accuratley sort your results */

PROC SQL;

title "Company Sales - Evolution Over the Years (Month-wise Split-Up)";
SELECT  year(datepart(InvoiceDate)) as Year, month(datepart(InvoiceDate)) as Month, sum(Total) as Sales /*Selecting the Year, Month & Total Sales*/
FROM CHINOOK.INVOICES /*From Invoices Table*/
GROUP BY 1,2 /*Group by Year & Month*/
ORDER BY 1,2 ASC; /*Sort by Year & Month*/

QUIT;

/* 2. How many purchases are made per Invoice */

PROC SQL;

title "Purchases Made Per Invoice";
SELECT InvoiceId, sum(Quantity) as Total_Purchases /*Selecting InvoiceId & Sum of Quantity*/
FROM CHINOOK.INVOICE_ITEMS /*From Invoice Items Table*/
GROUP BY 1
ORDER BY 1;

QUIT;

/* 3. How many Invoices were there in 2009 and 2011? What are the respective total sales for each of those years? */

PROC SQL;

title "Invoice & Total Sales For The Year 2019 & 2011";
SELECT DISTINCT year(datepart(InvoiceDate)) as Year, count(InvoiceId) as No_Of_Invoice, sum(Total) as Total_Sales
FROM CHINOOK.invoices
WHERE year(datepart(InvoiceDate)) = 2009 /*Selecting the year 2009*/

UNION /*Using Union Set Operator to combine the query*/

SELECT DISTINCT year(datepart(InvoiceDate)) as Year, count(InvoiceId) as No_Of_Invoice, sum(Total) as Total_Sales
FROM CHINOOK.invoices
WHERE year(datepart(InvoiceDate)) = 2011; /*Selecting the year 2011*/

QUIT;

/* 4. Company Key Metrics Overview */

PROC SQL;
title "Company Key Metrics Overview";
SELECT Count(Distinct(a.InvoiceId)) as Number_of_Invoices, Count(Distinct(a.CustomerId)) as Number_of_Customers,
Count(Distinct(b.TrackId)) as Number_Of_Tracks, Sum(b.Quantity) as Total_Quantity, Sum(a.Total) as Total_Sales, count(DISTINCT a.BillingCountry) as Countries
From chinook.invoices as a, chinook.invoice_items as b
WHERE a.invoiceID = b.invoiceID; 
QUIT;

/*** B. CUSTOMER ASPECTS ***/

/* 5. How many customers do we have? Are they company clients or not? */

PROC SQL;

title "Total Customers in Chinook";
SELECT count(CustomerId) as No_Of_Customers	 /*Counting Clients*/  
FROM CHINOOK.CUSTOMERS; /*From Customers Tables*/

QUIT;

PROC SQL;

title "Customers Classification";
SELECT case when Company NOT LIKE "NA%" then "Company Clients"
	   else "Not Company Clients" end as Company_Clients_Status, /*Creating new column based on Company Cleints*/
	   count(CustomerId) as No_Of_Customers	 /*Counting Clients*/  
FROM CHINOOK.CUSTOMERS /*From Customers Tables*/
GROUP BY 1; /*Group by Clients*/

QUIT;

/* 6. a)How long has it been since the last purchase (Recency)
	  b)How much does the customer spend on average (Monetary Value) */

PROC SQL;

title "Last Purchase & Monetary Values Summary";
SELECT round(yrdif(datepart(max(i.InvoiceDate)),today())) as Since_Last_Purchase_In_Years,
	   sum(i.Total) as Total_Spending, avg(i.Total) as Average_Spending
FROM CHINOOK.invoices as i;
QUIT;

/* 6 c)How many purchases has the customer done (Frequency) */

PROC SQL;

title "Purchase Summary";
SELECT sum(it.Quantity) as Total_Purchases, avg(it.Quantity) as Average_Purchases
FROM CHINOOK.invoice_items as it;

QUIT;


/* 7. Give insight into the tenure of customers (How long are they already with the company) */

PROC SQL;

title "Tenure Of Customers";
SELECT round(yrdif(datepart(min(InvoiceDate)),today())) as Tenure_Of_Customers /*Comparing the first invoice date with Today*/
FROM CHINOOK.INVOICES; /*From Invoices table*/

QUIT;

/* 8. Where are our customers located and what is our biggest market (Sales per market)?
	  Note that a market may also be US/Europe/Asia */

PROC SQL;

title "Customers Location";
SELECT DISTINCT Country /*Selecting distinct countires of customers*/
FROM CHINOOK.CUSTOMERS; /*From Customers table*/

QUIT;

PROC SQL;

title "Biggest Market";
SELECT case a.Country
	   when "USA" then "North America"
	   when "Canada" then "North America"
	   when "India" then "Asia"
	   when "Argentina" then "South America"
	   when "Brazil" then "South America"
	   when "Chile" then "South America"
	   when "Australia" then "Oceania"
	   when "United Kingdom" then "UK"
	   else "Europe" end as Market_Name, /*Creating new column for the Market Category*/
	   sum(i.Total) as Sales /*Calculating the total sales*/
FROM CHINOOK.CUSTOMERS as a, CHINOOK.invoices as i /*From Customers & Invoices tables*/
WHERE a.CustomerId = i.CustomerId /*Inner Join based on CustomerID*/
GROUP BY 1 /*Group by Country*/
ORDER BY 2 DESC; /*Order by Sales*/

QUIT;

/* 9. Which are the countires accounting for the main part of the customers as well as revenue? */

PROC SQL;

title "Major Countries In Terms Of Customer Base & Revenue"; 
SELECT c.Country, count(DISTINCT c.CustomerId) as No_Of_Customers, sum(i.Total) as Total_Revenue, avg(i.Total) as Average_Revenue
FROM CHINOOK.Customers as c,CHINOOK.INVOICES as i
WHERE c.CustomerId = i.CustomerId /*Inner join CustomerID*/
GROUP BY 1 /*Group by Country*/
ORDER BY 2 DESC,3 DESC; /*Order by Customers & Total*/

QUIT;

/* 10. Give the Invoices Per Country */

PROC SQL;

title "Major Countries In Terms Of Invoices";
SELECT c.Country, count(i.InvoiceId) as No_Of_Invoices
FROM CHINOOK.Customers as c,CHINOOK.INVOICES as i
WHERE c.CustomerId = i.CustomerId /*Inner join CustomerID*/
GROUP BY 1 /*Group by Country*/
ORDER BY 2 DESC; /*Order by Invoices*/

QUIT;


/*** C. INTERNAL BUSINESS PROCESSES ***/

/* 11. Give insight into the genres, tracks and media types that are bought most/least.
	  What are the conclusions? You can also create a group of low, average and good performing groups */

PROC SQL;

/*Genres*/

title "Genres Summary";
SELECT case when Total_Purchases1 <= 20 then "Genres - Low Performing Group"
	   when Total_Purchases1 <= 80 then "Genres - Avg. Performing Group"
	   else "Genres - Good Performing Group" end as Products_Classification, /*Creating new column for Groups*/
	   g.Name, sum(it.Quantity) as Total_Purchases	
FROM (SELECT g.Name, sum(it.Quantity) as Total_Purchases, sum(it.Quantity) as Total_Purchases1
	  FROM CHINOOK.invoice_items as it, CHINOOK.GENRES as g, CHINOOK.TRACKS as t
	  WHERE g.GenreId = t.GenreId and
	  		t.TrackId = it.TrackId /*Inner join GenreId & TrackId*/
	  GROUP BY 1)
GROUP BY 2
ORDER BY 3 DESC;

QUIT;

PROC SQL;

/*Media Types*/

title "Media Types Summary";
SELECT case when Total_Purchases1 <= 100 then "Media - Low Performing Group"
	   when Total_Purchases1 <= 200 then "Media - Avg. Performing Group"
	   else "Media - Good Performing Group" end as Products_Classification, /*Creating new column for Groups*/
       m.Name, sum(it.Quantity) as Total_Purchases
FROM (SELECT m.Name, sum(it.Quantity) as Total_Purchases, sum(it.Quantity) as Total_Purchases1
	  FROM CHINOOK.invoice_items as it, CHINOOK.media_types as m, CHINOOK.TRACKS as t
	  WHERE m.MediaTypeId = t.MediaTypeId and
	  		t.TrackId = it.TrackId /*Inner join MediaTypeId & TrackId*/
	  GROUP BY 1)
GROUP BY 2
ORDER BY 3 DESC;
QUIT;

PROC SQL;

/*Tracks*/

title "Tracks Summary";
SELECT case when Total_Purchases1 <= 2 then "Tracks - Low Performing Group"
	   when Total_Purchases1 <= 4 then "Tracks - Avg. Performing Group"
	   else "Tracks - Good Performing Group" end as Products_Classification, /*Creating new column for Groups*/
       t.Name, sum(it.Quantity) as Total_Purchases	
FROM (SELECT t.Name, sum(it.Quantity) as Total_Purchases, sum(it.Quantity) as Total_Purchases1
	  FROM CHINOOK.invoice_items as it, CHINOOK.TRACKS as t
	  WHERE t.TrackId = it.TrackId /*Inner join InvoiceId & TrackId*/
	  GROUP BY 1)
GROUP BY 2
ORDER BY 3 DESC;
QUIT;

/* 12. a) Can we delete tracks that do not sell well?
       b) Are there tracks that have no sales?
	   c) Are there any characteristics related to these tracks?
	   d) How many bytes to we save by deleting them? */

PROC SQL;

title "Tracks - Poor Sales";
SELECT t.Name as Track_Name, p.Name as Playlist_Name , m.Name as Media_Type, t.Bytes as Bytes, sum(i.Total) as Sales
FROM CHINOOK.tracks as t, CHINOOK.INVOICES as i, CHINOOK.invoice_items as it, CHINOOK.PLAYLISTS as p,
	 CHINOOK.playlist_track as pt, CHINOOK.MEDIA_TYPES as m
WHERE t.TrackId = it.TrackId and
	  it.InvoiceId = i.InvoiceId and
	  p.PlayListId = pt.PlayListId and
	  pt.TrackId = t.TrackId and
	  t.MediaTypeId = m.MediaTypeId /*Inner join all the required tables*/
GROUP BY 1,2,3,4
HAVING Sales < 1;

QUIT;

/* 13. Show the TOP 3 Best Selling Artists */

PROC SQL Outobs=3; /*Taking the top 3 values*/

title "Top 3 Best Selling Artists";
SELECT ar.Name as Artist_Name, sum(Total) as Total_Sales
FROM CHINOOK.Artists as ar, CHINOOK.albums as a, CHINOOK.tracks as t, CHINOOK.INVOICE_ITEMS as it,
	 CHINOOK.invoices as i
WHERE ar.ArtistId = a.ArtistId and
	  a.AlbumId = t.AlbumId and
	  t.TrackId = it.TrackId and
	  it.InvoiceId = i.InvoiceId /*Inner join all the required tables*/
GROUP BY 1
ORDER BY 2 DESC;

QUIT;

/* 14. Give Top 3 most loyal customers of our company*/

PROC SQL outobs=3;

title "Most Loyal Customers";
SELECT unique(a.CustomerID), b.FirstName, b.LastName, Max(a.InvoiceDate) as Most_Recent_Order format = DATETIME7. ,
       Min(a.InvoiceDate) as First_Order format = datetime7.,
       int((Max(Datepart(a.InvoiceDate)) - Min(Datepart(a.InvoiceDate))))/365.25 as Tenure,
       Mean(a.Total) as Average_Sales /*Selecting & Converting desired values*/
FROM chinook.invoices as a inner join chinook.customers as b on a.customerID = b.customerID
GROUP BY a.CustomerID
ORDER BY Tenure DESC;
QUIT;

/*** D. EMPLOYESS ASPECTS ***/

/* 15. How many employees do we have?
	   How many are about to retire (>60)
	   How long are they in the company? */

PROC SQL;

title "Employees Details & Retirement Status";
SELECT EmployeeId, FirstName, LastName, count(EmployeeId) as Total_Employees,
	   count(EmployeeId) as Retirement_Employees, round(yrdif( datepart(hiredate), today())) as Working_Years
FROM CHINOOK.employees
WHERE round(yrdif(datepart(birthdate),today())) > 60; /*Selecting age more than 60*/

QUIT;

/* 16. How many different roles do we have? */

PROC SQL;

title "Different Roles in CHINOOK";
SELECT count(DISTINCT Title) as No_Of_Roles
FROM CHINOOK.EMPLOYEES;

QUIT;

/* 17. How many sales does each sales person have?
	   How many sales does each of the supervisors have?
	   What areas do they serve? */

PROC SQL;

title "Sales Details - Sales Agent & Manager";
SELECT e.EmployeeId, e.FirstName, e.LastName, count(it.Quantity) as Sales_Quantity
FROM CHINOOK.EMPLOYEES as e, CHINOOK.customers as c, CHINOOK.INVOICES as i, CHINOOK.INVOICE_ITEMS as it
WHERE e.EmployeeId = c.SupportRepId and
	  c.CustomerId = i.CustomerId and
	  i.InvoiceId = it.InvoiceId and
	  lowcase(e.Title) LIKE ("sales support%") /*Selecting Sales Agents*/
GROUP BY 1,2,3

UNION ALL

SELECT d.employeeId, d.firstname, d.lastname, count(a.Quantity) as Sales_Quantity 
FROM CHINOOK.invoice_items as a, chinook.invoices as i, chinook.customers as b, chinook.employees as c,
	 chinook.employees as d /* Link the supervisors with the employees */
WHERE a.invoiceid = i.invoiceid and
 	  i.customerid = b.customerid and
	  b.supportRepId = c.employeeID and 
	  INPUT(c.ReportsTo, 2.) = d.employeeId /* Merging Employees data with Supervisors */
GROUP BY d.employeeId, d.firstname, d.lastname;
QUIT;

PROC SQL;

title "Areas Served by Sales Agents";
SELECT DISTINCT c.Country, c.City 
FROM CHINOOK.EMPLOYEES as e, CHINOOK.CUSTOMERS as c
WHERE e.EmployeeId = c.SupportRepId /*Inner join EmployeeId & SupportRepId*/
GROUP BY 1;

QUIT;

/* 18. What is the overall sales contrinution by each sales agent?
	   Who brought in most money to the company?
	   Does experience plays a role in bringing more money to the company? */

PROC SQL;

title "Overall Sales Contribution - Sales Agent Wise";
SELECT e.EmployeeId, e.FirstName, e.LastName, year(datepart(hiredate)) as Hiring_Year, /*Hiring Year*/
	   sum(i.Total) as Total_Contribution
FROM CHINOOK.EMPLOYEES as e, CHINOOK.CUSTOMERS as c, CHINOOK.INVOICES as i
WHERE e.EmployeeId = c.SupportRepId and
	  c.CustomerId = i.CustomerId /*Inner join CustomerId & EmployeeID*/
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

QUIT;

/* 19. Show Yearly Sales Contribution by each Sales Agent? */

PROC SQL;

title "Employee Performance Over the Years";
SELECT year(datepart(invoicedate)) as Year, e.EmployeeId, e.FirstName, e.LastName,
	   sum(i.Total) as Total_Contribution /*Selecting year from Invoice Date*/
FROM CHINOOK.EMPLOYEES as e, CHINOOK.CUSTOMERS as c, CHINOOK.INVOICES as i
WHERE e.EmployeeId = c.SupportRepId and
	  c.CustomerId = i.CustomerId /*Inner join CustomerId & EmployeeID*/
GROUP BY 1,2,3,4
ORDER BY 1 ASC, 5 DESC;

QUIT;

/* 20. Employee Performance in Different Countries */
 
PROC SQL;

title "Employee Performance - Country Wise Analysis";
SELECT DISTINCT e.EmployeeId, e.FirstName, e.LastName,i.BillingCountry, sum(i.Total) as Total_Sales
FROM CHINOOK.EMPLOYEES as e, CHINOOK.CUSTOMERS as c, CHINOOK.INVOICES as i /*Selecting Billing Country*/
WHERE e.EmployeeId = c.SupportRepId and
	  c.CustomerId = i.CustomerId /*Inner join CustomerId & EmployeeID*/
GROUP BY 1,2,3,4
ORDER BY 1 ASC, 5 DESC;

QUIT;