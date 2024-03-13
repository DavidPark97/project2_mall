<?php
$con=mysqli_connect("localhost","root","1234","mall");
$user = $_POST['user'];



header('content-type: text/html; charset=utf-8');



$query = "select sum(cnt*price) as total,id,phone,address from user,detail,buy,buy_product where user.user_idx = buy.user_idx 
and detail.detail_idx = buy_product.detail_idx and buy.buy_idx = buy_product.buy_idx and user.user_idx=$user;";

	
if(mysqli_connect_error($con))
echo "Failied to connect : " .mysqli_connect_error();

$result=mysqli_query($con, $query);
$rowCnt= mysqli_num_rows($result);
$arr= array();

for($i=0;$i<$rowCnt;$i++){
      $row= mysqli_fetch_array($result, MYSQLI_ASSOC);
        $arr[$i]= $row;      
}


  $jsonData=json_encode(array("webnautes"=>$arr), JSON_PRETTY_PRINT+JSON_UNESCAPED_UNICODE);
  echo "$jsonData";

mysqli_close($con);
?>