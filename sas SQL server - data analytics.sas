
data auto2new;
  set auto2;
  Manufacturer=scan(make,1,' ');
  CarModel=scan(make,2,' ');
  Avg_Price=mean(price);
run;

proc summary data=auto2new;
	class Manufacturer;
	output out=auto2summary1
		mean(price) = Average_Price;
run;

proc print data=auto2new (keep=Manufacturer Avg_Price);
by mean(Avg_Price);
run;

proc sql;
create table manpricetes 
as select make, price, car_ratio, (car_ratio/mean(price)*100) as CRPercentage from auto3
group by Manufacturer
having count(Manufacturer) >= 3;
quit;

proc sql;
create table manprice
as select Manufacturer, mean(price) from auto3
group by Manufacturer
having count(Manufacturer) >= 3;
quit;


proc sort data=auto2new;
by Manufacturer;
run;
proc sort data=work.manprice (rename=(_TEMG001=AvgManPrice));
by Manufacturer;
run;

data auto4;
merge auto2new work.manprice;
if cmiss(of _all_) then delete;
car_ratio = (price/AvgManPrice);
meanprice = mean(price);
by Manufacturer;
run;

proc sort data=auto4 (keep=Manufacturer car_ratio AvgManPrice make price);
by car_ratio;
run;


proc means data=auto3 (keep=price);

run;
proc sql;
create table manprice1
as select Manufacturer, AvgManPrice, car_ratio from auto3
group by Manufacturer
having count(Manufacturer) >=3 ;
run;
quit;


proc freq data=auto3;
tables Manufacturer*car_ratio/out=test nocol norow nopercent;
run;

proc boxplot data=auto2new;
plot price*manufacturer;
run;


proc boxplot data=auto2new;
plot mpg*manufacturer;
run;

proc reg data=auto2;
model mpg = price rep78 hdroom trunk weight length turn displ gratio foreign / selection=backward;
plot R.*P.;
output out=curvelinear P=pred R=resid;
run;


proc reg data=auto2;
model mpg = weight length / selection=backward details=all;
plot R.*mpg;
run;


proc reg data=auto2;
model mpg = rep78 length gratio foreign;
run;



proc sgplot data=auto2;
scatter x=weight y=mpg;
run;

proc sgplot data=auto2;
scatter x=length y=mpg;
run;

proc univariate data=auto2 (keep=price mpg);
run;

proc surveyselect data = auto2 method = SRS rep = 1 
  sampsize = 10 seed = 1 out = auto_sample; /*SRS = simple random sampling, rep=1 only creates one table, samplesize is the size of the sample, random seed allows your sampling to be replicated*/
  id _all_;
run;

proc print data = auto_sample noobs;
run;

data auto_curv;
set auto2new;
length


proc reg data=auto2new;
length2 = length**2;
weight2 = weight**2;
model mpg= length weight length2 weight2;
run;