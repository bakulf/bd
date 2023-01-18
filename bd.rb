#!/usr/bin/env ruby

=begin
  bd - my deamon
=end

require 'gtk3'

class Bd
  def init
    @tooltips = {}
    create_icon
    load_modules
  end

  def run
    Gtk.main
  end

  def add_tooltip(key, value)
    @tooltips[key] = value

    tooltip = []
    @tooltips.each do |k, v| tooltip.push("#{k}: #{v}") end
    @si.tooltip_text = tooltip.join(", ")
  end

private
  def create_icon
    @si = Gtk::StatusIcon.new
    @si.pixbuf = GdkPixbuf::Pixbuf.new(:file => '/usr/share/pixmaps/bd/bd.svg')
    @si.tooltip_text = ""
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
