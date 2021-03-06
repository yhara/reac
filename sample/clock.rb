require 'reac'
require 'reac/view/curses'

module Math
  reactivize_singleton :sin, :cos
end

def rad(phase)
  phase * (2 * Math::PI)
end

SIZE = 20
t = Reac{Time.now}

deg = (t.sec.to_f - 15) / 60
phase = rad(deg)
y = Math.sin(phase) * SIZE/2 + SIZE/2
x = Math.cos(phase) * SIZE + SIZE
fizzbuzz = (t.sec % 15 == 0).then("FizzBuzz",
             (t.sec % 5 == 0).then("Buzz", 
               (t.sec % 3 == 0).then("Fizz")))

Reac::CursesView.new{
  put SIZE/2, SIZE-2, t.strftime("%H:%M")
  put SIZE/2+1, SIZE-2, fizzbuzz
  put y, x, t.sec.to_s
}.start(30)

