require 'mqtt'

MQTTHOST = "lite.mqtt.shiguredo.jp"
USERNAME = ENV["MQTT_USERNAME"]
PASSWORD = ENV["MQTT_PASSWORD"]

client = MQTT::Client.new(
  MQTTHOST,
  :username => USERNAME,
  :password => PASSWORD
)

client.connect do |c|
  TOPIC = "#{MQTT_USERNAME}/ir_controller"
  c.publish(TOPIC, ARGV[0])
end
