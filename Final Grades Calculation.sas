
/*Homework #4
Purpose:		Learn how to use PROC SQL to redo homework 2.
Author:			Alice (Yujia) Cai

Date: 			Oct 24th.

TO DO

1.	Please sort FINALDATA by student ID and print the observations
2.	Create a Histogram (appropriately titled and labeled) of the 
    distribution of the Final Grade for the 100 students
3.  Give students the mean, median, standard deviation, and quantiles of the final grade.
*/

*Identify the pathname with the files;
%let pathname1=/home/u61899550/SAS/;

*I included the formats at the start of the program for simplicity;
proc format;
 value Yearvalue 1 = "Freshman"
			2= "Sophmore"
			3="Junior"
			4="Senior"
			5="Senior Plus";
value Gender 1="Male" 
			 2="Female";
value Residency 1="In State" 
				2="Out of State";
value Major 1="Chemistry"
			2="Biology"
			3="Mathematics"
			4="Physics"
			5="Psychology"
			6="Other";
run;

*Read in the demographics file;
proc import datafile="&pathname1.Demographics.xlsx" out=demo dbms=xlsx replace;
run;

*Read in the Test Score file - longitudinal file;
proc import datafile="&pathname1.TestScores_original.xlsx" out=orig_score dbms=xlsx replace;
run;

*Read in the Test Score make up file;
proc import datafile="&pathname1.TestScores_makeup.xlsx" out=makeup_score dbms=xlsx replace;
run;

/*Your mission for HW#4 is to complete this same task using PROC SQL)
Note you do not have to follow the ab*/

/*Please upload 

1. your SAS program (saved as LASTNAME_FIRSTNAME_HW4) 
2. an Output file (saved as LASTNAME_FIRSTNAME_HW4_OUTPUT) including a) The final grades for the class, b) the histogram of final grades,
and three the requested stats for the final grade for the class.

to Canvas by the due date of October 24, 2022 by 11:59 PM EST)*/

*merge all of the data together;
proc sql;
	create table mergedall as
	select a.studentid, coalesce(a.testnumber, b.testnumber) as TestNumber, c.year, c.gender, c.residency, c.major, 
	case when coalesce(a.testscore, b.testscore) = . then 0 else coalesce(a.testscore, b.testscore) end as TestScore
	from orig_score as a left join makeup_score as b on a.studentid = b.studentid and a.testnumber = b.testnumber 
	full join demo as c on a.studentid = c.studentid;
quit;

*drop the lowest score of test 2,3,4;
PROC SQL;
	create table test234core as
	select studentid, sum(testscore)-min(testscore) as dropped
	from mergedall
	where testnumber in (2,3,4)
	group by studentid;
QUIT;

*calculate score with weighted percentage;
proc sql;
	create table fscore as
	select a.studentid, b.dropped*0.4/2 + a.testscore*0.3 + c.testscore * 0.3 as Fscore
	from mergedall as a, test234core as b, mergedall as c
	where a.studentid = b.studentid and a.studentid = c.studentid and a.testnumber = 1 and c.testnumber = 5;
quit;

*Calculate final score;
proc sql;
	create table adjscore as
	select a.studentid, 
	case when a.Fscore <= b.testscore then b.testscore else a.Fscore end as FinalGrade
	from fscore as a, mergedall as b
	where a.studentid = b.studentid and b.testnumber = 5;
quit;

*Calculate major difference;
proc sql;
	create table majordiff as
	select DISTINCT a.studentid, a.major, b.FinalGrade, FinalGrade - mean(FinalGrade) as MajorDiff
	from mergedall as a, adjscore as b
	where a.studentid = b.studentid
	group by major
	order by studentid;
quit;

*Calculate year difference;
proc sql;
	create table yeardiff as
	select DISTINCT a.studentid, a.Year, b.FinalGrade, FinalGrade - mean(FinalGrade) as YearDiff
	from mergedall as a, adjscore as b
	where a.studentid = b.studentid
	group by Year
	order by studentid;
quit;

*Sum all of the data into the FINALDATA;
proc sql;
	create table FINALDATA as
	select DISTINCT a.studentid, a.year format = Yearvalue., a.major format = Major., 
	b.FinalGrade label = "Final Grade" format = 10.2, 
	b.FinalGrade - mean (b.FinalGrade) as ClassDiff format = 10.2,
	b.YearDiff format = 10.2,
	c.MajorDiff format = 10.2
	from mergedall as a, yeardiff as b, majordiff as c
	where a.studentid = b.studentid and a.studentid = b.studentid 
	and a.studentid = c.studentid;
quit;

*Calculate all the stats (approximate quantiles using range divided by 4);
proc sql;
	create table Stats as
	select mean(FinalGrade) as Mean, 
	median(FinalGrade) as Median, 
	std(FinalGrade) as Standard_Deviation,
	min(FinalGrade) + (max(FinalGrade)-min(FinalGrade))/4 as Percentile_25,
	min(FinalGrade) + (max(FinalGrade)-min(FinalGrade))/2 as Percentile_50,
	max(FinalGrade) - (max(FinalGrade)-min(FinalGrade))/4 as Percentile_75
	from FINALDATA;
quit;

*print out results into PDF file;

ods pdf file="&pathname1.Cai_Alice_HW4_OUTPUT";

*Print out dataset;
title "Grades for the Science Course";
proc sql;
	select *
	from FINALDATA;
quit;

*Histogram for the final grade;
title "Final Grade distribution for the Science Course";
proc sgplot data=FINALDATA;
 histogram FinalGrade;
run;

*Statistics for the class;
title "Mean, Median, Standard Deviation, and Quantiles of Grades for the Science Course";
proc sql;
	select Mean format = 10.2, Median format = 10.2, 
	Standard_Deviation format = 10.2,
	Percentile_25 format = 10.2,
	Percentile_50 format = 10.2,
	Percentile_75 format = 10.2
	from Stats;
quit;

ods pdf close;






	

