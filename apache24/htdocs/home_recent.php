<?php
$con=mysqli_connect("localhost","root","1234","mall");




header('content-type: text/html; charset=utf-8');



$query = "select detail.detail_idx, price, std, d_name, name,cname from detail,product,detail_img,category where product.category_idx = category.category_idx 
and detail.product_idx = product.product_idx and detail.detail_idx = detail_img.detail_idx and name like '%main%' and detail.detail_idx in 
(select max(detail_idx) from detail,product where detail.product_idx = product.product_idx group by category_idx) order by product.category_idx;";



	
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