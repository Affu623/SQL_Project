create database Project_1;

use Project_1;

-- Sheet 1

select * from loan_status_2;

select * from loan_status;

rename table costomer_income to customer_income;

alter table customer_income_status rename column `customer id` to customer_id;
desc loan_stat;

drop table loan_status;

create table customer_income_status 
select *,
case
when applicantincome > 15000
then "Grade A"
when applicantincome > 9000
then "Grade B"
when applicantincome > 5000
then "Middle class customer"
else "low class"
end as Income_criteria,
case
when applicantincome<5000 and Property_Area = "rural"
then 3.0
when applicantincome<5000 and Property_Area = "semirural"
then 3.5
when applicantincome<5000 and Property_Area = "urban"
then 5
when applicantincome<5000 and Property_Area = "semiurban"
then 5
else 7 end as interest
from customer_income;

-- sheet 2
-- primary second
create table loan_status(loan_id varchar(50), customer_id varchar(50),loan_amount varchar(50),loan_amount_term int,cibil_score int);

delimiter //
create trigger loan_amount_check before insert on loan_status for each row
begin
	if new.loan_amount is null
    then set new.loan_amount = "Loan still processing";
    end if;
end //
delimiter ;

-- secondary table
create table loan_cibil_score_status_details(loan_id varchar(50),loan_amount varchar(50),cibil_score int,cibil_score_status varchar(100));

delimiter //
create trigger cibil_grade after insert on loan_status for each row
begin
	if new.cibil_score > 900 
    then insert into loan_cibil_score_status_details(loan_id,loan_amount,cibil_score,cibil_score_status) 
    values(new.loan_id,new.loan_amount,new.cibil_score,"High cibil score");
    elseif new.cibil_score > 750
    then insert into loan_cibil_score_status_details(loan_id,loan_amount,cibil_score,cibil_score_status) 
    values(new.loan_id,new.loan_amount,new.cibil_score,"No penalty");
    elseif new.cibil_score > 0
    then insert into loan_cibil_score_status_details(loan_id,loan_amount,cibil_score,cibil_score_status) 
    values(new.loan_id,new.loan_amount,new.cibil_score,"Penalty customers");
    elseif new.cibil_score <= 0
    then insert into loan_cibil_score_status_details(loan_id,loan_amount,cibil_score,cibil_score_status) 
    values(new.loan_id,new.loan_amount,new.cibil_score,"Rejected customers (loan cannot apply)");
	end if;
end //
delimiter ;
show triggers;

select * from loan_status;
select * from loan_cibil_score_status_details;
insert into loan_status select * from loan_status_2;

delete from loan_status where loan_amount = "loan still processing" or cibil_score <= 0;
alter table loan_status modify loan_amount int;

create table customer_interest_analysis select c.*,l.loan_amount,l.loan_amount_term,l.cibil_score,(l.loan_amount * c.interest)/100 as monthly_interest, (l.loan_amount * c.interest)*12/100 as annual_interest
from customer_income_status c inner join loan_status L on c.loan_id = l.loan_id;  

desc customer_interest_analysis;
alter table customer_interest_analysis modify monthly_interest decimal(10,2);
alter table customer_interest_analysis modify annual_interest decimal(10,2);
select * from customer_interest_analysis;

-- Sheet 3

alter table customer_det rename column `customer ID` to customer_id;

update customer_det set gender = case
when customer_id = "IP43006" then "Female"
when customer_id = "IP43016" then "Female"
when customer_id = "IP43018" then "Male"
when customer_id = "IP43038" then "Male"
when customer_id = "IP43508" then "Female"
when customer_id = "IP43577" then "Female"
when customer_id = "IP43589" then "Female"
when customer_id = "IP43593" then "Female"
else gender
end,
age = case
when customer_id = "IP43007" then 45
when customer_id = "IP43009" then 32
else age
end;

-- Sheet 4 and 5
alter table country_state rename column `load id` to loan_id;
select * from country_state;


-- output 1
delimiter //
create procedure get_all_data()
begin
	select c.*,d.customer_name,d.gender,d.age,d.married,d.education,d.self_employed,s.postal_code,s.segment,s.state,l.cibil_score_status,r.*
	from customer_interest_analysis c left join customer_det d on c.loan_id = d.loan_id 
	left join loan_cibil_score_status_details l on d.loan_id = l.loan_id
	left join country_state s on l.loan_id = s.loan_id left join region_info r on s.region_id = r.region_id; 
end //
delimiter ;
call get_all_data();

-- output 2
delimiter //
create procedure mismatch_det()
begin
	SELECT c.*, s.postal_code, s.segment, s.state, r.region 
    FROM region_info r 
    LEFT JOIN customer_det c ON r.region_id = c.region_id 
    LEFT JOIN country_state s ON c.region_id = s.region_id  -- Fix: Match s.region_id with c.region_id
    WHERE c.region_id IS NULL; 
end //
delimiter ;

call mismatch_det();
drop procedure mismatch_det;

-- output 3
delimiter //
create procedure high_cibil_score()
begin 
	select c.*,l.cibil_score_status from customer_interest_analysis c inner join loan_cibil_score_status_details l on 
    c.loan_id = l.loan_id where l.cibil_score_status = "High cibil score";
end //
delimiter ;
call high_cibil_score();

delimiter //
create procedure home_office_corporate()
begin 
	select c.*,s.customer_name,s.region_id,s.postal_code,s.segment,s.state 
    from customer_interest_analysis c inner join country_state s
    on c.loan_id = s.loan_id where segment in ("home office","corporate");
end //
delimiter ;
call home_office_corporate();