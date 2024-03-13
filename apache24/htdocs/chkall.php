<?php
$con=mysqli_connect("localhost","root","1234","mall");


$user = $_POST['user'];
$chk = $_POST['chk'];


header('content-type: text/html; charset=utf-8');
$query = "update cart set chk=$chk where user_idx=$user";


	
if(mysqli_connect_error($con))
echo "Failied to connect : " .mysqli_connect_error();

$result=mysqli_query($con, $query);

mysqli_close($con);
?>