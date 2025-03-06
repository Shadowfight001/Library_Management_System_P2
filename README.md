# Library Management System using SQL Project - P2

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_project_2`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/najirh/Library-System-Management---P2/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/najirh/Library-System-Management---P2/blob/main/library_erd.png)

- **Database Creation**: Created a database named `library_project_2`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
-- Library Management System - PROJECT-02 -- 

CREATE DATABASE library_project_2;

-- creating branch table --

DROP TABLE IF EXISTS branch;
create table branch
(
	branch_id VARCHAR(10) PRIMARY KEY,
	manager_id VARCHAR(10),
	branch_address VARCHAR(50),
	contact_no VARCHAR(15)
);


-- creating employees table --

DROP TABLE IF EXISTS employees;
create table employees
(
	emp_id VARCHAR(10) PRIMARY KEY,
	emp_name VARCHAR(25),
	position VARCHAR(25),
	salary INT,
	branch_id VARCHAR(25) --FK
	FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- creatign members table --

DROP TABLE IF EXISTS members;
create table members
(
	member_id VARCHAR(10) PRIMARY KEY,
	member_name VARCHAR(20),
	member_address VARCHAR(20),
	reg_date DATE
);


-- creating books table --

DROP TABLE IF EXISTS books;
create table books
(
	isbn VARCHAR(20) PRIMARY KEY,
	book_title VARCHAR(70),
	category VARCHAR(20),	
	rental_price FLOAT,	
	status VARCHAR(10),
	author VARCHAR(30),
	publisher VARCHAR(55)
);



-- creatign issued_status table --

DROP TABLE IF EXISTS issued_status;
create table issued_status
(
	issued_id VARCHAR(10) PRIMARY KEY,
	issued_member_id VARCHAR(10),        -- FK
	issued_book_name VARCHAR(70),	
	issued_date	DATE,
	issued_book_isbn VARCHAR(30),    --FK
	issued_emp_id VARCHAR(10)     --FK
);


-- creatign return_status table --

DROP TABLE IF EXISTS return_status;
create table return_status
(
	return_id VARCHAR(10) PRIMARY KEY,
	issued_id VARCHAR(10),
	return_book_name VARCHAR(75),	
	return_date	DATE,
	return_book_isbn VARCHAR(30),
	FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);


```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books 
values
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

select * from books;
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Main St'
where member_id = 'C101';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE issued_id = 'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * from issued_status
where issued_emp_id = 'E101';
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT 
     issued_emp_id, 
     COUNT(issued_id) AS total_book_issued 
from issued_status
group by 1
having count(issued_id) > 1;
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_issued_count
As
SELECT 
     b.isbn, 
     b.book_title, 
     COUNT(i.issued_id) AS no_issued from 
books as b
join 
     issued_status as i
     on b.isbn = i.issued_book_isbn
group by 1,2;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * from books
where category = 'Classic';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT 
     category, 
     SUM(rental_price), 
     COUNT(*) 
from books
group by 1;
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT 
     e1.*,
     b.manager_id, 
     e2.emp_name AS manager_name
FROM employees AS e1
JOIN
   branch AS b
   on b.branch_id = e1.branch_id
JOIN
   employees as e2
   on b.manager_id = e2.emp_id;
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE book_price_more_than_threshold
AS
SELECT * FROM books
where rental_price > 6;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT
     i.issued_book_name
FROM issued_status AS i
LEFT JOIN
    return_status AS r
    ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL;	
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT 
     i.issued_member_id,
     m.member_name,
     b.book_title,
     i.issued_date,
     r.return_date,
     (CURRENT_DATE - i.issued_date) as days_overdue 
FROM issued_status as i
JOIN 
members as m
    ON m.member_id = i.issued_member_id
JOIN
    books as b
    ON b.isbn = i.issued_book_isbn
LEFT JOIN                         
    return_status as r
    ON r.issued_id = i.issued_id
	
WHERE r.return_date IS NULL 
      AND
      (CURRENT_DATE - i.issued_date) > 30	
ORDER BY 1;

```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(15))
LANGUAGE plpgsql
AS $$
DECLARE
     v_isbn VARCHAR(20);
     v_book_name VARCHAR(70);
		
BEGIN
		-- code and logic must be written here --
		-- inserting into return based on user's input --
		
     insert into return_status(return_id, issued_id, return_date, book_quality)
     values
     (p_return_id, p_issued_id, CURRENT_DATE, p_issued_id);
		
-- updating the status from "NO" to "YES" ---------

-- UPDATE books
-- SET status = 'yes'
-- WHERE isbn = '978-0-679-77644-3';
	
/* here we dont have isbn as a parameter and your books table dont know about return_id, issued_id etc.
   so we need to get isbn ---> from where ? ---> issued_book_isbn 

*/

     SELECT
            issued_book_isbn,
            issued_book_name
            INTO 
            v_isbn, v_book_name                -- Variable --> to store data of a column temporarily ---
FROM issued_status
WHERE issued_id = p_issued_id;


-- UPDATING THE STATUS FROM "NO" to "YES" --
	
     UPDATE books
     SET status = 'yes'
     WHERE isbn = v_isbn;

-- PRINTING MESSAGE --

     RAISE NOTICE 'Thankyou for returning the book : %', v_book_name;
	
END;
$$


-- TESTING FUNCTIONS -------------------

ISSUED_ID = 'IS135'
ISBN = '978-0-307-58837-1'


SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

DELETE FROM return_status
where issued_id = 'IS135';

-- CALLING PROCEDURE --- 

CALL add_return_records('RS140','IS135','Good');


-- TESTING FUNCTIONS --------

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';


-------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- TESTING ANOTHER RECORD --

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-375-41398-8';

SELECT * FROM return_status
WHERE issued_id = 'IS134';       -- YOU'LL GET EMPTY TABLE AS OUTPUT BECAUSE THE BOOK IS NOT RETURNED YET.--


-- CALLING PROCEDURE ---

CALL add_return_records('RS141','IS134','Bad');

-- TESTING AGAIN ---------

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8';

SELECT * FROM return_status
WHERE issued_id = 'IS134';     -- NOW, YOU HAVE 1 RECORD. --

```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
CREATE TABLE branch_reports
AS
SELECT 
     br.branch_id,
     br.manager_id,
     COUNT(i.issued_id) as no_of_books_issued,
     COUNT(r.return_id) as no_of_books_returned,
     SUM(b.rental_price) as total_revenue
	
FROM issued_status as i
JOIN 
    employees as e
    ON e.emp_id = i.issued_emp_id
JOIN
    branch as br
    ON br.branch_id = e.branch_id
JOIN
    books as b
    ON b.isbn = i.issued_book_isbn
LEFT JOIN
    return_status as r
    ON r.issued_id = i.issued_id
GROUP BY 1,2;

SELECT * FROM branch_reports;

```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

CREATE TABLE active_members
AS
SELECT 
     DISTINCT m.*
FROM members as m
JOIN 
    issued_status as i 
    ON m.member_id = i.issued_member_id
WHERE i.issued_date >= CURRENT_DATE - INTERVAL '2 months';

SELECT * FROM active_members;

------------------------------------------------------------------

SELECT * FROM members
WHERE member_id IN (SELECT DISTINCT issued_member_id
                    FROM issued_status
                    WHERE 
                       issued_date >= CURRENT_DATE - INTERVAL '2months'
                   );

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT 
     e.emp_name,
     b.*,
     COUNT(i.issued_id) as no_of_books_issued
	
FROM issued_status as i
JOIN 
    employees as e
    ON e.emp_id = i.issued_emp_id
JOIN 
    branch as b
    ON e.branch_id = b.branch_id

GROUP BY 1,2
ORDER BY COUNT(i.issued_id) desc
LIMIT 3;

```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    


**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

CREATE OR REPLACE PROCEDURE 
	book_issued_status(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(10), p_issued_book_isbn VARCHAR(20), 
	p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
	-- Declaring Variables --
     v_status VARCHAR(10);

BEGIN
	-- checking the status of books----
     SELECT 
          status
          INTO v_status
     FROM books
     WHERE isbn = p_issued_book_isbn;

     IF v_status = 'yes' THEN

            INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
            VALUES
            (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

            UPDATE books
            SET status = 'no'
            WHERE isbn = p_issued_book_isbn;

            RAISE NOTICE 'Book Records Added Successfully For Book Isbn : %', p_issued_book_isbn;


     ELSE
            RAISE NOTICE 'Sorry This Book With Isbn :  %, Is Currently Unavailable', p_issued_book_isbn;

	END IF;
END;
$$

------------------ TESTING FUNCTION --------------------------------------------------------

select * from books;
"978-0-553-29698-2"        -- YES --
"978-0-7432-7357-1"        -- NO --

SELECT * from issued_status;


CALL book_issued_status('IS155','C108', '978-0-553-29698-2','E104');    -- RECORD ADDED SUCCESSFULLY -- 


-- here we want to insert a book that is not available ---
CALL book_issued_status('IS156','C108', '978-0-7432-7357-1','E104'); 


SELECT * FROM books
WHERE isbn = '978-0-553-29698-2';


SELECT * FROM books
WHERE isbn = '978-0-7432-7357-1';


```



**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines



## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project showcases SQL skills in developing and managing a library management system. It covers database setup, data manipulation, and advanced queries, offering a strong foundation for efficient data management and analysis.

## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   git clone https://github.com/Shadowfight001/Library_Management_System_P2.git
   ```

2. **Set Up the Database**: Execute the SQL scripts in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the `analysis_queries.sql` file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - UDIT PATEL

This project showcases SQL skills essential for database management and analysis. For more content on SQL and data analysis, connect with me through the following channels:

- **LinkedIn**: [Connect with me](www.linkedin.com/in/udit-patel-1108s)

Thank you for your interest in this project!
