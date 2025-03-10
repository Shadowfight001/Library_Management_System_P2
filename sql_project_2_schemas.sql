-- Library Management System - PROJECT-02 -- 

-- creating branch table --

DROP TABLE IF EXISTS branch;
create table branch
(
	branch_id VARCHAR(10) PRIMARY KEY,
	manager_id	VARCHAR(10),
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
);


-- creating books table --

DROP TABLE IF EXISTS books;
create table books
(
	isbn VARCHAR(20) PRIMARY KEY,
	book_title	VARCHAR(70),
	category VARCHAR(20),	
	rental_price FLOAT,	
	status VARCHAR(10),
	author VARCHAR(30),
	publisher VARCHAR(55)
);


-- creatign members table --

DROP TABLE IF EXISTS members;
create table members
(
	member_id VARCHAR(10) PRIMARY KEY,
	member_name	VARCHAR(20),
	member_address VARCHAR(20),
	reg_date DATE
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
	return_book_isbn VARCHAR(30)
);


-- FOREIGN KEY CONSTRAINT --

ALTER TABLE issued_status
add constraint fk_members
FOREIGN KEY(issued_member_id)
REFERENCES members(member_id);



ALTER TABLE issued_status
add constraint fk_books
FOREIGN KEY(issued_book_isbn)
REFERENCES books(isbn);



ALTER TABLE issued_status
add constraint fk_employees
FOREIGN KEY(issued_emp_id)
REFERENCES employees(emp_id);


ALTER TABLE employees
add constraint fk_branch
FOREIGN KEY(branch_id)
REFERENCES branch(branch_id);


ALTER TABLE return_status
add constraint fk_issued_status
FOREIGN KEY(issued_id)
REFERENCES issued_status(issued_id);











