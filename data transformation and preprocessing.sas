DATA dads;
 INPUT famid name $  dadinc ;
DATALINES;
2 Art  22000
1 Bill 30000
3 Paul 25000
;
RUN;

DATA moms;
 INPUT famid name $  mominc ;
DATALINES;
1 Bess 15000
3 Pat  50000
2 Amy  18000
;
RUN;


DATA faminc;
   INPUT famid faminc1-faminc12 ;
CARDS;
1 3281 3413 3114 2500 2700 3500 3114 3319 3514 1282 2434 2818
2 4042 3084 3108 3150 3800 3100 1531 2914 3819 4124 4274 4471
3 6015 6123 6113 6100 6100 6200 6186 6132 3123 4231 6039 6215
;
RUN;


data momdad;
 set dads(in=dad) moms(in=mom);
 if dad=1 then momdad="dad";
 if mom=1 then momdad="mom";
run;

data momdad2;
	set dads(in=dad) moms(in=mom);
	if dad=1 then do;
		momdad="dad";
		inc=datainc;
	end;
	if mom=1 then do;
		momdad="mom";
		inc=mominc;
	end;
run;

data momdad3;
	set dads(rename=(dadinc=inc) in=a) moms(rename=(mominc=inc) in=b);
	if a=1 then momdad="dad";
	if b=1 then momdad="mom";
run;


/*wide vs long nomenclature*/

proc sort data=moms;
by famid;
run;

proc sort data=dads;
by famid;
run;

data merged (drop=name);
merge dads(rename=(name=dadname)) moms(rename=(name=momname));
by famid;
faminc=mominc+dadinc;
run;

/*tax calculation*/

data faminc_tex;
 set faminc;
 array a_faminc(12) faminc1-faminc12;
 array a_taxinc(12) taxinc1-taxinc12;
 array a_qtrinc(4) qtrinc1-qtrinc4;

 do i=1 to 12;
 	a_taxinc(i) = a_faminc(i)*0.1;
 end;

do qtr = 1 to 4;
	month3 =  3*qtr;
	a_qtrinc(qtr) = a_faminc(month3-2) + a_faminc(month3-1) + a_faminc(month3);
 end;
run;

/*look up cross sectional panel data*/



proc transpose data=faminc_tex out=faminc_transpose prefix=faminc;
by famid;
var faminc1-faminc12;
run;
/*
var-> identifying the information that is going wide to long or vice versa.
id-> identifies the variable that we can use to create new variable
prefix identifies the rename variable while suffix to the prefix becomes a new categorical variable.


*/

proc transpose data=faminc_tex out=taxinc_transpose prefix=taxinc;
by famid;
var taxinc1-taxinc12;
run;

proc sort data=faminc_transpose;
by _name_;
run;


proc sort data=taxinc_transpose;
by _name_;
run;

data transfaminc;
merge faminc_transpose taxinc_transpose;
by _NAME_;
run;

data faminc_transpose_dataway (keep=famid month faminc taxinc);
	set work.faminc_tex;

	array a_faminc(12) faminc1-faminc12;
	array a_taxinc(12) taxinc1-taxinc12;

	do i = 1 to 12;
		month = i;
		faminc = a_faminc(i);
		taxinc = a_taxinc(i);
	output;
	end;
run;

proc tabulate data=faminc_transpose_dataway;
	var taxinc;
	class famid;
	table famid,sum*(taxinc)*(format=dollar20.);
run;

