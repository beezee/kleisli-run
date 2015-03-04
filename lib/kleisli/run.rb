require "kleisli/run/version"

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
      @hash = {}
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
      @hash[k] = v
    end

    def get_value(k)
      @hash[k]
    end

    def method_missing(m, *args)
      case
      when @o_self.respond_to?(m)
        @o_self.send(m, *args)
      when args.first.kind_of?(Hash) && args.first[:from] && args.size == 1
        extract(m, args.first[:from])
      when args.empty?
        get_value(m)
      when m.to_s =~ /\=$/
        set_value(m, args.first)
      else
        @o_self.send(m, *args)
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
