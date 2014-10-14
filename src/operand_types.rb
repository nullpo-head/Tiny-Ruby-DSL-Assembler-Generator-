module OperandType
  attr_accessor :bit_len

  def bit_exp(num)
    [*1..bit_len].inject("") {|accu, i| accu += num[bit_len - i].to_s}
  end
  
end

class Reg
  include OperandType
  
  def initialize(num)
    @num = num
  end

  def encode(env)
    bit_exp(@num)
  end

  def self.type_accept?(type)
    type == Reg
  end


end

class LabelRelative
  include OperandType

  attr_accessor :bit_len

  def initialize(sym)
    @sym = sym
  end

  def encode(env)
    raise StandardError.new("Label '#{@sym.to_s}' in not found.") if env[:labels][@sym][:location].nil?
    bit_exp(env[:labels][@sym][:location] - (env[:location] + 1))
  end

  def self.type_accept?(type)
    type == Symbol
  end

end

class LabelAbsolute
  include OperandType

  attr_accessor :bit_len

  def initialize(sym)
    @sym = sym
  end

  def encode(env)
    raise StandardError.new("Label '#{@sym.to_s}' in not found.") if env[:labels][@sym][:location].nil?
    bit_exp(env[:labels][@sym][:location])
  end

  def self.type_accept?(type)
    type == Symbol
  end

end

class Immediate
  include OperandType

  attr_accessor :bit_len

  def initialize(int)
    @int = int
  end

  def encode(env)
    bit_exp(@int)
  end

  def self.type_accept?(type)
    type == Fixnum
  end

end

