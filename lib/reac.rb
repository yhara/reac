# 
# reacruby - Reactive Programming on Ruby
#
# (c) 2008, yhara@kmc.gr.jp
require 'reac/reactivize.rb'
require 'reac/view.rb'

class Reac
  attr_accessor :last_update

  # construct tree of Reac::*
  #  (instead of call the method)
  # to call it later
  def method_missing(method, *args)
    Call.new(self, method, args)
  end

  # caluculate the value
  # (short-hand for Reac.value(x))
  def value
    Reac.value(self)
  end

  # caluculate the value by traversing the tree
  def self.value(reac, tick=nil)
    return reac if not reac.is_a?(Reac) 

    # return cached data if already calculated
    return reac.data if tick && (reac.last_update == tick)

    reac.last_update = tick 
    case reac
    when Value
      reac.data
    when Call
      receiver = Reac.value(reac.receiver, tick)
      args = reac.args.map{|item|
        Reac.value(item, tick)
      }
      reac.data = receiver.__send__(reac.method, *args)
    when Proc
      reac.data = reac.proc.call
    when Array
      reac.data = reac.ary.map{|item| Reac.value(item, tick)}
    else
      raise "must not happen"
    end
  end
  undef :to_s
  undef :inspect
  undef :==

  class Value < Reac
    def initialize(data)
      @data = data
    end
    attr_reader :data
  end

  class Call < Reac
    def initialize(receiver, method, args)
      @receiver, @method, @args = receiver, method, args
    end
    attr_accessor :data
    attr_reader :receiver, :method, :args
  end

  class Proc < Reac
    def initialize(proc)
      @proc = proc
    end
    attr_accessor :data 
    attr_reader :proc
  end

  class Array < Reac
    def initialize(ary)
      @ary = ary
    end
    attr_accessor :data
    attr_reader :ary
  end
end

# construct reactive value from normal value (or proc)
def Reac(obj=nil, &block)
  if block
    Reac::Proc.new(block)
  else
    if obj.is_a?(Array)
      Reac::Array.new(obj)
    else
      Reac::Value.new(obj)
    end
  end
end
