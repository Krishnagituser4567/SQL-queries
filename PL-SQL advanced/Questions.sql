--1. Create a PL/SQL block to adjust the salary from 7900 to 9000 of the employee whose ID 122.

CREATE PROCEDURE sp_salary_update
  @x INT,
  @new_salary INT
AS
BEGIN
  UPDATE employees
  SET salary = @new_salary
  WHERE employee_id = @x;
END;

EXEC sp_salary_update @x = 122, @new_salary = 50000;


select * from employees where employee_id=122; 
----------------------------------------------------------------------------------------------------------
--2.Count number of employees in department 50 and check whether this department have any vacancies 
--or not. There are already maximum of 45 employees in this department. 

select * from employees;

alter table employees add  department_id int ;

select  distinct(job_title),count(*) as no from employees group by job_title;

create table department (
Department_id int primary key ,
Department_name varchar(20),
Max_member int )
--finance = accountant ,Accounting Manager,Finance Manager,Purchasing Clerk,Purchasing Manager,Stock Clerk,Stock Manager
--admistration=Administration Assistant,Administration Vice President,President,Human Resources Representative
--sales =Sales Manager,Sales Representative,Shipping Clerk
--technical=programmer
--marketing=Marketing Manager,Marketing Representative,Public Accountant,Public Relations Representative
insert into department (Department_id ,Department_name ,Max_member) values(10,'Finance',30),
(20,'admistration',100),(30,'technical',30),(40,'marketing',100),(50,'sales',100);

select * from department;

alter table employees add CONSTRAINT fk_department FOREIGN KEY(department_id )REFERENCES department(department_id )
ON DELETE CASCADE;

delete
create procedure update_table (@jobtitle varchar(20),@dept_id int)as
begin
update employees set department_id = @dept_id where job_title = @jobtitle;
end;

exec update_table @jobtitle = 'Shipping Clerk',@dept_id=50;


DECLARE @department_id INT = 50;
DECLARE @max_employees INT = 45;
DECLARE @employee_count INT;

-- Count the number of employees in department 50
SELECT @employee_count = COUNT(*)
FROM employees
WHERE department_id = @department_id;

-- Check for vacancies
IF @employee_count >= @max_employees
  PRINT 'Department ' + CAST(@department_id AS VARCHAR(10)) + ' is full.';
ELSE
  PRINT 'Department ' + CAST(@department_id AS VARCHAR(10)) + ' has vacancies.';


  select count(*) from employees where department_id =50 ;

---------------------------------------------------------------------------------------------------------
--3. Create a PL/SQL procedure to calculate the incentive achieved according to the specific sale limit.

CREATE PROCEDURE calculate_incentive
  @sales_limit DECIMAL(10, 2),
  @incentive DECIMAL(10, 2) OUTPUT
AS
BEGIN
  -- Declare variables
  DECLARE @total_sales DECIMAL(10, 2);

  -- Calculate the total sales
  SELECT @total_sales = SUM(quantity * unit_price)
  FROM order_items;

  -- Calculate the incentive
  IF @total_sales >= @sales_limit
    SET @incentive = @total_sales * 0.1; -- 10% incentive rate
  ELSE
    SET @incentive = 0;
END;

DECLARE @incentive_value DECIMAL(10, 2);

EXEC calculate_incentive @sales_limit = 1000 , @incentive = @incentive_value OUTPUT;

SELECT @incentive_value as incentive_value;
-----------------------------------------------------------------------------------------------------------

--4. Print a list of managers using PL/SQL explicit cursors. 

-- Declare variables
DECLARE @manager_first_name VARCHAR(50);
DECLARE @manager_last_name VARCHAR(50);

-- Declare cursor-like result set
DECLARE cur CURSOR LOCAL FOR
  SELECT e.first_name, e.last_name
  FROM employees e
  JOIN employees m ON e.manager_id = m.employee_id;

-- Open the cursor
OPEN cur;

-- Fetch the first row
FETCH NEXT FROM cur INTO @manager_first_name, @manager_last_name;

-- Loop through the result set and print the manager names
print('Managers in the employees table are:');
WHILE @@FETCH_STATUS = 0
BEGIN
  -- Print the manager name
  
  PRINT CONCAT(@manager_first_name, ' ', @manager_last_name);

  -- Fetch the next row
  FETCH NEXT FROM cur INTO @manager_first_name, @manager_last_name;
END;

-- Close the cursor
CLOSE cur;

-- Deallocate the cursor
DEALLOCATE cur;
---------------------------------------------------------------------------------------------------------
--5. Create a t/SQL cursor to calculate total salary from employee table without using sum() function.
DECLARE @employee_id INT;
DECLARE @salary INT;
DECLARE @total_salary INT = 0;

-- Declare the cursor
DECLARE cur CURSOR LOCAL FOR
  SELECT employee_id, salary
  FROM employees;

-- Open the cursor
OPEN cur;

-- Fetch the first row
FETCH NEXT FROM cur INTO @employee_id, @salary;

-- Loop through the result set and calculate the total salary
WHILE @@FETCH_STATUS = 0
BEGIN
  -- Increment the total salary
  SET @total_salary = @total_salary + @salary;
  
  -- Fetch the next row
  FETCH NEXT FROM cur INTO @employee_id, @salary;
END;

-- Close the cursor
CLOSE cur;

-- Deallocate the cursor
DEALLOCATE cur;

-- Print the total salary
PRINT 'Total Salary: ' + CONVERT(VARCHAR(20), @total_salary);
----------------------------------------------------------------------------------------------------------
--6. Display the name and salary of each employee in the EMPLOYEES table whose salary is less than that 
--specified by a passed-in parameter value.

CREATE PROCEDURE display_employees_below_salary
  @max_salary DECIMAL(10, 2)
AS
BEGIN
  -- Display employee name and salary
  SELECT CONCAT(first_name, ' ', last_name) AS Employee, salary AS Salary
  FROM employees
  WHERE salary < @max_salary;
END;

EXEC display_employees_below_salary @max_salary = 5000;
------------------------------------------------------------------------------------------------------------
--7. Display the name of the employee and increment percentage of salary according to their working 
--experiences.

CREATE VIEW employees_experience AS
SELECT
  CONCAT(first_name, ' ', last_name) AS Employees_name,
  2031 - YEAR(hire_date) AS experience
FROM
  employees;

  SELECT * FROM employees_experience;


CREATE PROCEDURE display_employee_increment
AS
BEGIN
  -- Display employee name and increment percentage
  SELECT 
    employees_name AS Employee, 
    CASE
      WHEN experience >= 10 THEN '15%' -- 15% increment for experience >= 10 years
      WHEN experience >= 5 THEN '10%' -- 10% increment for experience >= 5 years
      WHEN experience >= 3 THEN '5%' -- 5% increment for experience >= 3 years
      ELSE 'No increment'
    END AS IncrementPercentage
  FROM employees_experience;
END;

EXEC display_employee_increment;
--------------------------------------------------------------------------------------------------------------
--8. Display the number of employees by month using PL/SQL block. 
CREATE PROCEDURE display_employees_by_month
AS
BEGIN
  -- Display the number of employees by month
  SELECT MONTH(hire_date) AS Month, COUNT(*) AS NumEmployees
  FROM employees
  GROUP BY MONTH(hire_date)
  ORDER BY Month;
END;

EXEC display_employees_by_month;
-------------------------------------------------------------------------------------------------------------
--9. Create a PL/SQL block to insert records from employee table to another table.

CREATE TABLE employees_info
(
  employee_id INT PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(50) NOT NULL
);

CREATE PROCEDURE insert_employee_records
AS
BEGIN
  -- Insert records from employee table into another table
  INSERT INTO employees_info (employee_id, first_name, last_name, email, phone)
  SELECT employee_id, first_name, last_name, email, phone
  FROM employees;
END;

EXEC insert_employee_records;

select * from employees_info;
------------------------------------------------------------------------------------------------------------
--10. Create the PL/SQL package to calculate net value of the ordered items done by a particular customer 
--in a specific year.

CREATE FUNCTION calculate_net_value
(
  @customer_id INT,
  @order_year INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
  DECLARE @total_amount DECIMAL(10,2);

  -- Calculate the net value by summing the amounts of ordered items
  SELECT @total_amount = SUM(quantity*unit_price)
  FROM orders o
  JOIN order_items i ON o.order_id = i.order_id
  WHERE o.customer_id = @customer_id AND YEAR(o.order_date) = @order_year;

  RETURN @total_amount;
END;

CREATE PROCEDURE display_net_value
(
  @customer_id INT,
  @order_year INT
)
AS
BEGIN
  DECLARE @net_value DECIMAL(10,2);

  -- Call the calculate_net_value function to get the net value
  SET @net_value = dbo.calculate_net_value(@customer_id, @order_year);

  -- Display the net value
  SELECT CONCAT('Net Value for Customer ID ', @customer_id, ' in Year ', @order_year, ': ', @net_value) AS NetValue;
END;

EXEC display_net_value @customer_id = 1, @order_year = 2027;

---------------------------------------------------------------------------------------------------------------
-- 11. Display the first 10 customers using nested table 

SELECT TOP 10 *
FROM (
  SELECT *
  FROM customers
) AS info  ORDER BY customer_id;
-------------------------------------------------------------------------------------------------------------
--12. Fetch the data from employees table for employee_id ‘1001’ using native dynamic SQL (Execute 
--Immediate) and DBMS_SQL.

DECLARE @sql NVARCHAR(MAX);
DECLARE @employee_id INT = 101;

SET @sql = 'SELECT * FROM employees WHERE employee_id = @emp_id';

EXEC sp_executesql @sql, N'@emp_id INT', @emp_id = @employee_id;

--------------------------------------------------------------------------------------------------------------

--13. Create a statement-level trigger, when CRUD operation is performed on employees table

CREATE  TABLE crud_info (
  employees_id INT,
  action VARCHAR(50)
);

CREATE TRIGGER employees_update_trigger
ON employees
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
  -- Check if it's an INSERT operation
  IF EXISTS(SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted)
  BEGIN
    INSERT INTO crud_info (employees_id, action)
    SELECT employee_id, 'insert_operation'
    FROM inserted;
  END

  -- Check if it's an UPDATE operation
  IF EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
  BEGIN
    INSERT INTO crud_info (employees_id, action)
    SELECT employee_id, 'update_operation'
    FROM inserted;
  END

  -- Check if it's a DELETE operation
  IF NOT EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
  BEGIN
    INSERT INTO crud_info (employees_id, action)
    SELECT employee_id, 'delete_operation'
    FROM deleted;
  END
END;


Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE,HIRE_DATE,MANAGER_ID,JOB_TITLE,SALARY) values 
(123,'Summer','Payne','summer.payne@example.com','515.123.8181','2016-06-07',106,'Public Accountant',54236);


delete from employees where employee_id = 123;

update employees
set salary = 20000
where employee_id = 2; 

select * from crud_info;


declare @name int ;
declare curs cursor  for 
select salary  from employees;
open curs;
fetch next from curs into @name;
while @@FETCH_STATUS =0 
begin 
print @name;
fetch next from curs into @name;
end;
close curs; 
deallocate curs;


select * from employees_info;

INSERT INTO employees_info (employee_id, first_name, last_name, email, phone)
  SELECT employee_id, first_name, last_name, email, phone
  FROM employees;

begin transaction p1;

delete from employees_info ;

--commit transaction p1 ;

rollback transaction p1;

create view employee_infos as
select e.employee_id  , job_title from employees_info e join employees em on e.employee_Id = em.employee_id;


select count(*),job_title from employee_infos group by job_title;

create procedure tim
@salary int ,
@employee_id int
as
begin 

update employees 
set salary = @salary
where employee_id = @employee_id;
end;

create trigger tri
on employees 
after update 
as 
begin 
print 'update happened ' 
end ;

declare @empid int;

declare @t int = 0;
declare cur cursor for select employee_id from employee_infos;
open cur;

fetch next from cur into @empid;

while @@FETCH_STATUS = 0 
begin 

set @t += 1

fetch next from cur into @empid;
end ;
print @t ;
close cur;
deallocate cur;


SELECT * FROM employees WHERE salary = (SELECT MAX(salary) FROM employees);

----like operator
--LIKE Operator	Description
--WHERE CustomerName LIKE 'a%'	Finds any values that start with "a"
SELECT * FROM employees WHERE first_name like 'a%' AND first_name LIKE '%a';

--WHERE CustomerName LIKE '%a'	Finds any values that end with "a"
--WHERE CustomerName LIKE '%or%'	Finds any values that have "or" in any position
SELECT * FROM employees WHERE first_name like '%a%';

--WHERE CustomerName LIKE '_r%'	Finds any values that have "r" in the second position
SELECT * FROM employees WHERE first_name like '___a%';

--WHERE CustomerName LIKE 'a_%'	Finds any values that start with "a" and are at least 2 characters in length
SELECT * FROM employees WHERE first_name like 'a__%';

--WHERE CustomerName LIKE 'a__%'	Finds any values that start with "a" and are at least 3 characters in length
--WHERE ContactName LIKE 'a%o'	Finds any values that start with "a" and ends with "o"

SELECT * FROM employees WHERE first_name like 'a%t';

-- substring
select SUBSTRING('free',1,1);

declare @name varchar(20);
declare cur cursor for select first_name from employees;
open cur ;
fetch next from cur into @name;
while @@FETCH_STATUS = 0
begin
print(@name)
fetch next from cur into @name;
end;
close cur;
deallocate cur;

print(cast(getdate() as date))

