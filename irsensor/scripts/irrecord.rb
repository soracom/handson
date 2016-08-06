require 'erb'
require 'readline'

def get_signal_name(commands)
  puts "ボタンの名称を入力してください (Ex: power_on)"
  signal_name = Readline.readline
  unless commands[signal_name].nil? 
    return get_signal_name(commands)
  end
  return signal_name
end

lines =  File.open(ARGV[0]).readlines
lines_without_first = lines.slice(1..-1).join(" ")

commands = {}
command_name = ""
if File.exist?('/etc/lirc/lircd.conf')
  File.open('/etc/lirc/lircd.conf').each do |line|
    if /name\s(?!controller)/ === line
      command_name = line.gsub(/\A.*name\s|\n/, "")
    end

    if /\A\s*\d{2,5}\s/ === line
      if commands[command_name].nil?
        commands[command_name] = line
      else
        commands[command_name] += line
      end
    end
  end
end

signal_name = get_signal_name(commands)
commands[signal_name] = lines_without_first

erb = ERB.new <<'END'
begin remote
  name controller 
    flags RAW_CODES
    eps   30
    aeps  100
    gap   200000
    toggle_bit_mask 0x0
    
    begin raw_codes
      <% commands.each do |k, v|%>
      name <%= k %>
      <% v.split(/\n/).each do |d| %><%= d.gsub(/\A\s*/, '') %>
      <% end %>
      <% end %>
    end raw_codes
end remote
END

lircd_conf = erb.result(binding)

File.open('/etc/lirc/lircd.conf', 'w') do |file|
  file.write(lircd_conf)
end
