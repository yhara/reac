require 'reac'
require 'reac/view/curses.rb'

x = Reac{rand(100)}
y = x * 2 
t = Reac{Time.now}

#### Make a reactive world (declarative style):
Reac::CursesView.new{
  put 0, 0, "x : " + x.to_s
  put 1, 0, "y : " + y.to_s
  put 2, 0, "x and y : " + Reac([x, y]).inspect

  put 4, 0, "now : " + t.strftime("%H:%M:%S")
  put 5, 0, "second * 100 : " + (t.sec * 100).to_s

}.start(3)

#### Another way (imperative style):
#
#view = Reac::CursesView.new
#view.put(0, 0, "x : " + x.to_s)
#view.put(1, 0, "y : " + y.to_s)
#view.put(2, 0, "x and y : " + Reac([x, y]).inspect)
#
#view.put(4, 0, "now : " + t.strftime("%H:%M:%S"))
#view.put(5, 0, "second * 100 : " + (t.sec * 100).to_s)
#
#view.start(3)
