require 'sdl'

class Reac

  class SDLView < View

    def self.init(w=640, h=480, options={})
      @@width, @@height = w, h
      bpp   = options[:bpp] || 32
      flags = options[:flags] || SDL::SWSURFACE

      SDL.init(options[:init_flags] || SDL::INIT_EVERYTHING)
      SDL::TTF.init unless options[:no_ttf]
      @@screen = SDL.set_video_mode(w, h, bpp, flags)
    end

    def initialize(options={}, &block)
      @reacs = {
        :images => [],
        :bmfonts => [],
        :ttffonts => [],
      }
      @background_color = options[:background] || [0, 0, 0]

      instance_eval(&block) if block
    end

    def put(_x, _y, _obj, *rest)
      case _obj
      when SDL::Surface
        put_image(_x, _y, _obj)
      else
        put_string(_x, _y, _obj, *rest)
        #raise ArgumentError, "unkown object type: #{_obj.class}"
      end
    end

    def main_loop(now)
      @@screen.fill_rect(0, 0, @@width, @@height, @background_color)
      @reacs[:images].each do |_x, _y, _image|
        x = Reac.value(_x, now)
        y = Reac.value(_y, now)
        image = Reac.value(_image, now)
        @@screen.put(image, x, y)
      end
      @reacs[:bmfonts].each do |_x, _y, _str, font|
        x = Reac.value(_x, now)
        y = Reac.value(_y, now)
        str = Reac.value(_str, now)
        i = 0
        str.each_line do |line|
          font.textout(@@screen, line, x, y + font.height*i)
          i += 1
        end
      end
      col = [255,255,255]
      @reacs[:ttffonts].each do |_x, _y, _str, font|
        x = Reac.value(_x, now)
        y = Reac.value(_y, now)
        str = Reac.value(_str, now)
        i = 0
        str.each_line do |line|
          font.draw_solid_utf8(@@screen, line, x, y + font.line_skip*i, *col)
          i += 1
        end
      end
      @@screen.flip
    end

    private

    #TODO: rewrite in OOP style (use inheritance)
    def put_image(_x, _y, _image)
      @reacs[:images] << [_x, _y, _image]
    end

    def put_string(_x, _y, _str, font)
      case font
#      when SDL::BMFont
#        @reacs[:bmfonts] << [_x, _y, _str, font]
      when SDL::TTF
        @reacs[:ttffonts] << [_x, _y, _str, font]
      when SDL::Kanji
        raise NotImplementedError, "this font type is not yet supported.."
      else
        raise ArgumentError, "unkown font type: #{font.class}"
      end
    end

  end
  
end
