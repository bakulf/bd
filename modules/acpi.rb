# ACPI module for 'bd'

require 'libnotify'

@notifyWarning = false
@notifyCritical = false
@n = nil

def close_notify()
  unless @n.nil?
    @n.close
    @n = nil
  end
end

def notify(level, battery, time)
  @bd.warning "Battery", true
  close_notify
  @n = Libnotify.new(:summary => "Battery #{level}",
                     :body => "Battery level: #{battery}, Time: #{time}",
                     :urgency => level == 'Critical' ? :critical : :normal)
  @n.update
end

def magic
  charging = false
  capacity = ''
  time = ''

  output = ""
  IO.popen("acpitool -b") do |a| output += a.read end
  output.split("\n").each do |line|
    next unless line.include? ':'

    parts = line.split(':', 2)
    parts = parts[1].strip.split(',')
    return if parts.length < 2

    charging = parts[0].strip == 'Charging' || parts[0].strip == 'Full'
    capacity = parts[1].strip
    time = parts[2].strip if parts.length > 2
  end

  @bd.add_tooltip("Battery", "#{charging ? "Charging" : "Discharging" }, #{capacity}, #{time}")

  if charging == true
    @bd.warning "Battery", false
    @notifyWarning = @notifyCritical = false
    close_notify
    return
  end

  value = capacity.to_i
  if value < 5
    return if @notifyCritical == true

    @notifyCritical = true
    notify("Critical", capacity, time)
    return
  end

  if value < 10
    return if @notifyWarning == true

    @notifyWarning = true
    notify("Warning", capacity, time)
    return
  end
end

GLib::Timeout.add 5000 do
  magic
  true
end

magic
