require 'mqtt'

MQTTHOST = "beam.soracom.io"

client = MQTT::Client.new(
  MQTTHOST
)

client.connect do |c|
  TOPIC = "#"
  c.get(TOPIC) do |topic, message|
    if /\/ir_controller\Z/ === topic
      puts "#{topic}: #{message}"
      system("irsend SEND_ONCE controller #{message}")
    end
  end
end
