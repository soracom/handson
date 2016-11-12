#!/usr/bin/env ruby
module GPIO
  module_function

  def export(n, dir)
    File.open("/sys/class/gpio/export", "w") do |fp|
      fp.write(n.to_s)
    end
    sleep 0.1
    File.open("/sys/class/gpio/gpio#{n}/direction", "w") do |fp|
      fp.write(dir)
    end
  end

  def unexport(n)
    File.open("/sys/class/gpio/unexport", "w") do |fp|
      fp.write(n.to_s)
    end
  end

  def reset(*pins)
    pins.each do |pin|
      begin
        unexport(pin)
      rescue
      end
    end
  end

  def read(n)
    File.read("/sys/class/gpio/gpio#{n}/value")
  end

  def write(n, value)
    File.open("/sys/class/gpio/gpio#{n}/value", "w") do |fp|
      fp.write(value.to_s)
    end
  end

  class Edge
    def initialize(n, mode='both')
      File.open("/sys/class/gpio/gpio#{n}/edge", "w") do |fp|
        fp.write(mode)
      end
      @value = File.open("/sys/class/gpio/gpio#{n}/value")
    end

    def wait(timeout=nil)
      IO.select([], [], [@value], timeout)
      read
    end

    def read
      @value.seek(0)
      @value.read
    end

    def close
      @value.close
    end
  end
end
