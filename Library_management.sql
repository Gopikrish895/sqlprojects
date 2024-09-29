-- Library Management System Project
--Creating Branch table
Drop table if exists branch;
Create table branch
(
	branch_id varchar(10) primary key,
	manager_id varchar(10),
	branch_address	varchar(50),
	contact_no varchar(10)
);

Alter table branch
alter column contact_no type varchar(15);
-- creating employee table

Drop table if exists employee;
Create table employee 
(
 emp_id varchar(10) Primary Key,
 emp_name varchar(25),
 position varchar(15),
 salary int,
 branch_id varchar(25)
 );

--Create books table
Drop table if exists books;
Create table books
(
isbn varchar(30) primary key,
book_title	varchar(60),
category varchar(35),
rental_price float,
status varchar(15),
author varchar(30),
publisher varchar(50)
);

Alter table books
alter column isbn type varchar(50);

--Create member table
Drop table if exists members;
Create table members
(
member_id varchar(10) primary key,
member_name varchar(35),
member_address varchar(75),
reg_date DATE
);

--Create issued_status
Drop table if exists issued_status;
Create table issued_status
(issued_id varchar(10) primary key,
issued_member_id varchar(15),
issued_book_name varchar(70),
issued_date date,
issued_book_isbn varchar(30),
issued_emp_id varchar(10)
);

-- Create returned status
Drop table if exists return_table;
Create table return_status
(
return_id varchar(10) primary key,
issued_id varchar(10),
return_book_name varchar(70),
return_date date,	
return_book_isbn varchar(20)
);

-- Foreign Key
Alter table issued_status
Add constraint fk_members
foreign key (issued_member_id)
references members(member_id);

Alter table issued_status
add constraint fk_books
foreign key (issued_book_isbn)
references books(isbn);

Alter table issued_status
add constraint fk_employees
foreign key (issued_emp_id)
references employee(emp_id);

Alter table employee
add constraint fk_branch
foreign key (branch_id)
references branch(branch_id);

Alter table return_status
add constraint fk_issued_status
foreign key (issued_id) 
references issued_status(issued_id);

/*Create, Read, Update, Delete Records */

/*Q1.Create a New Book Record-- "978-1-60129-456-2', 
'To Kill a Mockingbird', 'Classic', 6.00, 'yes',
'Harper Lee', 'J.B. Lippincott & Co.')" */
insert into books(isbn,book_title,category,rental_price,status,author, publisher)
values('978-1-60129-456-2','To Kill a Mockingbird','Classic',6.00,'yes',
'Harper Lee', 'J.B. Lippincott & Co.');

/*Q2. Update an existing Member's Address */
update members
set member_address = '25, Ram Street'
where member_id= 'C103';

/*Q3.delete record of issued id = IS121 from issued status table */
delete from issued_status
where issued_id = 'IS121';

/*Q4.Retrieve all books issued by the emp id = E101*/
select *
from issued_status
where issued_emp_id = 'E101';

/*Q5. List all members who have issued more than 1 book */
select issued_member_id, count(*) as Number_of_books
from issued_status
group by 1 
having count(*)>1

/* Q6. Create Summary table based on query results each book and total book issued count*/

create table book_issued_cnt as
(select b.isbn, b.book_title, count(ist.issued_id) as issue_count
from issued_status as ist
join books as b
on ist.issued_book_isbn= b.isbn
group by b.isbn, b.book_title)

/* Data Analysis 
Q7. find all books in a specific category */
select * from books
where category = 'Science Fiction'

/*Q8. Find total rental by each category */
select b.category, sum(b.rental_price),count(*)
from issued_status as ist 
Join books as b
on b.isbn=ist.issued_book_isbn
Group by 1

/*Q9. List Members Who Registered in the Last 180 Days */
Select * 
from members
where reg_date>= current_date - interval '180 days';

/*Q10.List Employees with Their Branch Manager's Name and 
their branch details */

Select e1.emp_name, e2.emp_name as Manager
from branch b 
join employee e1
on b.branch_id=e1.branch_id
join employee e2
on e2.emp_id = b.manager_id

/*Q11.Create a Table of Books with Rental Price Above a 6.5 */
Create table exp_books as 
Select *
from books
where rental_price >6.5

/*Q12.Retrieve the List of Books Not Yet Returned */
Select *
From issued_status ist
left join return_status rst on 
rst.issued_id= ist.issued_id
where rst.return_id is null

/*Q13.Identify Members with Overdue Books
Write a query to identify members who have overdue books 
(assume a 30-day return period). Display the member's_id, 
member's name, book title, issue date, and days overdue. */

Select ist.issued_member_id, m.member_name, b.book_title, ist.issued_date,
      current_date - ist.issued_date as over_due_date
from issued_status as ist 
join members as m
on m.member_id = ist.issued_member_id
join books b
on b.isbn= ist.issued_book_isbn
left join return_status rs
on rs.issued_id = ist.issued_id
where 
rs.return_date is null 
and 
current_date - ist.issued_date >30 
order by 1 

/*Q14. Write a query to update the status of books in the 
books table to "Yes" when they are returned 
(based on entries in the return_status table). */