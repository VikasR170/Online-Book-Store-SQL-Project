--CREATE DATABASE

CREATE DATABASE Online_BookS_Store;

--CREATE BOOKS TABLES 

CREATE TABLE Books (
    Book_ID INT PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price DECIMAL(10,2),
    Stock INT
);

CREATE TABLE Customers (
    Customer_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(100),
    City VARCHAR(100),
    Country VARCHAR(100)
);

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Customer_ID INT FOREIGN KEY REFERENCES Customers(Customer_ID),
    Book_ID INT FOREIGN KEY REFERENCES Books(Book_ID),
    Order_Date DATE,
    Quantity INT,
    Total_Amount DECIMAL(10,2)
);
SELECT*FROM BOOKS;
SELECT*FROM Customers;
SELECT*FROM Orders;

-- Books
BULK INSERT Books
FROM 'C:\Users\VIKAS RAJBHAR\Desktop\ONLINE STORE CSV\Books.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);

-- Customers
BULK INSERT Customers
FROM 'C:\Users\VIKAS RAJBHAR\Desktop\ONLINE STORE CSV\Customers.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);

-- Orders
BULK INSERT Orders
FROM 'C:\Users\VIKAS RAJBHAR\Desktop\ONLINE STORE CSV\Orders.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);

--  BASIC QUERIES


-- 1) Retrieve all books in the "Fiction" genre
SELECT*
FROM Books
WHERE Genre ='Fiction'

-- 2) Find books published after the year 1950
SELECT*
FROM Books
WHERE Published_Year > 1950;

-- 3) List all customers from Canada
SELECT *
FROM Customers
WHERE Country LIKE '%Canada%';

-- 4) Show orders placed in November 2023
SELECT*
FROM Orders
WHERE Order_Date >= '2023-11-01'
  AND Order_Date < '2023-12-01';
  
-- 5) Retrieve the total stock of books available
SELECT SUM(Stock) AS Total_stocks
FROM BOOKS;

-- 6) Find the details of the most expensive book
SELECT TOP 1 Title, Author,Genre, Published_Year, Price
FROM BOOKS
ORDER BY Price DESC;

-- USING  A SUBQUERY
SELECT Title, Author, Published_Year, Price
FROM BOOKS
WHERE Price = (SELECT MAX(Price) FROM BOOKS);


-- 7) Show all customers who ordered more than 1 quantity of a book

SELECT*
FROM Orders
WHERE Quantity > 1;

-- 8) Retrieve all orders where the total amount exceeds $20
SELECT*
FROM Orders
WHERE Total_Amount>20;

-- 9) List all genres available in the Books table
SELECT DISTINCT Genre
FROM BOOKS;

-- 10) Find the book with the lowest stock
SELECT TOP 1 Title, Author, Published_Year, Stock
FROM BOOKS
ORDER BY Stock ASC;

-- 11) Calculate the total revenue generated from all orders
SELECT SUM(Total_Amount) AS Total_Revenue
FROM Orders;





-- ADVANCED QUERIES


-- 1) Retrieve the total number of books sold for each genre
SELECT b.Genre, SUM(o.Quantity) AS Total_Sold
FROM Orders o 
JOIN BOOKS b 
    ON b.Book_ID = o.Book_ID
GROUP BY b.Genre;

-- 2) Find the average price of books in the "Fantasy" genre
SELECT AVG(Price) AS Average_price
FROM BOOKS 
WHERE Genre='Fantasy';

-- 3) List customers who have placed at least 2 orders
SELECT o.Customer_ID, c.Name, COUNT(o.Order_ID) AS Order_Count
FROM Orders AS o
JOIN Customers AS c 
    ON o.Customer_ID = c.Customer_ID
GROUP BY o.Customer_ID, c.Name
HAVING COUNT(o.Order_ID) >= 2;

-- 4) Find the most frequently ordered book
SELECT TOP 1 b.Title, b.Author, SUM(oi.Quantity) AS Total_Ordered
FROM BOOKS AS b
JOIN Orders AS oi 
    ON b.Book_ID = oi.Book_ID
GROUP BY b.Title, b.Author
ORDER BY Total_Ordered DESC;

-- 5) Show the top 3 most expensive books of Fantasy genre
SELECT TOP 3 Title, Author, Published_Year, Price
FROM BOOKS
WHERE Genre = 'Fantasy'
ORDER BY Price DESC;

-- 6) Retrieve the total quantity of books sold by each author
SELECT b.Author,SUM(o.Quantity) AS Total_books_sold
FROM Orders o
JOIN BOOKS b ON o.Book_ID=b.Book_ID
GROUP BY b.Author 
ORDER BY Total_books_sold DESC;

-- 7) List the cities where customers who spent over $30 are located
SELECT DISTINCT c.City,Total_Amount
FROM Orders o
JOIN Customers c ON o.Customer_ID=c.Customer_ID
WHERE o.Total_Amount>30
ORDER BY Total_Amount DESC;


-- 8) Find the customer who spent the most on orders
SELECT TOP 1 c.Customer_ID,c.NAME,SUM(o.Total_Amount) AS Total_Spent
FROM Orders o
JOIN Customers c ON o.Customer_ID=c.Customer_ID
GROUP BY c.Customer_ID,c.Name
ORDER BY Total_Spent DESC;


-- 9) Calculate the stock remaining after fulfilling all orders
SELECT b.Book_ID, b.Title, b.Author, 
       b.Stock - COALESCE(SUM(o.Quantity), 0) AS Remaining_Stock
FROM BOOKS AS b
LEFT JOIN Orders AS o 
    ON b.Book_ID = o.Book_ID
GROUP BY b.Book_ID, b.Title, b.Author, b.Stock;


-- ===========================================================
--                 SQL INTERVIEW QUESTIONS 
-- ===========================================================

-- 1. Find all books that have never been ordered.

SELECT b.Book_ID,
       b.Title,
       b.Author
FROM Books b
LEFT JOIN Orders o
ON b.Book_ID = o.Book_ID
WHERE o.Book_ID IS NULL;

-- 2. Find all customers who have never placed an order.

SELECT c.Customer_ID,
       c.Name,
       c.Email
FROM Customers c
LEFT JOIN Orders o
ON c.Customer_ID = o.Customer_ID
WHERE o.Customer_ID IS NULL;


-- 3. Find books whose price is greater than the average price  of all books.

SELECT *
FROM Books
WHERE Price >
(
    SELECT AVG(Price)
    FROM Books
);


-- 4. Display the second most expensive book.

SELECT TOP 1 *
FROM Books
WHERE Price <
(
    SELECT MAX(Price)
    FROM Books
)
ORDER BY Price DESC;

-- 5. Find customers who purchased books from more than one genre.

SELECT
       c.Customer_ID,
       c.Name,
       COUNT(DISTINCT b.Genre) AS Total_Genres
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
JOIN Books b
ON o.Book_ID = b.Book_ID
GROUP BY c.Customer_ID,
         c.Name
HAVING COUNT(DISTINCT b.Genre) > 1;

-- 6. Find the top 3 customers based on total spending.

SELECT TOP 3
       c.Customer_ID,
       c.Name,
       SUM(o.Total_Amount) AS Total_Spent
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID,
         c.Name
ORDER BY Total_Spent DESC;


-- 7. Find the average quantity ordered for each book.

SELECT
       b.Book_ID,
       b.Title,
       AVG(CAST(o.Quantity AS DECIMAL(10,2))) AS Average_Quantity
FROM Books b
JOIN Orders o
ON b.Book_ID = o.Book_ID
GROUP BY
       b.Book_ID,
       b.Title;


-- 8. Find customers who ordered more books (total quantity)  than the average customer.

SELECT
       c.Customer_ID,
       c.Name,
       SUM(o.Quantity) AS Total_Quantity
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY
       c.Customer_ID,
       c.Name
HAVING SUM(o.Quantity) >
(
      SELECT AVG(CustomerQty)
      FROM
      (
            SELECT SUM(Quantity) AS CustomerQty
            FROM Orders
            GROUP BY Customer_ID
      ) AvgTable
);


-- 9. Find the authors whose books have never been sold.

SELECT DISTINCT
       b.Author
FROM Books b
LEFT JOIN Orders o
ON b.Book_ID = o.Book_ID
WHERE o.Book_ID IS NULL;

-- 10. Find the percentage contribution of each genre to the total revenue.

SELECT
       b.Genre,
       SUM(o.Total_Amount) AS Revenue,
       ROUND(
             SUM(o.Total_Amount) * 100.0 /
             (SELECT SUM(Total_Amount) FROM Orders),
             2
       ) AS Revenue_Percentage
FROM Books b
JOIN Orders o
ON b.Book_ID = o.Book_ID
GROUP BY b.Genre
ORDER BY Revenue_Percentage DESC;


-- 11. Find books whose stock is below the average stock of all books.

SELECT Book_ID,
       Title,
       Author,
       Stock
FROM Books
WHERE Stock <
(
    SELECT AVG(Stock)
    FROM Books
);


-- 12. Find the customer who placed the highest number of orders.

SELECT TOP 1
       c.Customer_ID,
       c.Name,
       COUNT(o.Order_ID) AS Total_Orders
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY
       c.Customer_ID,
       c.Name
ORDER BY Total_Orders DESC;

-- 13. Find the book that generated the highest total revenue.

SELECT TOP 1
       b.Book_ID,
       b.Title,
       SUM(o.Total_Amount) AS Total_Revenue
FROM Books b
JOIN Orders o
ON b.Book_ID = o.Book_ID
GROUP BY
       b.Book_ID,
       b.Title
ORDER BY Total_Revenue DESC;

-- 14. Display the total revenue generated by each customer.

SELECT
       c.Customer_ID,
       c.Name,
       SUM(o.Total_Amount) AS Total_Revenue
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY
       c.Customer_ID,
       c.Name
ORDER BY Total_Revenue DESC;

-- 15. Find the genre with the highest number of books sold.

SELECT TOP 1
       b.Genre,
       SUM(o.Quantity) AS Total_Books_Sold
FROM Books b
JOIN Orders o
ON b.Book_ID = o.Book_ID
GROUP BY b.Genre
ORDER BY Total_Books_Sold DESC;

-- 16. Find books that were ordered more than 5 times in total.

SELECT
       b.Book_ID,
       b.Title,
       SUM(o.Quantity) AS Total_Orders
FROM Books b
JOIN Orders o
ON b.Book_ID = o.Book_ID
GROUP BY
       b.Book_ID,
       b.Title
HAVING SUM(o.Quantity) > 5
ORDER BY Total_Orders DESC;

-- 17. Find customers who purchased more than 3 different books.

SELECT
       c.Customer_ID,
       c.Name,
       COUNT(DISTINCT o.Book_ID) AS Different_Books
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY
       c.Customer_ID,
       c.Name
HAVING COUNT(DISTINCT o.Book_ID) > 3;

-- 18. Display the top 5 bestselling books based on quantity sold.

SELECT TOP 5
       b.Book_ID,
       b.Title,
       SUM(o.Quantity) AS Total_Sold
FROM Books b
JOIN Orders o
ON b.Book_ID = o.Book_ID
GROUP BY
       b.Book_ID,
       b.Title
ORDER BY Total_Sold DESC;


-- 19. Find the total number of unique books ordered by each customer.

SELECT
       c.Customer_ID,
       c.Name,
       COUNT(DISTINCT o.Book_ID) AS Unique_Books
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY
       c.Customer_ID,
       c.Name
ORDER BY Unique_Books DESC;


-- 20. Find books that have never gone out of stock (Stock > 0).

SELECT
       Book_ID,
       Title,
       Author,
       Stock
FROM Books
WHERE Stock > 0
ORDER BY Stock DESC;

-- 21. Find the month that generated the highest revenue.

SELECT TOP 1
       DATENAME(MONTH, Order_Date) AS Month_Name,
       MONTH(Order_Date) AS Month_Number,
       SUM(Total_Amount) AS Total_Revenue
FROM Orders
GROUP BY
       MONTH(Order_Date),
       DATENAME(MONTH, Order_Date)
ORDER BY Total_Revenue DESC;


-- 22. Find the year with the highest number of orders.

SELECT TOP 1
       YEAR(Order_Date) AS Order_Year,
       COUNT(Order_ID) AS Total_Orders
FROM Orders
GROUP BY YEAR(Order_Date)
ORDER BY Total_Orders DESC;


-- 23. Find the average spending of customers by country.

SELECT
       c.Country,
       AVG(Customer_Total) AS Average_Spending
FROM
(
     SELECT
            Customer_ID,
            SUM(Total_Amount) AS Customer_Total
     FROM Orders
     GROUP BY Customer_ID
) o
JOIN Customers c
ON o.Customer_ID = c.Customer_ID
GROUP BY c.Country
ORDER BY Average_Spending DESC;


-- 24. Find customers whose total spending is greater than the overall average customer spending.

SELECT
       c.Customer_ID,
       c.Name,
       SUM(o.Total_Amount) AS Total_Spending
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY
       c.Customer_ID,
       c.Name
HAVING SUM(o.Total_Amount) >
(
     SELECT AVG(Customer_Total)
     FROM
     (
          SELECT SUM(Total_Amount) AS Customer_Total
          FROM Orders
          GROUP BY Customer_ID
     ) AvgTable
);


-- 25. Display each customer's first and latest order date.

SELECT
       c.Customer_ID,
       c.Name,
       MIN(o.Order_Date) AS First_Order,
       MAX(o.Order_Date) AS Latest_Order
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY
       c.Customer_ID,
       c.Name
ORDER BY c.Customer_ID;


-- 26. Find books priced higher than the average price of their own genre.

SELECT
       b1.Book_ID,
       b1.Title,
       b1.Genre,
       b1.Price
FROM Books b1
WHERE Price >
(
      SELECT AVG(b2.Price)
      FROM Books b2
      WHERE b1.Genre = b2.Genre
);

-- 27. Find the author with the highest average book price.

SELECT TOP 1
       Author,
       AVG(Price) AS Average_Price
FROM Books
GROUP BY Author
ORDER BY Average_Price DESC;


-- 28. Display all genres along with their total stock and total books sold.

SELECT
       b.Genre,
       SUM(DISTINCT b.Stock) AS Total_Stock,
       COALESCE(SUM(o.Quantity),0) AS Total_Books_Sold
FROM Books b
LEFT JOIN Orders o
ON b.Book_ID = o.Book_ID
GROUP BY b.Genre;



