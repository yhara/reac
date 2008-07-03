#
# Reac::Reactivize
#
class Reac
  module Reactivize
    # reactivize - make methods to take reactive values
    # NOTE: currently supports one-arg method only
    #
    # exmaple:
    #class String
    #  alias __old_plus__ +
    #  def +(other)
    #    if other.kind_of?(Reac)
    #      Reac(self) + other
    #    else
    #      self.__old_plus__(other)
    #    end
    #  end
    #end
    OLD_NAME = {
      :+ => "plus",
      :- => "minus",
      :* => "mul",
      :/ => "div"
    }
    def reactivize(*methods)
      methods.each do |m|
        old_name = OLD_NAME[m] || m
        module_eval <<-EOD
          alias __old_#{old_name}__ #{m}
          def #{m}(arg)
            if arg.kind_of?(Reac)
              Reac(self).#{m}(arg)
            else
              __old_#{old_name}__(arg)
            end
          end
        EOD
      end
    end

    # reactivize singleton methods.
    #
    # example:
    #   module Math
    #    reactivize_singleton :sin, :cos
    #   end
    def reactivize_singleton(*methods)
      method_list = methods.map{|m|m.inspect}.join(',')
      instance_eval <<-EOD
        class << self
          reactivize #{method_list}
        end
      EOD
    end
  end
end

# now you can use 'reactivize' in all classes & modules
Module.__send__(:include, Reac::Reactivize)

class String
  reactivize :+, :*
end

class Fixnum
  reactivize :+, :-, :*, :/
end

