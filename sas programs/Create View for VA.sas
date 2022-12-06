libname autol 'C:\SAS\Config\Lev1\AppData\SASVisualAnalytics\VisualAnalyticsAdministrator\AutoLoad';

filename p1_t ftp 'p1_t.csv' cd='~/docker/data/output/lijster/'
   user='sas' 
   pass=sas 
   host='baspi.localdomain'
   recfm=v
   TERMSTR=LF
   PASSIVE  
   debug ; 

/*filename p1_elec 'C:\temp\elec_data.csv';*/
proc delete data=autol.p1_t (memtype=view);
run;
data autol.p1_t (drop= opcode state period   )
/* Create a view */
/ view=autol.p1_t 
;   

   infile p1_t dsd dlm=',' firstobs=2
/*obs=3     */
MISSOVER
lrecl=32767  
;

informat electricity_low electricity_low_usage
    electricity_normal electricity_normal_usage gas gas_usage 13.6;
   format Period date E8601DZ25.3
    electricity_low electricity_low_usage
    electricity_normal electricity_normal_usage gas gas_usage 13.6 thermostaat 5.1;
   
   input 
   opcode $ state $ sensor_id period temperatuur power power_max
   electricity_low electricity_low_usage electricity_normal electricity_normal_usage tariff gas gas_usage;
   date=TZONEU2S(Period+315619200);
   weekday = Weekday(Datepart(date));
   time= Timepart(date);
   if weekday = 1  then 
   do;
      if '00:00't <= time <  '08:00't then thermostaat=15;   else
/*      if '08:00't <= time <  '08:00't then thermostaat=18.5; else*/
      if '08:00't <= time <  '19:30't then thermostaat=19;   else
      if '19:30't <= time <  '21:10't then thermostaat=20;   else
      if '21:10't <= time <= '23:59't then thermostaat=18.5; 
   end;
   else if weekday in (2,3,4,5,6) then 
   do;
      if '00:00't <= time <  '07:00't then thermostaat=15;   else
      if '07:00't <= time <  '08:00't then thermostaat=18.5; else
      if '08:00't <= time <  '19:30't then thermostaat=19;   else
      if '19:30't <= time <  '21:10't then thermostaat=20;   else
      if '21:10't <= time <= '23:59't then thermostaat=18.5; 
   end;
   else if weekday =7 then 
   do;
      if '00:00't <= time <  '07:30't then thermostaat=15;   else
      if '07:30't <= time <  '08:00't then thermostaat=18.5; else
      if '08:00't <= time <  '19:30't then thermostaat=19;   else
      if '19:30't <= time <  '21:10't then thermostaat=20;   else
      if '21:10't <= time <= '23:59:59't then thermostaat=18.5; 
   end;
run;

DATA view=autol.p1_t; describe; run;


proc print data=autol.p1_t;     /* Print the data */
run;
DATA view=autol.p1_t; describe; run;   

libname autol 'C:\SAS\Config\Lev1\AppData\SASVisualAnalytics\VisualAnalyticsAdministrator\AutoLoad';
DATA view=autol.slimmemeter; describe; run;

DATA view_name / view=view_name;
X=1; Y=1;
Run;
/*When creating a data step view, the name and the view name must be the same. */
/*Also if you use a data step to create a view, it is possible to view the code */
/*used to create a SAS view: */
DATA view=view_name; describe; run;   

ods listing;
 ods listing close;
   ods results off;
   ods output members=bb; 


 PROC DATASETS LIBRARY=work MEMTYPE=(data view) nowarn;
   quit;