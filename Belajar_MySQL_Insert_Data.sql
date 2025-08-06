show tables;
create table barang (kode int, nama varchar(100), harga int, jumlah int)
engine = innoDB;
show tables;
describe barang;
show create table barang;

alter table barang
add column info text;

alter table barang
add column padam text;

alter table barang
drop column padam;

alter table barang 
modify nama varchar(200) after info;

alter table barang
modify nama varchar(200) first;

alter table barang
rename column kode to id;

alter table barang
modify id int not null,
modify nama varchar(200) not null;

alter table barang
modify nama varchar(200) not null,
modify id int not null,
modify harga int not null default 0,
modify jumlah int not null default 0,
add column masa timestamp not null default current_timestamp;

insert into barang (id, nama) values (1, 'Apel');

select*from barang;

truncate barang; #buang semua data dalam table

show tables;

drop table barang; #buang semua table dalam belajar_mysql



#table table baru untuk next session
create table Product
(
ID varchar(10) not null,
Name varchar(100) not null,
Description text,
Price int unsigned not null,
Quantity int unsigned not null default 0,
Create_at timestamp not null default current_timestamp
) engine innoDB;

show tables;
describe Product;
 
insert into Product (ID, Name, Price, Quantity)
values ('A0001', 'Potassium Cloride', 22000, 100);

insert into Product (ID, Name, Price, Quantity, Description)
values ('A0002', 'Rock Phosphate', 11000, 120, 'Raw Material for Phosphate Fertilizer');

insert into Product (ID, Name, Price, Quantity)
values ('A0003', 'Chlorine', 23000, 150),
('A0004', 'Flourine', 22200, 50),
('A0005', 'Aluminium', 21500, 300),
('A0006', 'Plutonium', 30000, 5),
('A0007', 'Vibranium', 500000, 3),
('A0008', 'Polimer', 24500, 200),
('A0009', 'Hydrogen', 30000, 320),
('A0010', 'Quartz', 36000, 510),
('A0011', 'Carbon', 55000, 600),
('A0012', 'Neon', 32000, 180),
('A0013', 'Titanium', 55500, 180),
('A0014', 'Bromine', 32000, 120),
('A0015', 'Morphine', 10200, 25);

select*from Product;

select Name, Price, Quantity from Product;

alter table Product
add primary key (ID);

describe Product;
show create table Product;

select*from Product where Quantity = 200;
select*from Product where Price = 10200;

alter table Product
add column Category enum('Metal', 'Non-Metal', 'Others')
after Name;
select*from Product;

update Product
set Category = 'Others',
Description = 'Raw Material'
where ID = 'A0010';
select*from Product;

insert into Product (ID, Name, Price, Quantity)
values ('A0016', 'Contoh_Padam', 2025, 1206);
delete from Product
where ID = 'A0016';

select ID as kode,
Name as Nama,
Category as Kategori,
Description as Info,
Price as Harga, 
Quantity as Kuantiti,
Create_at as Masa
from Product;

select ID as kode,
p.Name as Nama,
p.Category as Kategori,
p.Description as Info,
p.Price as Harga, 
p.Quantity as Kuantiti,
p.Create_at as Masa
from Product as p;

select ID, Name, Price from Product
where Quantity > 10;

select * from Product where Category != 'Metal';

select * from Product where Category = 'Metal' and Quantity > 50;

select * from Product where Category = 'Metal' or Quantity > 50;

select * from Product where (Category = 'Metal' or Quantity > 50) and Price > 30000;

select * from Product where Name like '%um';

select * from Product where Price between 20000 and 50000;
select * from Product where Price not between 20000 and 50000;

select * from Product where Category in ('Metal', 'Non-Metal');
select * from Product where Category not in ('Metal', 'Non-Metal');

select * from Product order by Category asc;
select * from Product order by Category asc, Price desc;

select * from Product order by ID limit 5;
select * from Product order by ID limit 5, 5;

select distinct Category from Product order by Category asc;

select ID, Name, Price, Price div 1000 as 'Price in k' from Product;
select 10 as 'n1', 10 as 'n2', 10*10 as hasil;
select ID, cos(Price), sin(Price), tan(Price) from Product;
select ID, Name, Price, Price div 1000 as 'Price in k' from product where Price div 1000 > 20;

#-----------------------------------------------------------------------------------------------------------------------------------------------------------
Create table Admin
( 
ID int  not null auto_increment,
First_Name varchar(100) not null,
Last_Name varchar(100) not null, 
primary key (ID)
) engine InnoDB;

show tables;
describe Admin;
select* from Admin;

alter table Admin
add column Team enum('BSAA', 'Umbrella', 'STARS' )
after Last_Name;
select*from Admin;

insert into Admin (First_Name, Last_Name, Team)
Values ('Leon', 'Kennedy', 'STARS'),
('Claire', 'Redfields', 'BSAA'),
('Chris', 'Redfields', 'BSAA'),  
('Jill', 'Valentine', 'BSAA'),
('Richard', 'Aiken', 'STARS'),
('Albert', 'Wesker', 'Umbrella');

select * from Admin order by ID;

delete from Admin where ID=6; 

insert into Admin (First_Name, Last_Name, Team)
Values ('William', 'Birkin', 'Umbrella');

select last_insert_id();

select ID, Lower(First_Name) as 'Name Lower Case', Upper(First_Name) as 'Name Upper Case', length(First_Name) as 'Length'
from Admin;

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------

select ID from Product;

select ID, Create_at,
time(Create_at) as Time,
extract(year from Create_at) as Year,
extract(month from Create_at) as Month
from Product;

select ID, Create_at, Time(Create_at), Year(Create_at), Month(Create_at) from Product;

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select ID, Team,
case Team when 'BSAA' then 'Old_Protagonist'
when 'STARS' then 'New_Protagonist'
else 'Antagonit'
end as 'Main_Role'
from Admin;

select * from product;
select ID, Name, Price,
if(Price <= 20000, 'Normal', if( Price <= 30000, 'High', 'Out_of_Budget')) as Budget
from Product order by Price desc;

insert into Product (ID, Name, Price, Quantity)
values ('A0016', 'Argentum', 25000, 300);
update Product
set Category = 'Metal'
where ID = 'A0016';
select*from Product;

select ID, Name, Price, ifnull(Description, 'Error') as Description from Product order by Description;