#!/home/greg/.rvm/rubies/default/bin/ruby

require 'rmagick'

class String
  def convert_base(from, to)
    to_i(from).to_s(to)
  end
end

class Numeric
  def diff(other_value)
    (self - other_value).to_f.abs
  end
end

class Array
  def mean
    inject(&:+) / size # sum / length of self
  end
end

module ColorGuesser
  class ColorSquare
    def initialize(color)
      imgl = Magick::ImageList.new
      imgl.new_image(200,200, Magick::HatchFill.new(color, color))
      imgl.write("square.png")
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
      @light, @dark = {r: [255], g: [255], b:[255]}, {r: [0], g: [0], b:[0]}
      @current_color = Color.random_color
      ColorSquare.new @current_color
    end

    def add_color(color, type)
      # create a local color object
      _color = Color.new(color).rgb
      # add the R from color to the R arr in self.white|black etc. for G and B
      _new = instance_variable_get("@#{type}").merge(_color){ |k,o,n|o << n }
      # save the abovementioned
      instance_variable_set("@#{type}", _new)
      @current_color = Color.random_color
      ColorSquare.new @current_color
    end

    def color_chance(color)
      ["dark", "light"].map do |t|
        self.instance_variable_get("@#{t}").map do |k,v| # get current color
          target_color = color.rgb["#{k}".to_sym]
          # difference between
          # mean of (mean color value + the closest color in dark/light)
          # closest color in dark/light
          [v.mean, v.min_by{|x|(x-target_color).abs}].mean.diff(target_color)
        end.mean
      end.zip([:dark, :light]).map(&:reverse).to_h # convert back to hash
      # example return:
      # {light: 12, dark: 54}
    end

    def decide(color)
      # get the type with the smallest total diff from the provided color
      color_chance(color).min_by{ |k,v| v }.first.to_s
    end
  end
end
