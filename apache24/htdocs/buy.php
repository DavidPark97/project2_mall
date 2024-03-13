<?php
$con=mysqli_connect("localhost","root","1234","mall");


$user = $_POST['user'];

$date = date("Y-m-d");
header('content-type: text/html; charset=utf-8');

if(mysqli_connect_error($con))
echo "Failied to connect : " .mysqli_connect_error();

$result1 = mysqli_query($con, "select ifnull(max(buy_idx)+1,1) as buy_idx from buy;");
$buy = mysqli_fetch_array($result1);
$buy_idx = $buy['buy_idx'];
$res = mysqli_query($con,"insert into buy (buy_idx,user_idx,date) values ($buy_idx,$user,'$date')");

$result=mysqli_query($con, "select * from cart where user_idx=$user and chk=1");
$rowCnt= mysqli_num_rows($result);

for($i=0;$i<$rowCnt;$i++){
      $res= mysqli_fetch_array($result, MYSQLI_ASSOC);
      
      $detail = $res['detail_idx'];
      $cnt = $res['cnt'];
     
      $query = "insert into buy_product(detail_idx,buy_idx,cnt) values ($detail,$buy_idx,$cnt)";
      mysqli_query($con,$query);
}
mysqli_query($con,"delete from cart where user_idx=$user and chk=1;");

mysqli_close($con);
?>