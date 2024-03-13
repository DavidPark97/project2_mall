<?php
$con=mysqli_connect("localhost","root","1234","mall");


$user = $_POST['user'];
$cnt = $_POST['cnt'];
$detail = $_POST['detail'];



header('content-type: text/html; charset=utf-8');
$query = "insert into cart (user_idx,cnt,detail_idx) values ($user,$cnt,$detail) on duplicate key update cnt = cnt+$cnt;";


	
if(mysqli_connect_error($con))
echo "Failied to connect : " .mysqli_connect_error();

$result=mysqli_query($con, $query);

mysqli_close($con);
?>