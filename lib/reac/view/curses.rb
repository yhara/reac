require 'curses'

class Reac
  class CursesView < View
    def initialize(&block)
      @top_window = Curses.init_screen
      @x = @y = 0
      #Curses.noecho
      #Curses.nocbreak  # disable buffering keyboard input
      Curses.clear
      Curses.refresh
      @reacs = []
      #@top_window = Curses::Window.new(Curses.cols-2, Curses.lines-1, 0, 0) #y, x = 0

      instance_eval(&block) if block
    end

    def put(y, x, reac)
      @reacs << [y, x, reac]
    end

    def main_loop(now)
      @top_window.clear
      @reacs.each do |y, x, reac|
        yval = Reac.value(y, now)
        xval = Reac.value(x, now)
        @top_window.setpos(yval, xval)
        @top_window << Reac.value(reac, now).to_s
        @top_window.refresh
      end
    end
  end
end
