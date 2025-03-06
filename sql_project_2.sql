-- checking for data --

select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;


-- PROJECT TASK --

-- ### 2. CRUD Operations(CREATE - READ - UPDATE - DELETE) --------------------------------------------------


-- Task 1. Create a New Book Record -
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books 
values
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

select * from books;


-- Task 2: Update an Existing Member's Address - 

UPDATE members
SET member_address = '125 Main St'
where member_id = 'C101';

-- TESTING --
select * from members
order by member_id;



-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS107' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id = 'IS121';       -- we deleted this because IS121 does not exist in return_status table and
								-- IS107 id is dependent on return_status table thats why we are not able to delete this particular record.

-- TESTING --
select * from issued_status;



-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * from issued_status
where issued_emp_id = 'E101';



-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
	issued_emp_id, 
	COUNT(issued_id) AS total_book_issued 
from issued_status
group by 1
having count(issued_id) > 1;



-- ### 3. CTAS (Create Table As Select) --------------------------------------------------

-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
-- in this, we need to find how many time a book is issued.....

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


SELECT * FROM book_issued_count;




-- ### 4. Data Analysis & Findings -------------------------------------------------

-- Task 7. **Retrieve All Books in a Specific Category:

SELECT * from books
where category = 'Classic';


-- Task 8: Find Total Rental Income by Category:

SELECT 
	category, 
	SUM(rental_price), 
	COUNT(*) 
from books
group by 1;



-- Task 9. **List Members Who Registered in the Last 180 Days**:

-- let's insert 3 rows....as this dataset contain values of past years but we need to calculate for last 180 days.

-- insert into members
-- values
-- ('C120','Iron Man','999 Stark St','2024-12-24'),
-- ('C121','Captain America','777 Captain St','2024-11-11'),
-- ('C122','Loki','111 Asgard St','2025-01-26');


SELECT * FROM members
where reg_date >= CURRENT_DATE - INTERVAL '180 days';


-- Task 10: List Employees with Their Branch Manager's Name and their branch details**:
-- IMPORTANT QUESTION --

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



-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold

CREATE TABLE book_price_more_than_threshold
AS
SELECT * FROM books
where rental_price > 6;


SELECT * FROM book_price_more_than_threshold;



-- Task 12: Retrieve the List of Books Not Yet Returned

-- IN issued_status table we have 34 books but in return_status table we have only 14 books. means only 14 books have een returned.
-- & we need to find how many books have not been returned -- 

--LOGIC -- JOIN

-- vo saari books jinki return_id NULL hai...vo return nhi hui hai....and that is something we need to find.

SELECT i.issued_book_name FROM issued_status AS i
LEFT JOIN
return_status AS r
ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL;	




------------------------------------------- ADVANCE SQL QUERIES --------------------------------------------------------------------------


select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;


/*
Task 13: 
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

-- JOIN --> issued_status = members = books = return_status
-- Filter books which is return
-- overdue > 30


SELECT CURRENT_DATE         -- for getting current date --


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
LEFT JOIN                         -- because return_status has 14 rows and issued_status table has 38 rows. that's why we need to use left join. so that, no. of table does not get reduced.
return_status as r
	ON r.issued_id = i.issued_id
	
WHERE r.return_date IS NULL 
	AND (CURRENT_DATE - i.issued_date) > 30
	
ORDER BY 1;



-----------------------------------------------------------------------------------------------------------------

select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


/*    
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/

-- matlab isme hai ki as soon as koi person book return krta hai in retrun_status table, uska status books table me automatically update("YES") ho jaaye... 
-- check return_status table ---> issued_id ----> ye books return ho chuki hai....

-- in return_status table issued_id is from IS107 - IS118...iske alawa issued_id ki books return nhi hui hai...
-- lets check whether this particular book is available or not.......WE ARE TRYING TO UPDATE IT MANUALLY FOR NOW....

SELECT * FROM issued_status          -- IS127 -- 

SELECT * FROM books
WHERE isbn = '978-0-679-77644-3';

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-679-77644-3';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-679-77644-3';


-- NOW CHECK RETURN_STATUS TABLE WHETHER THIS BOOK IS RETURNED OR NOT.....

SELECT * FROM return_status
WHERE issued_id = 'IS127';      -- you will get empty row or no data...because this book is not returned as we changed its status....


-- NOW IF SOMEONE RETURN THE BOOK TODAY, THEN YOU NEED TO UPDATE THE RETURN_STATUS TABLE.....

insert into return_status(return_id, issued_id, return_date, book_quality)
values
('RS121','IS127',CURRENT_DATE,'Good');


-- NOW WE HAVE TO UPDATE THE STATUS OF A BOOK TO "YES" ----------------------------

UPDATE books
SET status = 'yes'
WHERE isbn = '978-0-679-77644-3';


-- NOW CHECK THE STATUS ---------------------------------
SELECT * FROM books
WHERE isbn = '978-0-679-77644-3';


/* SO IF WE DO IT MANUALLY IT WILL TAKE LOT OF TIME AND IT IS NOT A EFFICIENT APPROACH BECAUSE YOU HAVE TO
	WRITE CODE AGAIN & AGAIN. SO WHAT TO DO ??

use - STORED PROCEDURES ---> 

A Stored Procedure is a set of SQL commands saved in the database that can be executed whenever needed. 
It helps automate tasks like inserting, updating, or deleting data without writing the same SQL repeatedly.
	
	
Stored Procedure ek set of SQL statements hota hai jo database ke andar save hota hai 
aur jab chahe tab execute kiya ja sakta hai. Matlab, baar-baar same SQL likhne ki zaroorat nahi hoti.

Q. - Why Use Stored Procedures?

Saves Time – No need to write the same queries again and again.
Faster Execution – Runs directly from the database, reducing processing time.
More Secure – Users can execute the procedure without direct access to tables.


*/


select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;

-- STORED PROCEDURE ---------------------------------------------- 

CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(15))
LANGUAGE plpgsql
AS $$

DECLARE
		-- for declaring variables --
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




---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
Task 15: Branch Performance Report - 

	Create a query that generates a performance report for each branch, showing the number of books issued, 
	the number of books returned, and the total revenue generated from book rentals.
*/


select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;


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


/* We use GROUP BY to ensure that the COUNT() and SUM() functions calculate values for
	each branch and manager separately, rather than across the entire table. 

also we have used CTAS for code reusability....
*/

---------------------------------------------------------------------------------------------------------------------------------


-- Task 16: CTAS: Create a Table of Active Members
/*Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members
	who have issued at least one book in the last 2 months. */

select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;


SELECT * FROM members
WHERE member_id IN (SELECT
						DISTINCT issued_member_id
					FROM issued_status
					WHERE 
						issued_date >= CURRENT_DATE - INTERVAL '2months'
					)

---------- OR (by joining member and issued_status table) ---------------------------------------------

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

/* Use JOIN when working with related tables and direct filtering (faster & better for large data)
   Use Subquery when filtering based on aggregated values, computed results, or existence checks
*/

----------------------------------------------------------------------------------------------------------
 


-- Task 17: Find Employees with the Most Book Issues Processed
/*Write a query to find the top 3 employees who have processed the most book issues. 
	Display the employee name, number of books processed, and their branch. */


select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;



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


----------------------------------------------------------------------------------------------------------------

/*
Task 19: Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: 

The stored procedure should take the book_id as an input parameter. 

The procedure should first check if the book is available (status = 'yes'). 

If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 

If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/



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


CALL book_issued_status('IS155','C108', '978-0-553-29698-2','E104');  -- RECORD ADDED SUCCESSFULLY -- 


-- here we want to insert a book that is not available ---
CALL book_issued_status('IS156','C108', '978-0-7432-7357-1','E104'); 


SELECT * FROM books
WHERE isbn = '978-0-553-29698-2';


SELECT * FROM books
WHERE isbn = '978-0-7432-7357-1';



---------------------------------------------------------------------------------------------------------------------------------------------------













































