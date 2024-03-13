<?php
$con=mysqli_connect("localhost","root","1234","mall");
$user = $_POST['user'];



header('content-type: text/html; charset=utf-8');



$query = "select d_name, detail.detail_idx, std,price,cnt,chk,name,cart_idx from detail,detail_img,cart where detail.detail_idx = detail_img.detail_idx 
and cart.detail_idx = detail.detail_idx and user_idx = $user and name like '%main%' order by cart_idx asc;";

	
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