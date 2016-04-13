#!/home/greg/.rvm/rubies/default/bin/ruby

require 'gtk2'
require './color_guesser'

# Setup login for ColorGuesser
guesser = ColorGuesser::ColorGuesser.new

# Create window
window = Gtk::Window.new

window.title = "Color Thing"
window.border_width = 10

# Buttons
button_light = Gtk::Button.new("_Light")
button_dark = Gtk::Button.new("_Dark")
button_guess = Gtk::Button.new("_Guess")

# Image
img_color = Gtk::Image.new("square.png")

# Main box (V)
main_box = Gtk::VBox.new(false, 0)

# Button box (H)
button_box = Gtk::HBox.new(false, 0)

# Image color text
text_color = Gtk::Label.new(guesser.current_color)

# Guess text
text_guess = Gtk::Label.new('Please answer some colors before using the guess function')

# Hooks
window.signal_connect("destroy") {
  Gtk.main_quit
}

def choose(type, guesser_obj, img, guess, color)
  guesser_obj.add_color(guesser_obj.current_color, type)
  # reload image
  img.file = "square.png"
  # hide the guessed answer
  guess.hide
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

button_guess.signal_connect("clicked") do
  _color = ColorGuesser::Color.new(guesser.current_color)
  text_guess.text = "My guess is: #{guesser.decide(_color)}.\n\
Difference: \
#{guesser.color_chance(_color).map{|k,v|"#{k}: #{v.to_i}"}}"
  text_guess.show_now
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
# guess button
main_box.pack_start(button_guess, true, true, 0)
# guess text
main_box.pack_start(text_guess, true, true, 0)

# Start!
window.show_all
Gtk.main
