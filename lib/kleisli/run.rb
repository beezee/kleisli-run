require "kleisli/run/version"
require 'ostruct'

module Kleisli

  def self.run(&block)
    r = Runner.new(block.binding)
    begin
      res = r.instance_eval(&block)
      r.start.fmap { res }
    rescue MonadTerminator => ex
      ex.m
    end
  end

  class Runner
    attr_reader :start

    def initialize(block_binding)
      @struct = OpenStruct.new
      @stopped = false
      @start = false
      @o_self = block_binding.eval('self')
    end

    def extract(val, m)
      called = false
      @start = m unless @start
      m >-> i { called = true; @struct.send("#{val}=".to_sym, i) }
      raise MonadTerminator.new(m) unless called
      @struct.send(val)
    end

    def method_missing(m, *args)
      if @o_self.respond_to?(m)
        return @o_self.send(m, *args)
      end
      if args.first.kind_of?(Hash) && args.first[:from] && args.size == 1
        return extract(m, args.first[:from])
      end
      if args.empty?
        @struct.send(m)
      else
        @struct.send("#{m}=".to_sym, args.first)
      end
    end
  end

  class MonadTerminator < Exception
    attr_accessor :m

    def initialize(msg)
      super(msg)
      self.m = msg
    end
  end
end
