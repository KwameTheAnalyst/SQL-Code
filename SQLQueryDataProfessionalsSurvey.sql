/*
This survey was condcuted by Alex and thought on his YouTube channel.
*/
------------------CLEANING SEGMENT---------------------------------

Select *
From PortfolioProject.dbo.DataProfessionalSurvey

SELECT Browser, OS, City,Country,Referrer
FROM PortfolioProject.dbo.DataProfessionalSurvey

-- Drop Empty Columns

ALTER TABLE PortfolioProject.dbo.DataProfessionalSurvey
DROP COLUMN Browser, OS, City,Country,Referrer

--- WORK ON CATEGORICAL COLUMNS
--- Split Columns into new Columns

Select Q1_Which_Title_Best_Fits_your_Current_Role, Q4_What_Industry_do_you_work_in, Q5_Favorite_Programming_Language,
Q8_If_you_were_to_look_for_a_new_job_today_what_would_be_the_most_important_thing_to_you,
Q11_Which_Country_do_you_live_in,Q13_Ethnicity
From PortfolioProject.dbo.DataProfessionalSurvey

SELECT Q1_Which_Title_Best_Fits_your_Current_Role,
PARSENAME(REPLACE(Q1_Which_Title_Best_Fits_your_Current_Role,':','.'),1) AS Titles_for_Voter_Current_Role,
PARSENAME(REPLACE(Q4_What_Industry_do_you_work_in,':','.'),1) AS Voter_Industry_of_Work,
PARSENAME(REPLACE(Q5_Favorite_Programming_Language,':','.'),1) AS Voter_Favorite_Programming_Language,
PARSENAME(REPLACE(Q8_If_you_were_to_look_for_a_new_job_today_what_would_be_the_most_important_thing_to_you,':','.'),1) AS Things_Important_to_Voter_in_New_Role,
PARSENAME(REPLACE(Q11_Which_Country_do_you_live_in,':','.'),1) AS Country_Voters_Live_in,
PARSENAME(REPLACE(Q13_Ethnicity,':','.'),1) AS Ethnicity_of_Voters
FROM PortfolioProject.dbo.DataProfessionalSurvey

--- Create new Column to accept the New data

ALTER TABLE PortfolioProject.dbo.DataProfessionalSurvey
ALTER COLUMN Titles_for_Voter_Current_Role nvarchar(100)
UPDATE PortfolioProject.dbo.DataProfessionalSurvey
SET Titles_for_Voter_Current_Role = PARSENAME(REPLACE(Q1_Which_Title_Best_Fits_your_Current_Role,':','.'),1)

ALTER TABLE PortfolioProject.dbo.DataProfessionalSurvey 
ADD Voter_Industry_of_Work nvarchar(100)
UPDATE PortfolioProject.dbo.DataProfessionalSurvey
SET Voter_Industry_of_Work = PARSENAME(REPLACE(Q4_What_Industry_do_you_work_in,':','.'),1)

ALTER TABLE PortfolioProject.dbo.DataProfessionalSurvey
ADD Voter_Favorite_Programming_Language nvarchar(100)
UPDATE PortfolioProject.dbo.DataProfessionalSurvey
SET Voter_Favorite_Programming_Language = PARSENAME(REPLACE(Q5_Favorite_Programming_Language,':','.'),1)

ALTER TABLE PortfolioProject.dbo.DataProfessionalSurvey
ALTER COLUMN Things_Important_to_Voter_in_New_Role nvarchar(150)
UPDATE PortfolioProject.dbo.DataProfessionalSurvey
SET Things_Important_to_Voter_in_New_Role = PARSENAME(REPLACE(Q8_If_you_were_to_look_for_a_new_job_today_what_would_be_the_most_important_thing_to_you,':','.'),1)

ALTER TABLE PortfolioProject.dbo.DataProfessionalSurvey
ADD Country_Voters_Live_in nvarchar(50)
UPDATE PortfolioProject.dbo.DataProfessionalSurvey
SET Country_Voters_Live_in = PARSENAME(REPLACE(Q11_Which_Country_do_you_live_in,':','.'),1)

ALTER TABLE PortfolioProject.dbo.DataProfessionalSurvey
ADD Ethnicity_of_Voters nvarchar(50)
UPDATE PortfolioProject.dbo.DataProfessionalSurvey
SET Ethnicity_of_Voters = PARSENAME(REPLACE(Q13_Ethnicity,':','.'),1)

Select Titles_for_Voter_Current_Role,Voter_Industry_of_Work,Voter_Favorite_Programming_Language,Things_Important_to_Voter_in_New_Role,
Country_Voters_Live_in,Ethnicity_of_Voters
From PortfolioProject.dbo.DataProfessionalSurvey

--- Drop Old Columns
ALTER TABLE PortfolioProject.dbo.DataProfessionalSurvey
DROP COLUMN Q1_Which_Title_Best_Fits_your_Current_Role, Q4_What_Industry_do_you_work_in, Q5_Favorite_Programming_Language,
Q8_If_you_were_to_look_for_a_new_job_today_what_would_be_the_most_important_thing_to_you,
Q11_Which_Country_do_you_live_in,Q13_Ethnicity

--- Cleaning New Data columns

Select *
From PortfolioProject.dbo.DataProfessionalSurvey
WHERE Ethnicity_of_Voters LIKE '%(%)'


Update PortfolioProject.dbo.DataProfessionalSurvey
SET Ethnicity_of_Voters =''
WHERE Ethnicity_of_Voters = 'Other (Please Specify)'

--- WORK ON NUMERICAL COLUMNS

Select Q3_Current_Yearly_Salary_in_USD,
PARSENAME(REPLACE(Q3_Current_Yearly_Salary_in_USD,'-','.'),2) Current_MinYearlySalary,
PARSENAME(REPLACE(Q3_Current_Yearly_Salary_in_USD,'-','.'),1) Current_MaxYearlySalary
From PortfolioProject.dbo.DataProfessionalSurvey

Select Q3_Current_Yearly_Salary_in_USD,PARSENAME(REPLACE(Q3_Current_Yearly_Salary_in_USD,'-','.'),2) Current_MinYearlySalary,
REPLACE(PARSENAME(REPLACE(Q3_Current_Yearly_Salary_in_USD,'-','.'),2),'k','') MinCurrentYearSalary,
PARSENAME(REPLACE(Q3_Current_Yearly_Salary_in_USD,'-','.'),1) Current_MaxYearlySalary,
REPLACE(PARSENAME(REPLACE(Q3_Current_Yearly_Salary_in_USD,'-','.'),1),'k','') MaxCurrentYearSalary,
REPLACE(PARSENAME(REPLACE(Q3_Current_Yearly_Salary_in_USD,'-','.'),1),'k','') MaxCurrentYearSalary
From PortfolioProject.dbo.DataProfessionalSurvey

SELECT REPLACE(PARSENAME(REPLACE(Q3_Current_Yearly_Salary_in_USD,'-','.'),1),'k','') MaxCurrentYearSalary,
REPLACE(REPLACE(PARSENAME(REPLACE(Q3_Current_Yearly_Salary_in_USD,'-','.'),1),'k',''),'+','') Max_CurrentYearSalary
From PortfolioProject.dbo.DataProfessionalSurvey


ALTER TABLE PortfolioProject.dbo.DataProfessionalSurvey
ADD MinCurrentYearSalary int

ALTER TABLE PortfolioProject.dbo.DataProfessionalSurvey
ADD MaxCurrentYearSalary int

SELECT MinCurrentYearSalary,MaxCurrentYearSalary
FROM PortfolioProject.dbo.DataProfessionalSurvey

UPDATE PortfolioProject.dbo.DataProfessionalSurvey
SET MinCurrentYearSalary = REPLACE(PARSENAME(REPLACE(Q3_Current_Yearly_Salary_in_USD,'-','.'),2),'k','')

UPDATE PortfolioProject.dbo.DataProfessionalSurvey
SET MaxCurrentYearSalary = REPLACE(REPLACE(PARSENAME(REPLACE(Q3_Current_Yearly_Salary_in_USD,'-','.'),1),'k',''),'+','')

Select *
From PortfolioProject.dbo.DataProfessionalSurvey
WHERE Ethnicity_of_Voters LIKE '%+%'

--- Find the Average Salary

SELECT Unique_ID,MinCurrentYearSalary
FROM PortfolioProject.dbo.DataProfessionalSurvey
WHERE Unique_ID = '62a56bc67dc029e2d66e86c0'


SELECT MinCurrentYearSalary, MaxCurrentYearSalary, (MinCurrentYearSalary + MaxCurrentYearSalary)/2 AverageCurrentYearSalary
FROM PortfolioProject.dbo.DataProfessionalSurvey

-- First update null values to 0


UPDATE PortfolioProject.dbo.DataProfessionalSurvey
SET MinCurrentYearSalary = 225
WHERE Unique_ID = '62a56bc67dc029e2d66e86c0'

UPDATE PortfolioProject.dbo.DataProfessionalSurvey
SET MinCurrentYearSalary = 225
WHERE Unique_ID = '62a56bc67dc029e2d66e86c0'

--- CREATE AND UPDATE New Column

ALTER TABLE PortfolioProject.dbo.DataProfessionalSurvey
ADD AverageCurrentYearSalary int

UPDATE PortfolioProject.dbo.DataProfessionalSurvey
SET AverageCurrentYearSalary = (MinCurrentYearSalary + MaxCurrentYearSalary)/2

--- DROP REMAINING UNUSED COLUMNS

SELECT *
FROM PortfolioProject.dbo.DataProfessionalSurvey

ALTER TABLE PortfolioProject.dbo.DataProfessionalSurvey
DROP COLUMN Q3_Current_Yearly_Salary_in_USD

-- Standardize data

Select Voter_Industry_of_Work
From PortfolioProject.dbo.DataProfessionalSurvey
Where Voter_Industry_of_Work = ' Manufacturering '

Select Voter_Industry_of_Work
From PortfolioProject.dbo.DataProfessionalSurvey
Where Voter_Industry_of_Work = 'Manufacturing'

Update PortfolioProject.dbo.DataProfessionalSurvey
Set Voter_Industry_of_Work = 'Manufacturing'
Where Voter_Industry_of_Work = ' Manufacturering '


SELECT Unique_ID
From PortfolioProject.dbo.DataProfessionalSurvey
WHERE Country_Voters_Live_in = ''

---------------- REPORT SEGMENT-------------------------------------------------------

--- Total Count of Votes

Select COUNT(Unique_ID)
From PortfolioProject.dbo.DataProfessionalSurvey

---- Average Age of Voters

Select AVG(Q10_Current_Age)
From PortfolioProject.dbo.DataProfessionalSurvey

---Age Bracket of Voters-------------------------

Alter Table PortfolioProject.dbo.DataProfessionalSurvey
Add Age_bucket nvarchar(20)

UPDATE PortfolioProject.dbo.DataProfessionalSurvey
SET Age_bucket = CASE 
                    WHEN Q10_Current_Age <= 30 THEN 'Young'
                    WHEN Q10_Current_Age < 50 THEN 'Middle Age'
                    ELSE 'Old'
                 END
FROM PortfolioProject.dbo.DataProfessionalSurvey


SELECT Age_bucket, count(Age_bucket) as Voter_Age_Bracket
FROM PortfolioProject.dbo.DataProfessionalSurvey
GROUP by Age_bucket
ORDER BY Voter_Age_Bracket

SELECT Age_bucket
, count(Age_bucket) over(partition by Age_bucket) as VoterBracket
FROM PortfolioProject.dbo.DataProfessionalSurvey
ORDER BY VoterBracket

------- Ethnic Participation

SELECT Country_Voters_Live_in, COUNT(Ethnicity_of_Voters) VotesBYCountry
From PortfolioProject.dbo.DataProfessionalSurvey
GROUP BY Country_Voters_Live_in
ORDER BY VotesBYCountry DESC

SELECT Ethnicity_of_Voters, COUNT(Ethnicity_of_Voters) AS Race_Profile
From PortfolioProject.dbo.DataProfessionalSurvey
GROUP BY Ethnicity_of_Voters
ORDER BY Race_Profile DESC

--- Highest Average Salary among Countries
SELECT Country_Voters_Live_in, COUNT(Country_Voters_Live_in) VotesBYCountry, AVG(AverageCurrentYearSalary) AverageSalary
From PortfolioProject.dbo.DataProfessionalSurvey
GROUP BY Country_Voters_Live_in
ORDER BY AverageSalary DESC

--- Countries with the highest Salary

SELECT Country_Voters_Live_in, COUNT(Country_Voters_Live_in) VotesBYCountry, AVG(MaxCurrentYearSalary) MAXSALARY, AVG(AverageCurrentYearSalary) AverageSalary
FROM PortfolioProject.dbo.DataProfessionalSurvey
GROUP BY Country_Voters_Live_in
ORDER BY AverageSalary DESC

--- Salary Target for each Country

SELECT Country_Voters_Live_in
, COUNT(Ethnicity_of_Voters) OVER (PARTITION BY Country_Voters_Live_in) AS VotesBYCountry
, AVG(MaxCurrentYearSalary) OVER (PARTITION BY Country_Voters_Live_in) AS MAXSALARY
, AVG(AverageCurrentYearSalary) OVER (PARTITION BY Country_Voters_Live_in) AS AverageSalary
--, (AverageCurrentYearSalary/AVG(AverageCurrentYearSalary)*100) OVER (PARTITION BY Country_Voters_Live_in) AS IncomeLever 
FROM PortfolioProject.dbo.DataProfessionalSurvey
--GROUP BY Country_Voters_Live_in
ORDER BY MAXSALARY DESC

--- Gender Parity

Select DISTINCT Q9_Male_Female, COUNT(Q9_Male_Female) Participant, AVG(MaxCurrentYearSalary) Individual_Salary
FROM PortfolioProject.dbo.DataProfessionalSurvey
Group by Q9_Male_Female

SELECT *
FROM PortfolioProject.dbo.DataProfessionalSurvey

--- Which Title pays the highest Average Salary

SELECT Titles_for_Voter_Current_Role, AVG(AverageCurrentYearSalary) AS Best_Paying_Title
From PortfolioProject.dbo.DataProfessionalSurvey
GROUP BY Titles_for_Voter_Current_Role
ORDER BY Best_Paying_Title DESC

--- Which Tile is earning the highest Salary Now and Where?

SELECT Country_Voters_Live_in, Titles_for_Voter_Current_Role
, AVG(AverageCurrentYearSalary) OVER(PARTITION BY Titles_for_Voter_Current_Role) AS Average_Salary
, AVG(MaxCurrentYearSalary) OVER(PARTITION BY Titles_for_Voter_Current_Role) AS Current_Salary
FROM PortfolioProject.dbo.DataProfessionalSurvey
ORDER BY Current_Salary DESC

--- Filter By Country: For the highest paying Role

SELECT Titles_for_Voter_Current_Role
, AVG(AverageCurrentYearSalary) AS Avg_Salary
FROM PortfolioProject.dbo.DataProfessionalSurvey
WHERE Country_Voters_Live_in Like '%kingdom%'
Group By Titles_for_Voter_Current_Role
ORDER BY Avg_Salary DESC

---Which industry Pay the highest?

Select Country_Voters_Live_in, Voter_Industry_of_Work, Titles_for_Voter_Current_Role
, AVG(AverageCurrentYearSalary) OVER(PARTITION BY Titles_for_Voter_Current_Role) AS Avg_Salary
--WHERE Country_Voters_Live_in Like '%kingdom%'
From PortfolioProject.dbo.DataProfessionalSurvey
ORDER BY Avg_Salary DESC

Select Voter_Industry_of_Work, AVG(MaxCurrentYearSalary) Current_Salary, AVG(AverageCurrentYearSalary) Avg_Salary
From PortfolioProject.dbo.DataProfessionalSurvey
WHERE Country_Voters_Live_in Like '%state%'
GROUP BY Voter_Industry_of_Work
ORDER by Avg_Salary DESC
