--creating database--
create database NewHope

---Ensuring Minimum Disk Utilization---
alter database NewHope
Modify file
(
Name ='NewHope',
Maxsize =1000MB
)

alter database NewHope
Modify file
(
Name='NewHope_log',
Maxsize=1000MB
) 

---create schema-
create schema facilities
create schema HumanResources
create schema patients
create schema Management

 ----creating Ward  Table--
create table facilities.Ward
(
Ward_ID int primary key identity(100,1),
WardName char(50) check(WardName in ('OPD', 'ICU', 'CCU','Spl_Ward', 'General_Ward','Emergency')),
Total_Beds int ,
Ward_Charge varchar (200),
Avail_Beds int,
)
alter table facilities.ward add Ward_Charge money
update facilities.Ward 
set Ward_Charge=3000 where Ward_ID=104
insert into facilities.Ward
values('OPD','80','','40'),
      ('ICU','100','','50'),
	  ('CCU','60','','30'),
	  ('Spl_Ward','90','','79'),
	  ('General_Ward','80','','40')
SELECT * FROM facilities.Ward
---display number of bed and doctors in each ward--
create view DOCX 
with schemabinding 
as
select a.Ward_ID,a.Doctor_ID,b.Avail_Beds from HumanResources.Doctordetails a join facilities.Ward b on a.Ward_ID = b.Ward_ID
create unique clustered index DOCXXX on DOCX(Avail_Beds,Doctor_ID)
SELECT * FROM DOCX

--creating table Doctordetails---
Create table HumanResources.Doctordetails
(
Doctor_ID int primary key identity(400,1),
FirstName char(50) not null,
LastName char(50) not null,
Address  varchar(100) not null,
Phone_Num varchar(100) check(Phone_Num like('[0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9]')),
Employment_Type char(50) check(Employment_Type in ('Resident','Visiting')),
Ward_ID int foreign key references facilities.Ward(Ward_ID),
Specialization varchar (50)
)

--5--
Create view vDoctordetails
as
Select d.Doctor_ID, d.FirstName, d.LastName, d.Address, d.Phone_Num, 
d.Employment_Type, d.Ward_ID, d.Specialization , p.admin_Date 
from HumanResources.Doctordetails d join patients.PatientDetail p
on d.Doctor_ID = p.Doctor_ID

Select * from vDoctordetails
where DATEPART(mm, getdate()) = Datepart(mm, Admin_Date)

insert into HumanResources.Doctordetails
values ('Charles','Dwyane','6,Washinghton Mile','01-198-9981-999-018','Resident','100','Neurology'),
       ('Jackson','Susan','4,Otedola street','01-233-3433-233-293','Visiting','101','Gynecology'),
       ('Water','Bright','112,Awoloway way ikeja','09-444-3435-909-887','Resident','102','Cardiology'),
       ('James','Brown','55,Tovvix way Swizz','09-012-3837-939-337','Resident','103','Gastroenterology'),
       ('Kunta','Sage','9,sunset avenue','09-382-9928-928-292','Visiting','104','Nephrology')
select * from HumanResources.Doctordetails

---creating taable PatientDetail---
create table patients.PatientDetail
(
Patient_ID int primary key identity(700,1),
FirstName char(50) not  null,
LastName char(50) not null,
Address varchar (70) not null,
Age int,
Height float,
Weight int,
Blood_Grp char(20) check (Blood_Grp in ('A','B','AB','O')),
Admin_Date datetime check (Admin_Date>=getdate()),
Discharge_Date datetime check(Discharge_Date>=getdate()),
Treatment_Type varchar(50),
Doctor_ID int foreign key references HumanResources.Doctordetails(Doctor_ID),
Ward_ID int foreign key references facilities.Ward(Ward_ID),
Phone_Num varchar(50) check (Phone_Num like ('[0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9]')),
Total_Days_Spent int
)
		
insert into patients.PatientDetail(FirstName,LastName,Address,Age,Height,Weight,Blood_Grp,Admin_Date,Discharge_Date,Treatment_Type,Doctor_ID,Ward_ID,Phone_Num)
values('yomi','gold','10,Bode Thomas street Mushin','70','50','60','A','03-29-2020','05-17-2020','Heart Attack','401','100','09-676-9842-989-096'),
('sale','jack','9,Balogun street','66','6.1','58','AB','03-29-2020','03-31-2020','Kidney Cancer','402','101','09-222-2822-987-212'),
('Fola','Jacob','5,snake island way','55','5.1','67','O','03-29-2020','04-2-2020','Infertility','403','102','01-222-3343-345-456'),
('Peru','Johnson','2 Aso House Road','56','5.3','44','AB','03-29-2020','05-3-2020','Brain Cancer','404','103','00-254-2343-111-772'),
('Bella','cake','4 beach road','22','5.5','50','O','03-29-2020','05-5-2020','Breast Canacer','405','104','02-292-2333-234-567') 
SELECT * FROM patients.PatientDetail
--creating trigger for Total Days--
Create Trigger Daysxx
on Patients.PatientDetail
For Insert as
			Declare @Admin_Date datetime
			Declare @Discharge_Date datetime
			Declare @Total_Days_Spent int
			Select @Admin_Date = Admin_Date from inserted
			Select @Discharge_Date = Discharge_Date from inserted
			Select @Total_Days_Spent = Total_Days_Spent from inserted

			If @Discharge_Date > @Admin_Date
				Begin
					Update patients.PatientDetail
					Set Total_Days_Spent = datediff(dd,Admin_Date,Discharge_Date)
				end
				
select* from patients.PatientDetail

---Creating index---
create index patientxxx on patients.PatientDetail (Admin_Date,Discharge_Date)

---creating MedicalHistory table--
create Table patients.MedicalHistory
(
Record_ID int primary key identity(100,1),
Patient_ID int foreign key references patients.PatientDetail(Patient_ID),
Doctor_ID int foreign key references HumanResources.DoctorDetails,
Disease char(50)
)
insert into patients.MedicalHistory
values('711','401','Breast Cancer'),
      ('712','402','Infertility'),
	  ('713','403','Heart Attack'),
	  ('714','404','Brain Cancer'),
	  ('715','405','Kidney Cancer')
select * from patients.MedicalHistory

---creating Management table---
Create table Management.Payments
(
Payment_ID int primary key identity(200,1),
Patient_ID int foreign key references patients.PatientDetail(Patient_ID),
PaymentDate datetime check (PaymentDate >= getdate()),
PaymentMethod char(50) check (PaymentMethod in ('Cash', 'Check', 'Credit_CarD')),
CC_Num int,
CardHoldersName char(50),
Check_Num int,
AdvancePayment int,
FinalPayment int,
PaymentStatus char(50) DEFAULT 'PENDING', check(PaymentStatus in ('Paid','Pending')),
Total_Bill money
)
ALTER TABLE Management.Payments ALTER COLUMN CC_NUM VARCHAR(50)
CREATE VIEW Patients.CHECKOUT
WITH SCHEMABINDING 
AS
Select
A.PATIENT_ID,A.WARD_ID,C.Payment_ID, A.TOTAL_DAYS_SPENT,B.WARD_CHARGE,C.ADVANCEPAYMENT,C.FINALPAYMENT,C.TOTAL_BILL,A.Discharge_Date
 FROM patients.PatientDetail A JOIN
facilities.Ward B ON A.WARD_ID=B.WARD_ID join 
Management.Payments C ON A.Patient_ID = C.Patient_ID

Alter Schema Patients Transfer dbo.Checkout
SELECT * FROM patients.CHECKOUT

SELECT * FROM Management.Payments
--JOB FOR TOTAL BILL--
UPDATE patients.CHECKOUT
SET
Total_Bill= Ward_Charge * Total_Days_Spent
WHERE
DATEPART(MM,GETDATE())>= DATEPART(MM,Discharge_Date)
---JOB FOR FINAL PAYMENT--
UPDATE Management.Payments
SET
FinalPayment= Total_Bill - AdvancePayment
--- JOB FOR PAYMENT STORED DETAIL FOR EACH MONTH(6PAYMENT)--
Select * from Management.Payments
where DATEPART(mm, getdate()) = Datepart(mm, PaymentDate)

ALTER TABLE Management.Payments
alter COLUMN CC_NUM VARCHAR (100)
insert into Management.Payments(Patient_ID, PaymentDate, PaymentMethod, AdvancePayment)
values('711','04-30-2020','Cash','5000'),
	  ('714','04-19-2020','Cash','1000')
insert into Management.Payments(Patient_ID, PaymentDate, PaymentMethod, CC_Num, CardHoldersName, AdvancePayment)
values('712','04-25-2020','Credit_CarD','0398283829','sale jack','9000'),
	  ('713','04-16-2020','Credit_CarD','0017283265','yemmi silver','4000')
insert into Management.Payments(Patient_ID, PaymentDate, PaymentMethod, Check_Num, AdvancePayment)
values('715','04-18-2020','Check','34567892','3000')

	  select * from Management.Payments
--creating trigger on paymentStatus--
create trigger PaymentStatus on Management.Payments
for insert as
     declare @PaymentStatus char(50) 
	 declare @AdvancePayment int
	 select @PaymentStatus = PaymentStatus from inserted
	 select @AdvancePayment = AdvancePayment from inserted
	 begin
	 update Management.Payments
	 set PaymentStatus = 'Paid'
	 where AdvancePayment > 0
	 end

	

--creating trigger for bil
Create Trigger bill
on Management.Payments
for insert
as
			Declare @Totalbill money
			Declare @WardCharge money
			Declare @TotalDays int
			Declare @Discharge_Date date
			Select @Totalbill = Total_bill from inserted
			Select @WardCharge = Ward_Charge from facilities.Ward
			Select @TotalDays = Total_Days_Spent from patients.PatientDetail
			Select @Discharge_Date = Discharge_Date from patients.PatientDetail
			Begin
			    Update Management.Payments 
				Set Total_bill = (Select Total_Days_Spent from patients.PatientDetail) * (Select Ward_Charge from facilities.Ward)
				where GETDATE() = (Select Discharge_Date from patients.PatientDetail) 
			End
	--- NOT NEEDED, ALREADY IN JOBS ---		
---creating trigger for fianlpayment---
create trigger F on Management.Payments
for insert as
     declare @FinalPayment int
     declare @Totalbill money
	 declare @AdvancePayment int
	 select @Totalbill = Total_Bill from inserted
	 select @AdvancePayment = AdvancePayment from inserted
	 select @FinalPayment = FinalPayment from inserted
	 begin
	 update Management.Payments
	 set FinalPayment = Total_Bill - AdvancePayment
	 end
-- NO NEEDED,ALREDY IN JOBS--

---creating trigger to check the Credit Card payment if its null--	 
create trigger CC_Num
 on Management.Payments
FOR INSERT AS
DECLARE @PaymentMethod char(50)
DECLARE @Payment_ID int
select @PaymentMethod = PaymentMethod from inserted 
select @Payment_ID = Payment_ID from inserted 
if @PaymentMethod!= 'Credit_CarD'
begin
update Management.Payments
set CC_Num = null, CardHoldersName = null
end

---creating trigger to check the cheque payment if its null--
create trigger cheque
on Management.Payments
for insert as
declare @PaymentMethod char (50)
declare @Payment_ID int
select @PaymentMethod = PaymentMethod from inserted 
select @Payment_ID =  Payment_ID from inserted 
if @PaymentMethod! = 'Check'
begin
update Management.Payments
set Check_Num = null 
end

---creating index--
create index Epayment on Management.Payments (PaymentStatus)
select* from Management.Payments
 

 ---creating logins--
 create login James
 with password = 'james444'
 go
 create user james for login james

 create login Bryan
 with password = 'Bryan333'
 go
 create user bryan for LOGIN bryan
 go
 
 create login Maria
 with password = 'Maria243'
 go
create user maria for LOGIN maria
go

CREATE LOGIN John
WITH PASSWORD = 'jj224'
GO
CREATE USER john for LOGIN john
GO

---CREATING SERVER ROLE--
CREATE SERVER ROLE DATABASE_ADMIN
AUTHORIZATION JAMES

CREATE SERVER ROLE DATABASE_DEVELOPER
AUTHORIZATION BRYAN

CREATE SERVER ROLE DATASE_DEVELOPER
AUTHORIZATION JOHN

--Encryption--
CREATE  MASTER KEY ENCRYPTION 
BY PASSWORD = 'HOPEHOPE'
GO
CREATE CERTIFICATE NEWHOPE
WITH SUBJECT = 'DATA ENCRYPTION'
GO
CREATE SYMMETRIC KEY HOPEHOSPITAL
WITH ALGORITHM = AES_128
ENCRYPTION BY CERTIFICATE NEWHOPE
GO
ALTER TABLE MANAGEMENT.PAYMENTS
ADD ENCRYPTEDCC_NUM VARBINARY(MAX)
GO
ALTER TABLE MANAGEMENT.PAYMENTS
ADD ENCRYPTEDCARDHOLDERSNAME VARBINARY(MAX)
GO

UPDATE Management.Payments
SET [ENCRYPTEDCC_Num] = ENCRYPTBYKEY (KEY_GUID('HOPEHOSPITAL'),CC_Num)
GO
UPDATE Management.Payments
SET [ENCRYPTEDCARDHOLDERSNAME] = ENCRYPTBYKEY (KEY_GUID('HOPEHOSPITAL'),CARDHOLDERSNAME)
GO
SELECT * FROM Management.Payments
OPEN SYMMETRIC KEY HOPEHOSPITAL
DECRYPTION BY CERTIFICATE NEWHOPE
GO
CLOSE SYMMETRIC KEY HOPEHOSPITAL
GO
alter table Management.Payments 
drop column CC_NUM
alter table Management.Payments 
drop column CardHoldersName


BACKUP DATABASE NEWHOPE
TO DISK = 'C:\NEWHOPE BACK UP\Newhopebak'
   WITH FORMAT,MEDIANAME
 = 'SQLServerBackups',
      NAME = 'Full Backup of SQLTestDB'
GO



