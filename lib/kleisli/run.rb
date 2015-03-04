require "kleisli/run/version"
require 'ostruct'

module Kleisli

  def self.run(runner_impl = Runner, &block)
    r = runner_impl.new(block.binding)
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
      m >-> i { called = true; set_value(val, i) }
      raise MonadTerminator.new(m) unless called
      get_value(val)
    end

    def set_value(k, v)
      @struct.send("#{k}=".to_sym, v)
    end

    def get_value(k)
      @struct.send(k)
    end

    def method_missing(m, *args)
      if @o_self.respond_to?(m)
        return @o_self.send(m, *args)
      end
      if args.first.kind_of?(Hash) && args.first[:from] && args.size == 1
        return extract(m, args.first[:from])
      end
      if args.empty?
        get_value(m)
      else
        set_value(m, args.first)
      end
    end
  end

  class HashRunner < Runner

    def initialize(block_binding)
      super(block_binding)
      @hash = {}
    end

    def set_value(k, v)
      @hash[k] = v
    end

    def get_value(k)
      @hash[k]
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
