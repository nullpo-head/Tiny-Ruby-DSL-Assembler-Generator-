module OperandType
  attr_accessor :bit_len, :name

  def bit_exp(num)
    [*1..32].inject("") {|accu, i| accu += num[32 - i].to_s}
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

  def initialize(sym)
    @sym = sym
  end

  def encode(env)
    raise StandardError.new("Label '#{@sym.to_s}' in not found.") if env[:labels][@sym].nil? or env[:labels][@sym][:location].nil?
    bit_exp(env[:labels][@sym][:location] - (env[:location] + 1))
  end

  def self.type_accept?(type)
    type == Symbol
  end

end

class LabelAbsolute
  include OperandType

  def initialize(sym)
    @sym = sym
  end

  def encode(env)
    if env[:labels][@sym]
      bit_exp(env[:labels][@sym][:location] + env[:base_addr])
    elsif env[:exported_labels][@sym]
      bit_exp(env[:exported_labels][@sym][:location])
    else
      raise StandardError.new("Label '#{@sym.to_s}' is not found.")
    end
  end

  def self.type_accept?(type)
    type == Symbol
  end

end

class Immediate
  include OperandType

  def initialize(isf)
    if isf.class == Fixnum
      @int = isf
    elsif isf.class == Float
      @int = ftoi(isf)
    else
      @label = isf
    end
  end

  def encode(env)
    unless @int.nil?
      bit_exp(@int)
    else
      LabelAbsolute.new(@label).encode(env)
    end
  end

  def self.type_accept?(type)
    type == Fixnum || type == Symbol || type == Float
  end

  def ftoi(f)
    [f].pack("f").unpack("l")[0]
  end

end

