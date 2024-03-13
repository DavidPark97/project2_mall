<?php
$con=mysqli_connect("localhost","root","1234","mall");
$user = $_POST['user'];
$year = $_POST['year'];
$category = $_POST['category'];


header('content-type: text/html; charset=utf-8');

if(strcmp($category,"0")==1){
$query = "select month(date) as mon ,sum(price*cnt) as price from buy,buy_product,detail,product where buy.buy_idx = buy_product.buy_idx 
and buy_product.detail_idx = detail.detail_idx and detail.product_idx = product.product_idx and user_idx =$user and year(date)=$year and category_idx = $category 
group by year(date), month(date) order by month(date) asc;";
}else{
  $query = "select month(date) as mon ,sum(price*cnt) as price from buy,buy_product,detail,product where buy.buy_idx = buy_product.buy_idx 
  and buy_product.detail_idx = detail.detail_idx and detail.product_idx = product.product_idx and user_idx =$user and year(date)=$year  
  group by year(date), month(date) order by month(date) asc;";
}

	
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