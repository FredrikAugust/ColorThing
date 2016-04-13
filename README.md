# "Color Thing"

This is a quite simple program to guess whether the user thinks a color is dark or light.

The algorithm used for this is quite simple, and is therefor pretty inaccurate.

## Installation

_Only linux installation guide because linux supremacy_

**You might need to execute some of the commands using super-user permissions**

Firstly, install the packages required:

`apt-get install libatk-adaptor libgail-dev`

Then, you need to install the gems required by the program.

This can be done by `cd`ing into the directory you downloaded the repo to, and then running `gem install bundler` if you don't have the `bundler` gem installed.

When you're done with that you can run `bundle install`, and then you should be good to go.

To run the program; simply type `ruby path/to/file.rb` or `chmod +x path/to/file.rb` and `./path/to/file.rb`.

## Algorithm

So, to start off the program, you need to pass in some colors, and tell the program whether they are dark or light.

The program will then store the colors in arrays based on the RGB attributes (stored in _base10_)

This will result in this hash of colors (wrote this in JSON for readability):

```json
"light": {
  "r": [255, 200],
  "g": [255, 255],
  "b": [255, 220]
},
"dark": {
  "r": [0, 20],
  "g": [0, 40],
  "b": [0, 20]
}
```
So, when we now pass in a color, the program will try to determine the light/dark type based on the previous inputs.

Firstly, the program will find the RGB values for the color in _base10_.

E.g. `#eeffee` will result in `{"r": 238, "g": 255, "b": 238}`.

After that, it will find the mean RGB values for light and dark; so using the example above we will end up with this piece of pseudo-code.

```
Light
  R mean of [255, 200] = 227.5
  G mean of [255, 255] = 255
  N mean of [255, 220] = 237.5

Dark
  R mean of [0, 20] = 10
  G mean of [0, 40] = 20
  N mean of [0, 20] = 10
```

After this; it finds the closest value in each of the groups. So if we provided an R value of `238`, it would choose `255` since that is closer to `238` than `200`.

After that, it finds the difference between each of the RGB values of the provided color compared to the mean of the sum of the mean and the closest value. So in this example that would result in this equation:

```
Formula: absolute value of (mean + closest) / 2 - provided value

Light
  R diff = absolute value of (227.5 + 255) / 2) - 238 = 3.25
  G diff = absolute value of (255 + 255) / 2) - 255   = 0
  B diff = absolute value of (227.5 + 255) / 2) - 238 = 3.25
  Average RGB diff: (R diff + G diff + B diff) / 3    = 2.16

Dark
  R diff = absolute value of (10 + 20) / 2) - 238     = 223
  G diff = absolute value of (20 + 40) / 2) - 255     = 225
  B diff = absolute value of (10 + 20) / 2) - 238     = 223
  Average RGB diff: (R diff + G diff + B diff) / 3    = 223.66
```

Then, to determine the best match, we can compare the two mean differences and select the smallest one, which in this case would be:

```
Light    Dark
2.16  <  223.66
```

So that means that this color (according to the programs calculations) will most likely be a light color.

## GUI

The GUI is written using the `gtk2` gem for Ruby (`2.3.0p0 (2015-12-25 revision 53290) [x86_64-linux]`).

To render the color I am actually using the `rmagick` gem for Ruby to create an image, and then simply loading the image using `Gtk::Image`. To update the image I just reassing the filepath in GTK.
