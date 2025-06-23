-- Data Cleaning

-- I first create a duplicate table of the original data to allow myself a margin of error without corrupting the original data
drop table if exists expenses;

create table expenses
like `my finances`;

insert into expenses
select * from `my finances`;
-- cleaning expenses table

select *
from `my finances`;

-- I first delete the first three rows as they are unecessary
delete from expenses
where ï»¿ ='ï»¿';

delete from expenses
where ï»¿ = 'Expenses';

-- I decided to rename the columns. This made the whole cleaning process easier and also improved the visulization of the table
alter table `expenses`
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
set `transdate` = str_to_date(`date`, '%Y-%m-%d');

alter table expenses
modify column `transdate` date first;

alter table expenses
drop column `date`;

/*I clean the `amount` column by removing any '$' or ',' signs and converting the remaining values to decimals. 
I also noticed some transactions were negative and were duplicates of the same transaction but positive, meaning they cancel each other out. 
I deleted both transactions.
*/

select *
from expenses;

UPDATE expenses
SET amount = CAST(REPLACE(REPLACE(amount, '$', ''), ',', '') AS DECIMAL(10,2));

ALTER TABLE expenses
MODIFY COLUMN amount DECIMAL(10,2);

delete from expenses
where amount like '-%';

-- I noticed some transactions were refundable, meaning they do not appear in the income data and can therefore be deleted.

delete from expenses
where `note` = 'Refundable';

-- I update descriptions to make the purchases consistent. 
-- I create a temp table that will allow me to change the name of the purchases easily without having to individually update each one.
-- This will also be helpful in the future if the table gets updated.

CREATE TEMPORARY TABLE description_mapping (
    keyword VARCHAR(100),
    new_description VARCHAR(100),
    sub_category_filter VARCHAR(100),
    category_filter VARCHAR(100)
);

INSERT INTO description_mapping (keyword, new_description, sub_category_filter, category_filter) VALUES
('%HORTONS%', 'Tim Hortons', NULL, NULL),
('%Safa%', 'Safa Elegance Fashion', NULL, NULL),
('%insurance%', 'All State Insurance', 'insurance', NULL),
('%apple%', 'Apple', NULL, NULL),
('%costco%', 'Costco', 'Grocery', NULL),
('%costco%', 'Costco', 'eating Out', NULL),
('%costco%', 'Costco', 'Membership', NULL),
('%costco%', 'Costco', NULL, 'Retail and Grocery'),
('%costco%', 'Costco Gas', 'Car', NULL),
('%3 brother%', '3 Brothers', NULL, NULL),
('%relay%', 'Relay Airport', NULL, NULL),
('%police%', 'Police Station', NULL, NULL),
('%adonis%', 'Adonis', NULL, NULL),
('%african%', 'African BBQ House', NULL, NULL),
('%agence%', 'Agence de mobilité durable de Montréal', NULL, NULL),
('%alamo%', 'Alamo', NULL, NULL),
('%amaz%', 'Amazon', NULL, NULL),
('%chicken%', 'YKO BBQ Chicken', NULL, NULL),
('%yko%', 'YKO BBQ Chicken', NULL, NULL),
('%bell%', 'Bell', NULL, NULL),
('%best%', 'Best Buy', NULL, NULL),
('%Canadian Tire%', 'Canadian Tire', NULL, NULL),
('%OCT%', 'O-Train', NULL, NULL),
('%city of %', 'City Of Ottawa', NULL, NULL),
('%costco gas%', 'Costco Gas', NULL, NULL),
('%wholesale%', 'Costco', NULL, NULL),
('%dollarama%', 'Dollarama', NULL, NULL),
('%domino%', 'Dominos Pizza', NULL, NULL),
('%esso%', 'Esso', NULL, NULL),
('%basics%', 'Food Basics', NULL, NULL),
('%impark%', 'IMPARK', NULL, NULL),
('%intuit%', 'Turbotax', NULL, NULL),
('%enbridge%', 'Enbridge', NULL, NULL),
('%loblaws%', 'Loblaws', NULL, NULL),
('%manh%', "Manhattan's Hand-Made Burgers", NULL, NULL),
('%mc%', "McDonald's", NULL, NULL),
('%pretzel%', "Mr. Pretzels", NULL, NULL),
('%osmow%', "Osmow's", NULL, NULL),
('%paypal%', 'Paypal', NULL, NULL),
('%petro%', 'Petro Canada', NULL, NULL),
('%preci%', 'Precision Cornea Centre', NULL, NULL),
('%shell%', 'Shell', NULL, NULL),
('%shoppers%', 'Shoppers Drug Mart', NULL, NULL),
('%uber%', 'Uber Eats', 'Eating Out', NULL),
('%uber%', 'Uber', 'Uber', NULL),
('%wal%', 'Wal-Mart', NULL, NULL);

UPDATE expenses e
JOIN description_mapping m 
  ON e.description LIKE m.keyword
  AND (m.sub_category_filter IS NULL OR e.`sub-category` = m.sub_category_filter)
  AND (m.category_filter IS NULL OR e.category = m.category_filter)
SET e.description = m.new_description;

UPDATE expenses e
SET e.description = 'Kings of Cuts'
WHERE e.note LIKE '%cut%';


select * from expenses where `sub-category` like 'maintenance%';

-- I noticed the 'maintenance' and 'maintenance & supply' sub-categories mean the same thing, so I standardized the sub-category.

update expenses
set `sub-category` = 'Maintenance'
where `sub-category` like 'maintenance%';

update expenses
set `sub-category` = 'Car Accessory'
where `note` = 'Car Phone Mount';

------------------------------------------------------------------------------------
-- cleaning income table

-- once again, creating a duplicate of the original table to allow a margin of error

drop table if exists income2;

create table income2
like income;

insert into income2
select * from income;

select * from income2;

-- Renaming columns in `income2` for consistency and clarity

alter table `income2`
rename column `MyUnknownColumn` to `date`,
rename column `MyUnknownColumn_[0]`to `description`,
rename column `MyUnknownColumn_[1]` to `category`,
rename column `MyUnknownColumn_[2]`to `sub-category`,
rename column `MyUnknownColumn_[3]`to `note`,
rename column `MyUnknownColumn_[4]`to `amount`;



-- Removing irrelevant or 'total' rows from `income2`

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


-- One date was in the future and based on the data prior, I assumed it to be a simple typo
update income2
set date = '2025-06-12'
where date = '2026-06-12';

-- I will now be going through each column to see if there are any irregularites or errors in the data and trying to fill in NULL data where possible

select * from income2 where category = 'Pay';

update income2
set `sub-category` = 'EI'
where description = 'Employment Insurance';

update income2
set `sub-category` = 'Tax Rebate'
where description = 'CDACARBONREBATE';

update income2
set `sub-category` = 'Sales Tax Rebate'
where description = 'GST';

update income2
set `sub-category` = 'Salary'
where category = 'Pay';

-- Adding a primary key to both `expenses` and `income2` for better indexing and uniqueness
ALTER TABLE expenses
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE expenses
MODIFY COLUMN id INT AUTO_INCREMENT FIRST;

ALTER TABLE income2
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE income2
MODIFY COLUMN id INT AUTO_INCREMENT FIRST;

-- I noticed when adding the id column to expenses it did not keep the date order which may be a little confusing when working with the data
-- I will create a table named oexpenses to differentiate it as an ordered expenses table

CREATE TABLE oexpenses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  transdate DATE,
  description VARCHAR(255),
  category VARCHAR(100),
  `sub-category` VARCHAR(100),
  note TEXT,
  amount DECIMAL(10,2)
);

INSERT INTO oexpenses (transdate, description, category, `sub-category`, note, amount)
SELECT transdate, description, category, `sub-category`, note, amount
FROM expenses
ORDER BY transdate;



select * from oexpenses;
select * from income2;
-- The data is clean!