#!/home/greg/.rvm/rubies/default/bin/ruby

require 'shoes'

class String
  def convert_base(from, to)
    to_i(from).to_s(to)
  end
end

class Array
  def mean
    inject(&:+) / size # sum / length of self
  end

  # jRuby didn't have this for some reason
  def to_h
    Hash[self]
  end
end

class Color
  attr_reader :hex_color, :rgb

  # when printing the current color
  def to_s
    "#{@hex_color}"
  end

  def initialize(rgb_s)
    @hex_color = rgb_s
    # remove '#' and split into arrays of 2
    rgb_a = rgb_s.sub('#','').split('').each_slice(2).to_a
    # convert each num from base16 to base10
    rgb_a.map! {|x| x.join('').convert_base(16,10).to_i}

    @rgb = {r: rgb_a[0], g: rgb_a[1], b: rgb_a[2]}
  end

  def self.random_color
    _rand_color = "#" + rand("ffffff".convert_base(16,10).to_i)
                          .to_s.convert_base(10,16)
    # because it removes trailing 0's
    _rand_color += "0" until _rand_color.length == 7
    _rand_color
  end
end

class ColorGuesser
  attr_accessor :light, :dark, :current_color

  def initialize
    # instanciate empty arrs
    @light, @dark = {r: [], g: [], b:[]}, {r: [], g: [], b:[]}
  end

  def add_color(color, type)
    _color = Color.new(color).rgb
    _new = instance_variable_get("@#{type}").merge(_color){ |k,o,n|o << n }
    instance_variable_set("@#{type}", _new)
  end

  def color_chance(color)
    diff = Proc.new{ |val, target| (val - target).to_f.abs }

    ["dark", "light"].map do |t|
      self.instance_variable_get("@#{t}").map do |k,v| # get current color
        target_color = color.rgb["#{k}".to_sym]
        diff.call(v.mean, target_color)
      end.mean
    end.zip([:dark, :light]).map(&:reverse).to_h
  end

  def decide(color)
    color_chance(color).min_by{ |k,v| v }.first.to_s
  end
end

Shoes.app(height: 400, width: 300) do
  color_guesser = ColorGuesser.new
  color_guesser.current_color = Color.random_color

  stack height: 200 do
    @colored_rect = rect 12, 12, 276, 200, fill: color_guesser.current_color
  end

  stack margin: 12 do
    @color_text = title color_guesser.current_color
    flow do
      @light_b = button "Light" do
        color_guesser.current_color = c = Color.random_color
        @color_text.text = c
        @colored_rect.fill = c
        color_guesser.add_color(c, :light)
        @guessed_text.text = ""
      end

      @dark_b = button "Dark", margin_left: 10 do
        color_guesser.current_color = c = Color.random_color
        @color_text.text = c
        @colored_rect.fill = c
        color_guesser.add_color(c, :dark)
        @guessed_text.text = ""
      end

      @guess_b = button "Guess", align: "center", margin_left: 10 do
        guess = color_guesser.decide(Color.new(color_guesser.current_color))
        @guessed_text.text = "Morpheus guesses: #{guess}."
      end

      @reset_b = button "Reset", margin_left: 10 do
        color_guesser = ColorGuesser.new
      end
    end
    @guessed_text = para "", margin_top: 20
  end
end
