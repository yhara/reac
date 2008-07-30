# 
# reacruby - Reactive Programming on Ruby
#
# (c) 2008, yhara@kmc.gr.jp
require 'reac/reactivize.rb'
require 'reac/view.rb'

class Reac
  self.instance_methods.each do |m|
    undef_method(m) unless ["__send__", "__id__"].include?(m.to_s)
  end

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
    when Cond
      if Reac.value(reac.cond)
        reac.data = Reac.value(reac.thenr)
      elsif reac.elser
        reac.data = Reac.value(reac.elser)
      else
        reac.data = nil
      end
    else
      raise "must not happen"
    end
  end

  #TODO: use Struct

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

  class Cond < Reac
    def initialize(cond, thenr, elser=nil)
      @cond, @thenr, @elser = cond, thenr, elser
    end
    attr_accessor :data
    attr_reader :cond, :thenr, :elser
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

# Object#then
# (n % 3 == 0).then(value)
# (n % 3 == 0).then(value, value)
class Object
  def then(thenr, elser=nil)
    Reac::Cond.new(self, thenr, elser)
  end
end
