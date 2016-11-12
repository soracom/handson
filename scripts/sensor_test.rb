#!/usr/bin/env ruby
require './GPIO'

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

while true
  start_time = Time.now
  printf "距離: %.1f cm\n", read_distance()

  # １秒に１回実行するためのウェイトを入れる
  if Time.now < start_time+1
    sleep start_time+1-Time.now
  end
end
