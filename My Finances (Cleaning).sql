-- Data Cleaning

-- I first create a duplicate table of the original data to allow myself a margin of error without corrupting the original data
create table expenses
like `my finances`;

insert into expenses
select * from `my finances`;
-----------------------------------------------------------------------------------------
-- cleaning expenses table

select *
from `my finances`;

-- I first delete the first three rows as they are unecessary
delete from expenses
where ï»¿ ='ï»¿';

delete from expenses
where ï»¿ = 'Expenses';

-- I decided to rename the columns. This made the whole cleaning process easier
alter table `my finances`
rename column `ï»¿` to `date`,
rename column `MyUnknownColumn` to `post_date`,
rename column `MyUnknownColumn_[0]`to `description`,
rename column `MyUnknownColumn_[1]` to `category`,
rename column `MyUnknownColumn_[2]`to `sub-category`,
rename column `MyUnknownColumn_[3]`to `note`,
rename column `MyUnknownColumn_[4]`to `amount`;

delete from expenses
where date = 'Transaction Date';

alter table expenses
drop column `post_date`;


-- The original data has a lot of blank values, since NULL is easier to work with I replaced all blanks to NULL

update expenses
set note = NULL 
where note = '';

update expenses
set `sub-category` = NULL 
where `sub-category` = '';

update expenses
set `category` = NULL 
where `category` = '';

update expenses
set `description` = NULL 
where `description` = '';


-- the original table had two bottom rows with totals, i deleted them

delete from expenses 
where description is NULL and date = '';

delete from expenses
where description is NULL;

-- I am updating the date data type from text to date

select *
from expenses;

alter table expenses
add column `transdate` date;

update expenses
set `transdate` = str_to_date(`date`, '%M %d, %Y');

alter table expenses
modify column `transdate` date first;

alter table expenses
drop column `date`;

ALTER TABLE expenses
MODIFY COLUMN amount DECIMAL(10, 2);

/*I clean the `amount` column by removing any '$' signs and converting the remaining values to decimals. 
I also noticed some transactions were negative and were duplicates of the same transaction but positive, meaning they cancel each other out. 
I deleted both transactions.
*/

select *
from expenses;

update expenses
set amount = cast(replace(amount, '$', '') as decimal(10,2));

delete from expenses
where amount like '-%';

delete from expenses
where amount = 21.99 and description = 'Costco';



-- I noticed some transactions were refundable, meaning they would not appear in the income data, so can be deleted
delete from expenses
where `note` = 'Refundable';



-- I update descriptions to make them consistent
update expenses
set description = 'Tim Hortons'
where description like '%HORTONS%';


update expenses
set description = "Safa Elegance Fashion"
where description like '%Safa%';

update expenses
set description = "All State Insurance"
where `sub-category` like '%insurance%';

update expenses
set description = "Apple"
where description like '%apple%';

update expenses
set description = "Costco"
where description like '%costco%' and `sub-category` = 'Grocery';

update expenses
set description = "Costco"
where description like '%costco%' and `category` = 'Retail and Grocery';

update expenses
set description = "Costco"
where description like '%costco%' and (`sub-category` = 'eating Out' or `sub-category` = 'Membership');

update expenses
set description = "Costco Gas"
where description like '%costco%' and `category` = 'Car';

update expenses
set description = "3 Brothers"
where description like '%3 brother%';

update expenses
set description = "Relay Airport"
where description like '%relay%';

update expenses
set description = "Police Station"
where description like '%police%';

update expenses
set description = "Adonis"
where description like '%adonis%';

update expenses
set description = "African BBQ House"
where description like '%african%';

update expenses
set description = "Agence de mobilité durable de Montréal"
where description like '%agence%';

update expenses
set description = "Alamo"
where description like '%alamo%';

update expenses
set description = "Amazon"
where description like '%amaz%';

update expenses
set description = "Kings of Cuts"
where note like '%cut%';

update expenses
set description = "YKO BBQ Chicken"
where description like '%chicken%';

update expenses
set description = "YKO BBQ Chicken"
where description like '%chicken%';

update expenses
set description = "Bell"
where description like '%bell%';

update expenses
set description = "Best Buy"
where description like '%best%';

------------------------------------------------------------------------------------
-- cleaning income table
select *
from income2;

drop table if exists income2;



-- once again, creating a duplicate of the original table to allow a margin of error

create table income2
like income;

insert into income2
select * from income;



-- Renaming columns in `income2` for consistency and clarity

alter table `income2`
rename column `ï»¿` to `date`,
rename column `MyUnknownColumn`to `description`,
rename column `MyUnknownColumn_[0]` to `category`,
rename column `MyUnknownColumn_[1]`to `sub-category`,
rename column `MyUnknownColumn_[2]`to `note`,
rename column `MyUnknownColumn_[3]`to `amount`;



-- Removing irrelevant or total rows from `income2`

delete from income2
where date = 'ï»¿' or date = 'Income' or date = 'Transaction Date' or date = '' or date = 'Total Income' or date = 'Net Total';



-- Adding a new cleaned column for `amount` to ensure consistent data format

ALTER TABLE income2 ADD COLUMN amount_clean DECIMAL(10,2);

UPDATE income2
SET amount_clean = CAST(
    REPLACE(REPLACE(amount, '$', ''), ',', '') AS DECIMAL(10,2)
);

alter table income2
drop column amount;

alter table income2
change amount_clean amount DECIMAL(10,2);



-- Adding a new column `transdate` to store the date as a proper date type, then eventually switching it back to 'date'

alter table income2
add column `transdate` date;

update income2
set `transdate` = str_to_date(`date`, '%M %d, %Y');

alter table income2
modify column `transdate` date first;

alter table income2
drop column `date`;

alter table income2
rename column transdate to `date`;

-- Cleaning `note` and `sub-category` columns by setting empty values to NULL
update income2
set note = NULL 
where note = '';

update income2
set `sub-category` = NULL 
where `sub-category` = '';

-- Adding a primary key to `income2` for better indexing and uniqueness
ALTER TABLE income2
ADD COLUMN incomeid INT NOT NULL AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE income2
  MODIFY COLUMN incomeid INT PRIMARY KEY FIRST;

-- The data is clean!