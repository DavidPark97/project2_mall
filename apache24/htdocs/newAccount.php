<?php
$con=mysqli_connect("localhost","root","1234","mall");


$id = $_POST['id'];
$passwd = $_POST['passwd'];
$phone = $_POST['phone'];
$address = $_POST['address'];



header('content-type: text/html; charset=utf-8');
$query = "insert into user (user_idx,id,passwd,phone,address) values ((select user_idx from (select ifnull((select max(user_idx)+1 from user),1)as user_idx)as a),'$id','$passwd','$phone','$address');";



	
if(mysqli_connect_error($con))
echo "Failied to connect : " .mysqli_connect_error();

$result=mysqli_query($con, $query);

mysqli_close($con);
?>