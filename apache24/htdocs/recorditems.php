<?php
$con=mysqli_connect("localhost","root","1234","mall");
$user = $_POST['user'];



header('content-type: text/html; charset=utf-8');



$query = "select date,sum(price*cnt) as price, buy.buy_idx from buy,buy_product,detail where buy.buy_idx = buy_product.buy_idx 
and buy_product.detail_idx = detail.detail_idx and user_idx =$user group by buy_product. buy_idx order by buy.buy_idx desc;";

	
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