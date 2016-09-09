<?php  
$db = pg_connect("
    host: ENV['db'],
   port:ENV['port'],
   dbname:ENV['dbname'],
   user:ENV['user'],
   password:ENV['password');  
$query = "INSERT INTO mailing_list VALUES ('$_POST[email]')";  
$result = pg_query($query);   
?> 
