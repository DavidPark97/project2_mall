<?php
$con=mysqli_connect("localhost","root","1234","mall");
$category = $_POST['category'];
$word = $_POST['word'];
$product = $_POST['product'];



header('content-type: text/html; charset=utf-8');


if(strlen($word)!=0){
$query = "select detail.detail_idx, price, std, d_name, name from detail,product,detail_img where
detail.product_idx = product.product_idx and detail.detail_idx = detail_img.detail_idx and d_name like '%$word%' 
group by detail_img.detail_idx order by product.category_idx;";
}elseif(strlen($product)!=0){
  $query=  "select detail.detail_idx, price, std, d_name, name from detail,product,detail_img where
    detail.product_idx = product.product_idx and detail.detail_idx = detail_img.detail_idx and detail.product_idx = $product 
    group by detail_img.detail_idx order by product.category_idx;";
}elseif(strcmp($category,"0")==0){
    $query = "select detail.detail_idx, price, std, d_name, name from detail,product,detail_img where
    detail.product_idx = product.product_idx and detail.detail_idx = detail_img.detail_idx  
    group by detail_img.detail_idx order by product.category_idx;";    
}else{
    $query = "select detail.detail_idx, price, std, d_name, name from detail,product,detail_img where
    detail.product_idx = product.product_idx and detail.detail_idx = detail_img.detail_idx and category_idx = $category 
    group by detail_img.detail_idx order by product.category_idx;";    
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