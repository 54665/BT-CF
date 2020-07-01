#/bin/bash
    #创建black.txt
    touch /www/wwwlogs/black.txt
    #日志文件，你需要改成你自己的路径
    logfile=/www/wwwlogs/
    last_minutes=1
    #开始时间1分钟之前（这里可以修改,如果要几分钟之内攻击次数多少次，这里可以自定义）
    start_time= date +"%Y-%m-%d %H:%M:%S" -d '-1 minutes'
    echo $start_time
    #结束时间现在
    stop_time=`date +"%Y-%m-%d %H:%M:%S"`
    echo $stop_time
    cur_date="`date +%Y-%m-%d`" 
    echo $cur_date
    #过滤出单位之间内的日志并统计最高ip数，请替换为你的日志路径！！！！
    tac $logfile/www.fun.log | awk -v st="$start_time" -v et="$stop_time" '{t=substr($2,RSTART+14,21);if(t>=st && t<=et) {print $0}}' | awk '{print $1}' | sort | uniq -c | sort -nr > $logfile/log_ip_top10
    ip_top=`cat $logfile/log_ip_top10 | head -1 | awk '{print $1}'`
    ip=`cat $logfile/log_ip_top10 | awk '{if($1>30)print $2}'`
    # 单位时间[1分钟]内单ip访问次数超过30次的ip记录入black.txt,这里大鸟为了测试设置了30，你需要改成其它的数字
    for line in $ip
    do
    echo $line >> $logfile/black.txt
    echo $line
    # 这里还可以执行CF的API来提交数据到CF防火墙
    done
    # 填Cloudflare Email邮箱
    CFEMAIL=""
    # 填Cloudflare API key
    CFAPIKEY=""
    # 填Cloudflare Zones ID 域名对应的ID
    ZONESID=""
    # /www/wwwlogs/black.txt存放恶意攻击的IP列表
    # IP一行一个。
    IPADDR=$(</www/wwwlogs/black.txt)
    # 循环提交 IPs 到 Cloudflare  防火墙黑名单
    # 模式（mode）有 block, challenge, whitelist, js_challenge
    for IPADDR in ${IPADDR[@]}; do
    echo $IPADDR
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONESID/firewall/access_rules/rules" \
      -H "X-Auth-Email: $CFEMAIL" \
      -H "X-Auth-Key: $CFAPIKEY" \
      -H "Content-Type: application/json" \
      --data '{"mode":"block","configuration":{"target":"ip","value":"'$IPADDR'"},"notes":"CC Attatch"}'
    done
    # 删除 IPs 文件收拾干净
     rm -rf /www/wwwlogs/black.txt