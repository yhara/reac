class Reac

  class View

    WAIT = 0.1

    def start(secs=nil)
      if secs
        start = Time.now
        loop{
          now = Time.now
          main_loop(now)
          break if now - start > secs
          sleep WAIT
        }
      else
        loop{ 
          main_loop(Time.now)
          sleep WAIT
        }
      end
    end

  end

end
