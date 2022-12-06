
libname autol 'C:\SAS\Config\Lev1\AppData\SASVisualAnalytics\VisualAnalyticsAdministrator\AutoLoad';

%MACRO importFTPfiles (currentfile=);

filename p1_t ftp "&currentfile" cd='~/docker/data/output/lijster/'
   user='sas' 
   pass=sas 
   host='baspi.localdomain'
   recfm=v
   TERMSTR=LF
   PASSIVE  
   debug ; 




data work.currentfile (drop= opcode state period weekday time);   

   infile p1_t dsd dlm=',' firstobs=2
/*obs=3     */
MISSOVER
lrecl=32767  
;

   informat electricity_low electricity_low_usage  power power_max
      electricity_normal electricity_normal_usage gas gas_usage 13.6;
   format Period date E8601DZ25.3 time time5.
      electricity_low electricity_low_usage   power power_max
      electricity_normal electricity_normal_usage gas gas_usage 13.6 thermostaat temperatuur 5.1;
   
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
      if '21:10't <= time <= '23:59't then thermostaat=15; 
   end;
   else if weekday in (2,3,4,5,6) then 
   do;
      if '00:00't <= time <  '07:00't then thermostaat=15;   else
      if '07:00't <= time <  '08:00't then thermostaat=18.5; else
      if '08:00't <= time <  '19:30't then thermostaat=19;   else
      if '19:30't <= time <  '21:10't then thermostaat=20;   else
      if '21:10't <= time <= '23:59't then thermostaat=15; 
   end;
   else if weekday =7 then 
   do;
      if '00:00't <= time <  '07:30't then thermostaat=15;   else
      if '07:30't <= time <  '08:00't then thermostaat=18.5; else
      if '08:00't <= time <  '19:30't then thermostaat=19;   else
      if '19:30't <= time <  '21:10't then thermostaat=20;   else
      if '21:10't <= time <= '23:59:59't then thermostaat=15; 
   end;
run;

PROC APPEND base=autol.p1_t  data=currentfile FORCE;
RUN;
%MEND importFTPfiles;


/* GET THE FTP DIRECTORY LISTING */
filename dirlist ftp '' ls     CD='~/docker/data/output/lijster/' 
                 HOST='baspi.localdomain'
                 USER='sas'
                 PASS='sas'
   recfm=v
   TERMSTR=LF
   PASSIVE  
   debug ;
/* Pull listing of files, filtered and run through macro */
data dirlist;
  infile dirlist length=reclen;
  input fname $varying200. reclen;
  if upcase(fname)=: 'P1_T'; 
/* execute macro while sending each file name sequentially to the macro */
  call execute('%importFTPfiles(currentfile='||fname||')');
run;
options mprint macrogen symbogen source source2 mprintnest;
%include "C:\SAS\Config\Lev1\SASApp\SASEnvironment\SASCode\Jobs\load_p1_t_to_autoload.sas";