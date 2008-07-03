require 'readline'
require 'reac'
require 'reac/view/sdl'

# ruby 1.8/1.9 compatible
# ord(?a)   #=> returns 97
def ord(x)
  if x.is_a? String
    x.ord
  else
    x
  end
end

# call this before loading images, fonts, etc.
Reac::SDLView.init
view = Reac::SDLView.new

#font = SDL::BMFont.open("font.bmp", SDL::BMFont::TRANSPARENT)
font = SDL::TTF.open("ttf.ttf", 16)
#font = SDL::TTF.open("/Library/Fonts/Osaka.dfont", 16)

h = font.line_skip
n_lines = 0

#def method_missing(method, *args)
#  eval("@#{method}")
#end

KEYS = {
  SDL::Key::K1           => [ "1"  , "!"]  ,
  SDL::Key::K2           => [ "2"  , "\""] ,
  SDL::Key::K3           => [ "3"  , "#"]  ,
  SDL::Key::K4           => [ "4"  , "$"]  ,
  SDL::Key::K5           => [ "5"  , "%"]  ,
  SDL::Key::K6           => [ "6"  , "&"]  ,
  SDL::Key::K7           => [ "7"  , "'"]  ,
  SDL::Key::K8           => [ "8"  , "("]  ,
  SDL::Key::K9           => [ "9"  , ")"]  ,
  SDL::Key::K0           => [ "0"  , "0"]  ,
  SDL::Key::MINUS        => [ "-"  , "="]  ,
  SDL::Key::CARET        => [ "^"  , "~"]  ,
  SDL::Key::BACKSLASH    => [ "\\" , "_"]  ,

  SDL::Key::AT           => [ "@"  , "`"]  ,
  SDL::Key::LEFTBRACKET  => [ "["  , "{"]  ,

  SDL::Key::SEMICOLON    => [ ";"  , "+"]  ,
  SDL::Key::COLON        => [ ":"  , "*"]  ,
  SDL::Key::RIGHTBRACKET => [ "]"  , "}"]  ,

  SDL::Key::COMMA        => [ ","  , "<"]  ,
  SDL::Key::PERIOD       => [ "."  , ">"]  ,
  SDL::Key::SLASH        => [ "/"  , "?"]  ,
}
str = "(press ESCAPE to exit)\n" +
      "example: > @t = Reac{ Time.now }\n" + 
      "> "
header_size = str.split(/\n/).size
res = Reac{
  while event = SDL::Event2.poll
    if event.is_a?(SDL::Event2::KeyDown)
      if KEYS.key?(event.sym)
        if (event.mod & SDL::Key::MOD_SHIFT) == 0
          str << KEYS[event.sym].first
        else
          str << KEYS[event.sym].last
        end
      else
        case event.sym
        when SDL::Key::BACKSPACE
          str.chop!
        when SDL::Key::A .. SDL::Key::Z
          c = ord(?a) + (event.sym - SDL::Key::A)
          if (event.mod & SDL::Key::MOD_SHIFT) != 0
            c += (ord(?A) - ord(?a))
          end
          str << c.chr
        when SDL::Key::COMMA .. SDL::Key::SEMICOLON
          str << (ord(?,) + (event.sym - SDL::Key::COMMA)).chr
        when SDL::Key::RETURN
          code = str.split(/\n/).last[/^> (.*)/, 1]
          y = h * (n_lines * 2 + header_size)
          begin
            view.put 0, y, self.instance_eval(code).inspect, font
          rescue StandardError, ScriptError => e
            view.put 0, y, "#{e.class}!"
          end
          n_lines += 1
          str << "\n\n> "
        when SDL::Key::SPACE
          str << " "
        when SDL::Key::ESCAPE
          exit
        end
      end
    end
  end
  str
}

view.put 0, 0, res, font
view.start
