<?php

$redis = new Redis();
   $redis->connect('db-redis', 6379);
   echo "Connection to server successfully";
         //查看服务是否运行
   echo "Server is running: " . $redis->ping();
