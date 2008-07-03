require 'reac'
require 'reac/view/sdl.rb'

Reac::SDLView.init
img = SDL::Surface.load_bmp("icon.bmp")

x = Reac{ (Time.now.usec/5000) % 640 }
y = (x * 3) % 480

Reac::SDLView.new{
  put x, y, img
}.start(5)
