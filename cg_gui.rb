#!/home/greg/.rvm/rubies/default/bin/ruby

require 'gtk2'
require './color_guesser'

# Setup login for ColorGuesser
guesser = ColorGuesser::ColorGuesser.new

def certainty(guesser_obj, color)
  differences = guesser_obj.color_chance(ColorGuesser::Color.new(color))
  certainty = differences.map do |k,v|
    k.to_s + ": #{((1-v/differences.values.inject(&:+))*100).round}%"
  end.join("\n")
  differences = differences.min_by{|k,v|v}
  "Guess: #{differences.first} with #{differences.last.round} error\n#{certainty}"
end

# Create window
window = Gtk::Window.new

window.title = "Color Thing"
window.border_width = 10

# Buttons
button_light = Gtk::Button.new("_Light")
button_dark = Gtk::Button.new("_Dark")

# Image
img_color = Gtk::Image.new("square.png")

# Main box (V)
main_box = Gtk::VBox.new(false, 0)

# Button box (H)
button_box = Gtk::HBox.new(false, 0)

# Image color text
text_color = Gtk::Label.new(guesser.current_color)

# Guess text
text_guess = Gtk::Label.new(certainty(guesser, guesser.current_color))

# Hooks
window.signal_connect("destroy") {
  Gtk.main_quit
}

def choose(type, guesser_obj, img, guess, color)
  guesser_obj.add_color(guesser_obj.current_color, type)
  # reload image
  img.file = "square.png"
  # hide the guessed answer
  guess.text = certainty(guesser_obj, guesser_obj.current_color)
  # update color text
  color.text = guesser_obj.current_color
end

# dark color selected
button_dark.signal_connect("clicked") do
 choose("dark", guesser, img_color, text_guess, text_color)
end

# light color selected
button_light.signal_connect("clicked") do
 choose("light", guesser, img_color, text_guess, text_color)
end

# Add elems
window.add(main_box)

# add the buttons
button_box.pack_start(button_light, true, true, 0)
button_box.pack_start(button_dark, true, true, 0)

# image with color
main_box.pack_start(img_color)
# color text
main_box.add(text_color)
# light/dark buttons
main_box.pack_start(button_box)
# guess text
main_box.pack_start(text_guess, true, true, 0)

# Start!
window.show_all
Gtk.main
