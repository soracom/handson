#!/usr/bin/env ruby
require './GPIO'
require 'json'
require 'open-uri'
require 'elasticsearch'

GPIO.reset(17,27)
GPIO.export(17, 'out')
GPIO.export(27, 'in')

def read_distance
  GPIO.write(17, 1)
  sleep 0.00001
  GPIO.write(17, 0)
  
  edge = GPIO::Edge.new(27)
  edge.read
  edge.wait(1)
  s = Time.now
  edge.wait(1)
  e = Time.now
  edge.close
  return (e.to_f - s.to_f) * 17000
end

begin
  print "- メタデータサービスにアクセスして IMSI を確認中 ... "
  subscriber=JSON.parse(open('http://metadata.soracom.io/v1/subscriber').read)
  imsi=subscriber['imsi']
  puts imsi
rescue => e
  abort "ERROR: メタデータサービスが有効になっていない可能性があります"
end

# 閾値の設定: 距離 10cm 以内が３回続いた場合にイベント
threshold_distance = 10
threshold_count = 3
status = 'out' # 何もない時は out 、何かある時は in
status_change_at = Time.now
duration = 0
count = 0

puts <<EOF
- 条件設定
障害物を #{threshold_distance} cm 以内に #{threshold_count} 回検知したらクラウドにデータを送信します
センサーを手で遮ったり、何か物を置いてみたりしてみましょう
EOF

# ElasticSearch クライアント設定
es = Elasticsearch::Client.new hosts:[ {host: 'beam.soracom.io', port: '18080'} ]

puts "- 準備完了"

while true
  start_time = Time.now
  distance = read_distance # 距離の取得

  if status == 'out'
    if distance <= threshold_distance # 障害物を検知 
      count+=1
      printf("距離(cm) %.1f <= %.1f , 回数: %d / %d\n", distance, threshold_distance, count, threshold_count)
    else
      count=0
    end
  else 
    if distance > threshold_distance # 障害物がなくなったのを検知
      count+=1
      printf("距離(cm) %.1f > %.1f , 回数: %d / %d\n", distance, threshold_distance, count, threshold_count)
    else
      count=0
    end
  end

  # 状態が変化した
  if count >= threshold_count
    status = (status == 'out')? 'in':'out'
    duration = Time.now - status_change_at
    puts "- ステータスが '#{status}' (#{status == 'in'? '何か物体がある':'何も物体がない'}) に変化しました"
    puts "- Beam 経由でデータを送信します"
    puts es.index index: 'sensor', type: 'event', body:{'imsi':imsi, 'status':status, 'duration':duration, 'timestamp':Time.now.to_i*1001}
    count = 0
  end

  # １秒に１回実行するためのウェイトを入れる
  if Time.now < start_time+1
    sleep start_time+1-Time.now
  end
end
