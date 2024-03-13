<?php
$con=mysqli_connect("localhost","root","1234","mall");




header('content-type: text/html; charset=utf-8');



$query = "select round(max(cnt)/sum(cnt)*100,2) as perc, cname ,d_name,detail_idx,price,std,name
from (select detail.detail_idx,cname,count(*) as cnt,category.category_idx,d_name,price,std,name from detail_img,buy_product,product,detail,category
 where detail.detail_idx = buy_product.detail_idx and detail_img.detail_idx = detail.detail_idx and name like '%main%' 
and product.product_idx = detail.product_idx and product.category_idx = category.category_idx  group by detail.detail_idx) as t
group by category_idx;";



	
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