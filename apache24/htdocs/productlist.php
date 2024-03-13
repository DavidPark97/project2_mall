<?php
$con=mysqli_connect("localhost","root","1234","mall");
$user = $_POST['user'];

header('content-type: text/html; charset=utf-8');

$query = "select p_name,product.product_idx from product,cart,detail 
where product.product_idx = detail.product_idx and cart.detail_idx = detail.detail_idx and user_idx=$user
 group by product.product_idx;";

	
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