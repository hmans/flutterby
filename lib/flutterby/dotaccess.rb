module Dotaccess
  class Proxy
    def initialize(hash)
      @hash = hash
    end

    def method_missing(meth, *args)
      if @hash.respond_to?(meth)
        @hash.send(meth, *args)
      elsif meth =~ %r{\A(.+)=\Z}
        @hash[$1] = args.first
      elsif v = (@hash[meth] || @hash[meth.to_s])
        v.is_a?(Hash) ? Proxy.new(v) : v
      else
        nil
      end
    end
  end

  def self.[](hash)
    Proxy.new(hash)
  end
end
