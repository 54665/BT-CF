# BT-CF
宝塔配合fakeipcf脚本自动提交恶意攻击IP到cf，精准屏蔽

先配置下获取用户真实IP
相关教程

宝塔面板安装LNMP存放nginx配置文件位置在：
/www/server/nginx/conf/nginx.conf

将下面段代码加入 “include proxy.conf;”下方

log_format  main  '$http_x_forwarded_for [$time_local] "$request" '
                  '$status $body_bytes_sent "$http_referer" '
                  '$http_user_agent $remote_addr $request_time';
				  

保存好后，我们找到VPS上使用了Cloudflare CDN加速的那个网站，-->设置-->配置修改：
拉到差不多最底下，给网站日志文件后面加上main标签。改为使用main这个日志格式，具体操作为搜索

将 access_log  /www/wwwlogs/www.xxx.com.log;
修改为 access_log  /www/wwwlogs/www.xxx.com.log main;

参考文章：https://www.pigji.com/224.html

然后重启NGINX


修改fakeipcf.sh和deletelog.sh脚本的配置，然后直接复制粘贴到宝塔定时任务的shell脚本中。

参考文章：https://jhrs.com/2019/33092.html

fakeipcf.sh推荐设置2分钟执行一次

deletelog.sh推荐设置2小时30分钟执行一次
