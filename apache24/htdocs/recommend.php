<?php
$con=mysqli_connect("localhost","root","1234","mall");
$keyword = $_POST['keyword'];



header('content-type: text/html; charset=utf-8');


if(strlen($keyword)==0){
  $query="select d_name from detail order by rand() limit 10;";
}else{
  $query="select d_name from detail where d_name like '%$keyword%' limit 10;";
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