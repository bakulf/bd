#!/usr/bin/env ruby

=begin
  bd - my deamon
=end

require 'gtk2'

class Bd
  def init
    @warnings = {}
    @tooltips = {}
    create_icon
    load_modules
  end

  def run
    Gtk.main
  end

  def warning(what, value)
    @warnings[what] = value

    warning = false
    @warnings.each do |k, v| warning = warning || v end

    @si.blinking = warning
  end

  def add_tooltip(key, value)
    @tooltips[key] = value

    tooltip = []
    @tooltips.each do |k, v| tooltip.push("#{k}: #{v}") end
    @si.tooltip = tooltip.join(", ")
  end

private
  def create_icon
    @si = Gtk::StatusIcon.new
    @si.pixbuf = Gdk::Pixbuf.new('/usr/share/pixmaps/bd/bd.svg')
    @si.tooltip = ""
  end

  def load_modules
    dirname = ENV['HOME'] + '/.bd'

    if not File.exist? dirname
      Dir.mkdir dirname
    end

    # Let's load the modules
    d = Dir.open dirname
    while file = d.read do
      next if file.start_with? '.'
      begin
        require dirname + '/' + file
      rescue
        puts "Error loading " + dirname + '/' + file
      end
    end
  end
end

# Let's start!

@bd = Bd.new
@bd.init
@bd.run
