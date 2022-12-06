filename myfile sftp  
'/home/sas/docker/Dockerfile' host="baspi.localdomain"
debug;



FILENAME myfile SFTP '/home/sas/docker/Dockerfile' 

host='baspi.localdomain' 
user='sas' 
options="-i 'C:\files\ssh\baspi.ppk' -v" 
debug
WAIT_MILLISECONDS=30000;




filename outfile
      sftp 'delete_me_test_andrew.txt'
      cd ='/upload'
      host="transfer2.silverpop.com"
      user="bmorse@us.ci.org"
      optionsx='-pw "secret"'   ;


data _null_;
   infile myfile truncover;
   input a $25.;
run;



filename  p1_t  SFTP   'p1_t_recover.csv'  
            host="baspi.localdomain"
            wait_milliseconds=5000
            CD= "docker/data/output/lijster/"
              user="sas"
            options= "-v" debug
            optionsx="-i C:\files\.ssh\baspi8.ppk -v" 
            ;

libname autol 'C:\SAS\Config\Lev1\AppData\SASVisualAnalytics\VisualAnalyticsAdministrator\AutoLoad';



data test;
   set autol.p1_t_copy(where=(date^=.));

   file p1_t dsd dlm=',' lrecl=32767;
/*   file log;*/

period  = TZONES2U(date-315619200);

if _N_ = 1 then put
'sensor_id,period,temperatuur,power,power_max,electricity_low,electricity_low_usage,electricity_normal,electricity_normal_usage,tariff,gas,gas_usage';
else put 'I,N, ' sensor_id  + (-1)  ','  period+ (-1)  ',' temperatuur + (-1)  ',' power + (-1)  ','  power_max + (-1)  ',' 
   electricity_low + (-1)  ','  electricity_low_usage + (-1)  ','  electricity_normal + (-1)  ','  electricity_normal_usage + (-1)  ','  
   tariff + (-1)  ','  gas + (-1)  ','  gas_usage;
  
run;

/**/


