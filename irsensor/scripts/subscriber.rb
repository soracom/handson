require 'mqtt'

MQTTHOST = "beam.soracom.io"
USERNAME = ENV["MQTT_USERNAME"]

client = MQTT::Client.new(
  MQTTHOST
)

client.connect do |c|
  TOPIC = "#{USERNAME}/#"
  c.get(TOPIC) do |topic, message|
    if /\/ir_controller\Z/ === topic
      puts "#{topic}: #{message}"
      system("irsend SEND_ONCE controller #{message}")
    end
  end
end
