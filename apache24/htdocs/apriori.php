<?php


$selected = $_POST['selected'];
set_time_limit(300);
//파이썬 실행
$command = escapeshellcmd("apriori.py $selected");
$output = shell_exec($command);
$result = iconv('euc-kr', 'UTF-8', $output);

$jsonData=json_encode($result, JSON_PRETTY_PRINT+JSON_UNESCAPED_UNICODE);
echo $result;

?>