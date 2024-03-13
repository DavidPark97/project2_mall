<?php
$con=mysqli_connect("localhost","root","1234","mall");


$cart = $_POST['cart'];
$chk = $_POST['chk'];


header('content-type: text/html; charset=utf-8');
$query = "update cart set chk=$chk where cart_idx=$cart";


	
if(mysqli_connect_error($con))
echo "Failied to connect : " .mysqli_connect_error();

$result=mysqli_query($con, $query);

mysqli_close($con);
?>