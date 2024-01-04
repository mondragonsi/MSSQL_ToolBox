/*
# Creating new DB, Table and Populating it
*/

create database IA_DB;
go

use IA_DB;
go

drop table cancer_img;
go

create table cancer_img(
    id int primary key IDENTITY(1,1),
    radius int not null,
    texture int not null,
    diagnosis varchar (15)
)

--populate table cancer_img table

insert into cancer_img
VALUES
(14,23,'malignant'),
(15,28,'malignant'),
(9,21,'benign');
go

select * from cancer_img;
go

--populate the cancer_img with 100 more rows

INSERT INTO cancer_img VALUES (15, 28, 'malignant');
INSERT INTO cancer_img VALUES (9,  21,   'benign');
INSERT INTO cancer_img VALUES (17, 27, 'benign');
INSERT INTO cancer_img VALUES (10, 20, 'benign');
INSERT INTO cancer_img VALUES (17, 30, 'malignant');
