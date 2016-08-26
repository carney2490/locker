<?php  
$db = pg_connect("
    host: "lockerroom.c4iif5msrrmw.us-west-2.rds.amazonaws.com",
   port:'5432',
   dbname:'lockerroom',
   user:ENV['user'],
   password:ENV['password');  
$query = "INSERT INTO mailing_list VALUES ('$_POST[email]')";  
$result = pg_query($query);   
?> 