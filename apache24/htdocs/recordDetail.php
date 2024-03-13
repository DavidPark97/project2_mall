<?php
$con=mysqli_connect("localhost","root","1234","mall");
$buy = $_POST['buy'];



header('content-type: text/html; charset=utf-8');



$query = "select d_name, name,price,std,cnt from buy_product,detail,detail_img 
where buy_product.detail_idx = detail.detail_idx and detail.detail_idx = detail_img.detail_idx 
and buy_idx = $buy and name like '%main%';";

	
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