/*
Author: Alice Cai
Macro name: finaltest
Purpose: DETERMINE WHICH OF THE TWO TESTS (FISHER VERSUS CHISQUARE) 
IS APPROPRIATE and THEN EITHER RUN FISHER'S EXACT OR CHI SQUARE TEST OF 
ASSOCIATION

Required Parameters: library, dataset, 
row variable(treatment), column variable(outcome)

Creation Date:  December 12 , 2022

Optional Parameters:   NA
Sub-macros called: 	NA
Example:  %finaltest(library =work, dataN = question1, rowv = treat, columnv = outcome1)
*/


*load dataset;
proc format library=work.exam;
 value yesno 1="Yes"
             0="No";
run;

option fmtsearch=(work.exam);


data question1;
 input studyid treat outcome1 outcome2;
 format treat outcome1 outcome2 yesno.;
 datalines;
 1  0 1 1
 2  0 1 0
 3  0 1 1 
 4  1 1 0
 5  0 0 1
 6  1 0 0
 7  1 0 0
 8  1 0 1
 9  1 1 0
 10  1 1 1
 11  0 1 1
 12  0 1 0
 13  0 0 1
 14  0 0 0
 15  1 0 0
 16  0 0 1
 17  0 1 0
 18  1 1 0
 19  0 1 1
 20  0 1 0
 21  0 0 1
 22  0 0 0 
 23  0 0 0
 24  1 0 1
 25  0 1 0

 ;
run;

*macro;
%macro finaltest(library =,dataN=, rowv=,columnv =);
*firstly count number of levels in the row variable;
proc freq data = &library..&dataN nlevels noprint;
tables &rowv / out= useful ;
run;

*save count into N;
proc sql;
create table count1 as
select count(&rowv) as N from useful;
quit;

data _NULL_;
 set count1;
 call symputx('N', N);
 run;

*count number of levels in the column variable;
proc freq data = &library..&dataN nlevels noprint;
tables &columnv / out= useful2 ;
run;

*save count into N2;
proc sql;
create table count2 as
select count(&columnv) as N1 from useful2;
quit;

data _NULL_;
 set count2;
 call symputx('N1', N1);
 run;

*see the expected value in the table;
proc freq data = &library..&dataN nlevels NOPRINT;
tables &rowv * &columnv / out= useful3 ;
run;

*save the minimum value into fishc;
proc sql noprint;
select min(count) into : fishc
from useful3;
quit;
 
*if 2 by 2 and smallest value is less than or equal to 5, do fisher test;
*otherwise, do chisquare test;
%if &N =2 and &N1 = 2 and &fishc <= 5 %then %do;
title 'Test of Association using Fisher test';
proc freq data=&library..&dataN;
 table &rowv * &columnv /fisher; 
run;
%end;

%else %do;
title 'Test of Association using Chi-square test';
proc freq data=&library..&dataN;
 table &rowv * &columnv/chisq; 
run;
%end;
%mend finaltest;

%finaltest(library =work, dataN = question1, rowv = treat, columnv = outcome1)
%finaltest(library =work, dataN = question1, rowv = treat, columnv = outcome2)
