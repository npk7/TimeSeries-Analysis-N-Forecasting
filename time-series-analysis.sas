/*

Analysis of Border-Crossing Time series data to identify trends and patterns in Time Series

Using real world border crossing data from Buffalo Bridges

several stages of data cleansing, data transformations

Interactive data visualization included

(c) Pavan Kumar Narayanan, 2014


*/


libname bcross 'C:\Users\narayap01\Downloads';

proc contents data=bcross._all_;
run;

data border;
	set bcross.border;
run;

data border2;
	set work.border;

	time_str = substr(peacebridge_time,20,8);
	format time time7.;
	time = input(time_str,time7.);

	month = month(system_time);
	day = day(system_time);
	year = year(system_time);

	format system_date date9.;
	system_date = mdy(month,day,year);

	hour = hour(time);
	minute = minute(time);
	second = second(time);

	format sas_dhms datetime17.;
	sas_dhms = dhms(system_date,hour(time),minute(time),second(time));

	hour_wait = .;
	if substr(usa_auto_peace,2,2)="hr" then hour_wait = 1;
	else hour_wait = 0;

	pb_auto_us = .;
	if usa_auto_peace = "No Delay" then pb_auto_us = 0;
	else if hour_wait = 0 then pb_auto_us = substr(usa_auto_peace,1,2)*1;
	else if hour_wait = 1 then pb_auto_us = substr(usa_auto_peace,1,1)*60 + substr(usa_auto_peace,5,2)*1;

run;

proc univariate;
	var pb_auto_us;
	histogram pb_auto_us;
run;

proc sgplot;
	series x = sas_dhms y=pb_auto_us;
run;

/* Preprocessing and time series analysis and modeling */


/*removing all the records containing missing values*/

data temp;
	set border2;
 if cmiss(of _all_) then delete; 
run;

/*removing duplicate records*/

proc sort data=temp out=border_nodup nodupkey ;
by sas_dhms;
run;

/*plotting histogram after initial data cleansing*/

proc univariate data=border_nodup;
	var pb_auto_us;
	histogram pb_auto_us;
run;

/*preparing data for time series analysis expermentation*/

data tsmodel;
	set border_nodup (keep=sas_dhms pb_auto_us);
run;
ods graphics on;

/*plotting basic time series model*/

proc timeseries data=tsmodel plot=series;
	var pb_auto_us;
run;

/*arima model experimentation*/

proc arima data=tsmodel;
   identify var=pb_auto_us;
   estimate p=0 q=2;
   forecast id=sas_dhms printall out=b;
run;

data border3;
set border2;
if USA_Auto_Peace = "No Delay" then USA_Auto_Peace = "2 min";
run;


/*looking at state space models inorder to compensate for unequal indexes */

proc statespace data=tsmodel out=ssout;
var pb_auto_us;
run;
data border2a (keep=sas_dhms month day year hour minute second time system_date pb_auto_us qb_auto_us pb_truck_us 
			qb_truck_us pb_nexus_us qb_nexus_us pb_auto_ca qb_auto_ca pb_truck_ca qb_truck_ca pb_nexus_ca qb_nexus_ca);
	set work.border;

	time_str = substr(peacebridge_time,20,8);
	format time time7.;
	time = input(time_str,time7.);

	month = month(system_time);
	day = day(system_time);
	year = year(system_time);

	format system_date date9.;
	system_date = mdy(month,day,year);

	hour = hour(time);
	minute = minute(time);
	second = second(time);

	format sas_dhms datetime17.;
	sas_dhms = dhms(system_date,hour(time),minute(time),second(time));

	hour_waitu1 = .;
	if substr(usa_auto_peace,2,2)="hr" then hour_waitu1 = 1;
	else hour_waitu1 = 0;

	hour_waitu2 = .;
	if substr(usa_auto_queen,2,2)="hr" then hour_waitu2= 1;
	else hour_waitu2 = 0;

	hour_waitu3 = .;
	if substr(usa_truck_peace,2,2)="hr" then hour_waitu3 = 1;
	else hour_waitu3 = 0;

	hour_waitu4 = .;
	if substr(usa_truck_queen,2,2)="hr" then hour_waitu4 = 1;
	else hour_waitu4 = 0;

	hour_waitu5 = .;
	if substr(usa_nexus_peace,2,2)="hr" then hour_waitu5 = 1;
	else hour_waitu5 = 0;

	hour_waitu6 = .;
	if substr(usa_nexus_queen,2,2)="hr" then hour_waitu6= 1;
	else hour_waitu6 = 0;

	pb_auto_us = .;
	if usa_auto_peace = "No Delay" then pb_auto_us = 0;
	else if hour_waitu1 = 0 then pb_auto_us = substr(usa_auto_peace,1,2)*1;
	else if hour_waitu1 = 1 then pb_auto_us = substr(usa_auto_peace,1,1)*60 + substr(usa_auto_peace,5,2)*1;

	qb_auto_us = .;
	if usa_auto_queen = "No Delay" then qb_auto_us = 0;
	else if hour_waitu2 = 0 then qb_auto_us = substr(usa_auto_queen,1,2)*1;
	else if hour_waitu2 = 1 then qb_auto_us = substr(usa_auto_queen,1,1)*60 + substr(usa_auto_queen,5,2)*1;

	pb_truck_us = .;
	if usa_truck_peace = "No Delay" then pb_truck_us = 0;
	else if hour_waitu3 = 0 then pb_truck_us = substr(usa_truck_peace,1,2)*1;
	else if hour_waitu3 = 1 then pb_truck_us = substr(usa_truck_peace,1,1)*60 + substr(usa_truck_peace,5,2)*1;

	qb_truck_us = .;
	if usa_truck_queen = "No Delay" then qb_truck_us = 0;
	else if hour_waitu4 = 0 then qb_truck_us = substr(usa_truck_queen,1,2)*1;
	else if hour_waitu4 = 1 then qb_truck_us = substr(usa_truck_queen,1,1)*60 + substr(usa_truck_queen,5,2)*1;

	pb_nexus_us = .;
	if usa_nexus_peace = "No Delay" then pb_nexus_us = 0;
	else if hour_waitu5 = 0 then pb_nexus_us = substr(usa_nexus_peace,1,2)*1;
	else if hour_waitu5 = 1 then pb_nexus_us = substr(usa_nexus_peace,1,1)*60 + substr(usa_nexus_peace,5,2)*1;

	qb_nexus_us = .;
	if usa_nexus_queen = "No Delay" then qb_nexus_us = 0;
	else if hour_waitu6 = 0 then qb_nexus_us = substr(usa_nexus_queen,1,2)*1;
	else if hour_waitu6 = 1 then qb_nexus_us = substr(usa_nexus_queen,1,1)*60 + substr(usa_nexus_queen,5,2)*1;

	if missing(pb_auto_us) then pb_auto_us=0;
	if missing(qb_auto_us) then qb_auto_us=0;
	if missing(pb_truck_us) then pb_truck_us=0;
	if missing(qb_truck_us) then qb_truck_us=0;
	if missing(pb_nexus_us) then pb_nexus_us=0;
	if missing(qb_nexus_us) then qb_nexus_us=0;
/*canada data*/

	hour_waitc1 = .;
	if substr(canada_auto_peace,2,2)="hr" then hour_waitc1 = 1;
	else hour_waitc1 = 0;

	hour_waitc2 = .;
	if substr(canada_auto_queen,2,2)="hr" then hour_waitc2= 1;
	else hour_waitc2 = 0;

	hour_waitc3 = .;
	if substr(canada_truck_peace,2,2)="hr" then hour_waitc3 = 1;
	else hour_waitc3 = 0;

	hour_waitc4 = .;
	if substr(canada_truck_queen,2,2)="hr" then hour_waitc4 = 1;
	else hour_waitc4 = 0;

	hour_waitc5 = .;
	if substr(canada_nexus_peace,2,2)="hr" then hour_waitc5 = 1;
	else hour_waitc5 = 0;

	hour_waitc6 = .;
	if substr(canada_nexus_queen,2,2)="hr" then hour_waitc6= 1;
	else hour_waitc6 = 0;

	pb_auto_ca = .;
	if canada_auto_peace = "No Delay" then pb_auto_ca = 0;
	else if hour_waitc1 = 0 then pb_auto_ca = substr(canada_auto_peace,1,2)*1;
	else if hour_waitc1 = 1 then pb_auto_ca = substr(canada_auto_peace,1,1)*60 + substr(canada_auto_peace,5,2)*1;

	qb_auto_ca = .;
	if canada_auto_queen = "No Delay" then qb_auto_ca = 0;
	else if hour_waitc2 = 0 then qb_auto_ca = substr(canada_auto_queen,1,2)*1;
	else if hour_waitc2 = 1 then qb_auto_ca = substr(canada_auto_queen,1,1)*60 + substr(canada_auto_queen,5,2)*1;

	pb_truck_ca = .;
	if canada_truck_peace = "No Delay" then pb_truck_ca = 0;
	else if hour_waitc3 = 0 then pb_truck_ca = substr(canada_truck_peace,1,2)*1;
	else if hour_waitc3 = 1 then pb_truck_ca = substr(canada_truck_peace,1,1)*60 + substr(canada_truck_peace,5,2)*1;

	qb_truck_ca = .;
	if canada_truck_queen = "No Delay" then qb_truck_ca = 0;
	else if hour_waitc4 = 0 then qb_truck_ca = substr(canada_truck_queen,1,2)*1;
	else if hour_waitc4 = 1 then qb_truck_ca = substr(canada_truck_queen,1,1)*60 + substr(canada_truck_queen,5,2)*1;

	pb_nexus_ca = .;
	if canada_nexus_peace = "No Delay" then pb_nexus_ca = 0;
	else if hour_waitc5 = 0 then pb_nexus_ca = substr(canada_nexus_peace,1,2)*1;
	else if hour_waitc5 = 1 then pb_nexus_ca = substr(canada_nexus_peace,1,1)*60 + substr(canada_nexus_peace,5,2)*1;

	qb_nexus_ca = .;
	if canada_nexus_queen = "No Delay" then qb_nexus_ca = 0;
	else if hour_waitc6 = 0 then qb_nexus_ca = substr(canada_nexus_queen,1,2)*1;
	else if hour_waitc6 = 1 then qb_nexus_ca = substr(canada_nexus_queen,1,1)*60 + substr(canada_nexus_queen,5,2)*1;

	if missing(pb_auto_ca) then pb_auto_ca=0;
	if missing(qb_auto_ca) then qb_auto_ca=0;
	if missing(pb_truck_ca) then pb_truck_ca=0;
	if missing(qb_truck_ca) then qb_truck_ca=0;
	if missing(pb_nexus_ca) then pb_nexus_ca=0;
	if missing(qb_nexus_ca) then qb_nexus_ca=0;
run;


run;

data border2a;
set border2a;
	x = weekday(system_date);
run;

/*on a given day comparing the various traffic*/
proc gplot data=bcross.borderd1 (where=(hour>=9));
plot (pb_auto_us qb_auto_us pb_truck_us qb_truck_us)*sas_dhms/overlay;
symbol1 LINE=1 I=join c=bipb v=none;
symbol2 LINE=1 I=join c=bigy v=none;
symbol3 LINE=1 I=join c=black v=none;
symbol4 LINE=1 I=join c=big v=none;
symbol5 LINE=1 I=join c=bio v=none;
symbol6 LINE=1 I=join c=bippk v=dot;
run;	

proc sgplot data=bcross.borderd1 aspect=0.5;
series x=sas_dhms y=pb_auto_us;
series x=sas_dhms y=qb_auto_us;
series x=sas_dhms y=pb_truck_us;
series x=sas_dhms y=qb_truck_us;
run;

data border2;
set border2;
x=weekday(system_date);
run;

data weekends;
set border2;
where x=1 and 2;
run;

proc sgplot data=border2a (where=(x=1));
title "Sunday";
series x=time y=pb_auto_us;
run;
/* Data for US Auto at PeacebRidge */

proc sgplot data=border2a (where=(x=1));
title "Sunday";
series x=time y=pb_auto_us;
run;
proc sgplot data=border2a (where=(x=2));
title "Monday";
series x=time y=pb_auto_us;
run;
proc sgplot data=border2a (where=(x=3));
title "Tuesday";
series x=time y=pb_auto_us;
run;
proc sgplot data=border2a (where=(x=4));
title "Wednesday";
series x=time y=pb_auto_us;
run;
proc sgplot data=border2a (where=(x=5));
title "Thursday";
series x=time y=pb_auto_us;
run;
proc sgplot data=border2a (where=(x=6));
title "Friday";
series x=time y=pb_auto_us;
run;

proc sgplot data=border2a (where=(x=7));
title "Saturday";
series x=time y=pb_auto_us;
run;
proc gplot data=bcross.borderd1;
plot qb_auto_us*sas_dhms/hminor=0 vminor=0;
symbol LINE=1 I=join c=bipb v=none;
run;

proc gplot data=bcross.borderd1;
plot pb_truck_us*sas_dhms/hminor=0 vminor=0;
symbol LINE=1 c=
run;
/*(rename=(pb_auto_us=pb_auto_us1 qb_auto_us=qb_auto_us1 pb_truck_us=pb_truck_us1 qb_truck_us=qb_truck_us1 pb_nexus_us=pb_nexus_us1 qb_nexus_us=qb_nexus_us1))*/
data sunday;
merge bcross.borderd1(keep=pb_auto_us) bcross.borderd8(drop=day month hour minute second)(rename=(pb_auto_us=pb_auto_us1));
run;

data a;
input time : time8. v;
format time time8.;
cards;
09:45 21
09:48 45
09:49 34
09:54 32
10:02 56
;
run;
proc sort data=a; by time;run;
data aa;
 merge a a(firstobs=2 rename=(time=_time));
 output;
 do t=time+60 to coalesce(_time-60,0) by 60;
  time=t;v=.;output;
 end;
drop t _time;
run;
proc expand data=aa out=bb method=spline;
      id time;
   run;


/* Peace Bridge US Truck data weekday analysis
   */


proc sgplot data=border2a (where=(x=1));
title "Sunday";
series x=time y=pb_truck_us;
run;
proc sgplot data=border2a (where=(x=2));
title "Monday";
series x=time y=pb_truck_us;
run;
proc sgplot data=border2a (where=(x=3));
title "Tuesday";
series x=time y=pb_truck_us;
run;
proc sgplot data=border2a (where=(x=4));
title "Wednesday";
series x=time y=pb_truck_us;
run;
proc sgplot data=border2a (where=(x=5));
title "Thursday";
series x=time y=pb_truck_us;
run;
proc sgplot data=border2a (where=(x=6));
title "Friday";
series x=time y=pb_truck_us;
run;
proc sgplot data=border2a (where=(x=7));
title "Saturday";
series x=time y=pb_truck_us;
run;

proc sgplot data=border2a (where=(x=1));
title "Sunday";
series x=time y=pb_nexus_us;
run;
proc sgplot data=border2a (where=(x=2));
title "Monday";
series x=time y=pb_nexus_us;
run;
proc sgplot data=border2a (where=(x=3));
title "Tuesday";
series x=time y=pb_nexus_us;
run;
proc sgplot data=border2a (where=(x=4));
title "Wednesday";
series x=time y=pb_nexus_us;
run;
proc sgplot data=border2a (where=(x=5));
title "Thursday";
series x=time y=pb_nexus_us;
run;
proc sgplot data=border2a (where=(x=6));
title "Friday";
series x=time y=pb_nexus_us;
run;
proc sgplot data=border2a (where=(x=7));
title "Saturday";
series x=time y=pb_nexus_us;
run;

proc means data=border2a;
where x=1;
run;

proc ttest data=border2a (where=(x=1)) alpha=0.01 h0=5.33;
var pb_auto_us pb_nexus_us;
run;


/*Canada Plots */

proc sgplot data=border2a (where=(x=1));
title "Sunday";
series x=time y=pb_auto_ca;
run;
proc sgplot data=border2a (where=(x=2));
title "Monday";
series x=time y=pb_auto_ca;
run;
proc sgplot data=border2a (where=(x=3));
title "Tuesday";
series x=time y=pb_auto_ca;
run;
proc sgplot data=border2a (where=(x=4));
title "Wednesday";
series x=time y=pb_auto_ca;
run;
proc sgplot data=border2a (where=(x=5));
title "Thursday";
series x=time y=pb_auto_ca;
run;
proc sgplot data=border2a (where=(x=6));
title "Friday";
series x=time y=pb_auto_ca;
run;
proc sgplot data=border2a (where=(x=7));
title "Saturday";
series x=time y=pb_auto_ca;
run;




proc sgplot data=border2a (where=(x=1));
title "Sunday";
series x=time y=pb_truck_ca;
run;
proc sgplot data=border2a (where=(x=2));
title "Monday";
series x=time y=pb_truck_ca;
run;
proc sgplot data=border2a (where=(x=3));
title "Tuesday";
series x=time y=pb_truck_ca;
run;
proc sgplot data=border2a (where=(x=4));
title "Wednesday";
series x=time y=pb_truck_ca;
run;
proc sgplot data=border2a (where=(x=5));
title "Thursday";
series x=time y=pb_truck_ca;
run;
proc sgplot data=border2a (where=(x=6));
title "Friday";
series x=time y=pb_truck_ca;
run;
proc sgplot data=border2a (where=(x=7));
title "Saturday";
series x=time y=pb_truck_ca;
run;

proc sgplot data=border2a (where=(x=1));
title "Sunday";
series x=time y=pb_nexus_ca;
run;
proc sgplot data=border2a (where=(x=2));
title "Monday";
series x=time y=pb_nexus_ca;
run;
proc sgplot data=border2a (where=(x=3));
title "Tuesday";
series x=time y=pb_nexus_ca;
run;
proc sgplot data=border2a (where=(x=4));
title "Wednesday";
series x=time y=pb_nexus_ca;
run;
proc sgplot data=border2a (where=(x=5));
title "Thursday";
series x=time y=pb_nexus_ca;
run;
proc sgplot data=border2a (where=(x=6));
title "Friday";
series x=time y=pb_nexus_ca;
run;
proc sgplot data=border2a (where=(x=7));
title "Saturday";
series x=time y=pb_nexus_ca;
run;

proc sgplot data=border2a (where=(x=1));
title "Sunday";
series x=time y=qb_truck_us;
run;
proc sgplot data=border2a (where=(x=2));
title "Monday";
series x=time y=qb_truck_us;
run;
proc sgplot data=border2a (where=(x=3));
title "Tuesday";
series x=time y=qb_truck_us;
run;
proc sgplot data=border2a (where=(x=4));
title "Wednesday";
series x=time y=qb_truck_us;
run;
proc sgplot data=border2a (where=(x=5));
title "Thursday";
series x=time y=qb_truck_us;
run;
proc sgplot data=border2a (where=(x=6));
title "Friday";
series x=time y=qb_truck_us;
run;
proc sgplot data=border2a (where=(x=7));
title "Saturday";
series x=time y=qb_truck_us;
run;


proc sgplot data=border2a (where=(x=1));
title "Sunday";
series x=time y=qb_auto_us;
run;
proc sgplot data=border2a (where=(x=2));
title "Monday";
series x=time y=qb_auto_us;
run;
proc sgplot data=border2a (where=(x=3));
title "Tuesday";
series x=time y=qb_auto_us;
run;
proc sgplot data=border2a (where=(x=4));
title "Wednesday";
series x=time y=qb_auto_us;
run;
proc sgplot data=border2a (where=(x=5));
title "Thursday";
series x=time y=qb_auto_us;
run;
proc sgplot data=border2a (where=(x=6));
title "Friday";
series x=time y=qb_auto_us;
run;
proc sgplot data=border2a (where=(x=7));
title "Saturday";
series x=time y=qb_auto_us;
run;

proc sgplot data=border2a (where=(x=1));
title "Sunday";
series x=time y=qb_nexus_us;
run;
proc sgplot data=border2a (where=(x=2));
title "Monday";
series x=time y=qb_nexus_us;
run;
proc sgplot data=border2a (where=(x=3));
title "Tuesday";
series x=time y=qb_nexus_us;
run;
proc sgplot data=border2a (where=(x=4));
title "Wednesday";
series x=time y=qb_nexus_us;
run;
proc sgplot data=border2a (where=(x=5));
title "Thursday";
series x=time y=qb_nexus_us;
run;
proc sgplot data=border2a (where=(x=6));
title "Friday";
series x=time y=qb_nexus_us;
run;
proc sgplot data=border2a (where=(x=7));
title "Saturday";
series x=time y=qb_nexus_us;
run;



proc sgplot data=border2a (where=(x=1));
title "Sunday";
series x=time y=qb_truck_ca;
run;
proc sgplot data=border2a (where=(x=2));
title "Monday";
series x=time y=qb_truck_ca;
run;
proc sgplot data=border2a (where=(x=3));
title "Tuesday";
series x=time y=qb_truck_ca;
run;
proc sgplot data=border2a (where=(x=4));
title "Wednesday";
series x=time y=qb_truck_ca;
run;
proc sgplot data=border2a (where=(x=5));
title "Thursday";
series x=time y=qb_truck_ca;
run;
proc sgplot data=border2a (where=(x=6));
title "Friday";
series x=time y=qb_truck_ca;
run;
proc sgplot data=border2a (where=(x=7));
title "Saturday";
series x=time y=qb_truck_ca;
run;


proc sgplot data=border2a (where=(x=1));
title "Sunday";
series x=time y=qb_auto_ca;
run;
proc sgplot data=border2a (where=(x=2));
title "Monday";
series x=time y=qb_auto_ca;
run;
proc sgplot data=border2a (where=(x=3));
title "Tuesday";
series x=time y=qb_auto_ca;
run;
proc sgplot data=border2a (where=(x=4));
title "Wednesday";
series x=time y=qb_auto_ca;
run;
proc sgplot data=border2a (where=(x=5));
title "Thursday";
series x=time y=qb_auto_ca;
run;
proc sgplot data=border2a (where=(x=6));
title "Friday";
series x=time y=qb_auto_ca;
run;
proc sgplot data=border2a (where=(x=7));
title "Saturday";
series x=time y=qb_auto_ca;
run;

proc sgplot data=border2a (where=(x=1));
title "Sunday";
series x=time y=qb_nexus_ca;
run;
proc sgplot data=border2a (where=(x=2));
title "Monday";
series x=time y=qb_nexus_ca;
run;
proc sgplot data=border2a (where=(x=3));
title "Tuesday";
series x=time y=qb_nexus_ca;
run;
proc sgplot data=border2a (where=(x=4));
title "Wednesday";
series x=time y=qb_nexus_ca;
run;
proc sgplot data=border2a (where=(x=5));
title "Thursday";
series x=time y=qb_nexus_ca;
run;
proc sgplot data=border2a (where=(x=6));
title "Friday";
series x=time y=qb_nexus_ca;
run;
proc sgplot data=border2a (where=(x=7));
title "Saturday";
series x=time y=qb_nexus_ca;
run;


proc means data=border2a;
var pb_auto_us qb_auto_ca pb_auto_ca qb_auto_us;
run;

proc ttest data=border2a (where=(x=1 and 6)) alpha=0.01 h0=5.33;
var pb_auto_us pb_nexus_us;
run;

proc sort data=border2a out=border3 nodupkey;
by sas_dhms;
run;

proc expand data = border3 out = maborder;
  convert pb_auto_us = pb_auto_us_ma / transformout=( movave 5);
  convert pb_truck_us = pb_truck_us_ma / transformout=( movave 5);
  convert pb_nexus_us = pb_nexus_us_ma / transformout=( movave 5);
  convert pb_auto_ca = pb_auto_ca_ma / transformout=( movave 5);
  convert pb_truck_ca = pb_truck_ca_ma / transformout=( movave 5);
  convert pb_nexus_ca = pb_nexus_ca_ma / transformout=( movave 5);
  convert qb_auto_us = qb_auto_us_ma / transformout=( movave 5);
  convert qb_truck_us = qb_truck_us_ma / transformout=( movave 5);
  convert qb_nexus_us = qb_nexus_us_ma / transformout=( movave 5);
  convert qb_auto_ca = qb_auto_ca_ma / transformout=( movave 5);
  convert qb_truck_ca = qb_truck_ca_ma / transformout=( movave 5);
  convert qb_nexus_ca = qb_nexus_ca_ma / transformout=( movave 5);
run;

proc expand data = border3 out=borderma1 method=none;
  convert pb_auto_us = pb_auto_us_lag / transformout=( lag 1);
  convert pb_truck_us = pb_truck_us_lag / transformout=( lag 1);
  convert pb_nexus_us = pb_nexus_us_lag / transformout=( lag 1);
  convert pb_auto_ca = pb_auto_ca_lag / transformout=( lag 1);
  convert pb_truck_ca = pb_truck_ca_lag / transformout=( lag 1);
  convert pb_nexus_ca = pb_nexus_ca_lag / transformout=( lag 1);
  convert qb_auto_us = qb_auto_us_lag / transformout=( lag 1);
  convert qb_truck_us = qb_truck_us_lag / transformout=( lag 1);
  convert qb_nexus_us = qb_nexus_us_lag / transformout=( lag 1);
  convert qb_auto_ca = qb_auto_ca_lag / transformout=( lag 1);
  convert qb_truck_ca = qb_truck_ca_lag / transformout=( lag 1);
  convert qb_nexus_ca = qb_nexus_ca_lag / transformout=( lag 1);
  convert pb_auto_us = pb_auto_us_lead / transformout=( lead 4);
  convert pb_truck_us = pb_truck_us_lead / transformout=( lead 4);
  convert pb_nexus_us = pb_nexus_us_lead / transformout=( lead 4);
  convert pb_auto_ca = pb_auto_ca_lead / transformout=( lead 4);
  convert pb_truck_ca = pb_truck_ca_lead / transformout=( lead 4);
  convert pb_nexus_ca = pb_nexus_ca_lead / transformout=( lead 4);
  convert qb_auto_us = qb_auto_us_lead / transformout=( lead 4);
  convert qb_truck_us = qb_truck_us_lead / transformout=( lead 4);
  convert qb_nexus_us = qb_nexus_us_lead / transformout=( lead 4);
  convert qb_auto_ca = qb_auto_ca_lead / transformout=( lead 4);
  convert qb_truck_ca = qb_truck_ca_lead / transformout=( lead 4);
  convert qb_nexus_ca = qb_nexus_ca_lead / transformout=( lead 4);
run;

proc expand data = border3 out=borderd1 to=minute extrapolate;
convert	pb_auto_us	=	pb_auto_us_daily;
convert	pb_truck_us	=	pb_truck_us_daily;
convert	pb_nexus_us	=	pb_nexus_us_daily;
convert	pb_auto_ca	=	pb_auto_ca_daily;
convert	pb_truck_ca	=	pb_truck_ca_daily;
convert	pb_nexus_ca	=	pb_nexus_ca_daily;
convert	qb_auto_us	=	qb_auto_us_daily;
convert	qb_truck_us	=	qb_truck_us_daily;
convert	qb_nexus_us	=	qb_nexus_us_daily;
convert	qb_auto_ca	=	qb_auto_ca_daily;
convert	qb_truck_ca	=	qb_truck_ca_daily;
convert	qb_nexus_ca	=	qb_nexus_ca_daily;
id sas_dhms;
run;
ods graphics on;
proc arima data=borderd1;
identify var=pb_auto_us_daily stationarity=(adf=1);
run;


proc arima data=borderd1 out=borderarima;
   identify var=pb_auto_us_daily stationarity=(adf);
   estimate p=0 q=2;
   forecast id=sas_dhms printall out=b;
run;

proc means data=border2a;
run;



proc print data =ma1 (obs=10);
  var date open open_lag1 open_lead4;
run;
     


proc print data = ma (obs=10);
var date open open_ma;
run;
