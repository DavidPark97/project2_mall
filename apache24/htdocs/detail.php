<?php
$con=mysqli_connect("localhost","root","1234","mall");
$detail = $_POST['detail'];



header('content-type: text/html; charset=utf-8');

$query = "select cname,d_name,price,std,p_name,content from category,product,detail where category.category_idx = product.category_idx and product.product_idx =
detail.product_idx and detail_idx = $detail";

$query2 = "select name from detail_img where detail_idx = $detail order by detail_idx;";

	
if(mysqli_connect_error($con))
echo "Failied to connect : " .mysqli_connect_error();

$result=mysqli_query($con, $query);
$rowCnt= mysqli_num_rows($result);
$arr= array();

for($i=0;$i<$rowCnt;$i++){
      $row= mysqli_fetch_array($result, MYSQLI_ASSOC);
        $arr[$i]= $row;      
}

$result2=mysqli_query($con, $query2);
$rowCnt2= mysqli_num_rows($result2);
$arr2= array();

for($i=0;$i<$rowCnt2;$i++){
      $row= mysqli_fetch_array($result2, MYSQLI_ASSOC);
        $arr2[$i]= $row;      
}


  $jsonData=json_encode(array("webnautes"=>$arr,"imgs"=>$arr2), JSON_PRETTY_PRINT+JSON_UNESCAPED_UNICODE);
  echo "$jsonData";

mysqli_close($con);
?>