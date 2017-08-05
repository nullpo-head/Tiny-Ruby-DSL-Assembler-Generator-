module OperandType
  attr_accessor :bit_len, :name

  def bit_exp(num)
    [*1..$arch[:data_size]].inject("") {|accu, i| accu += num[$arch[:data_size] - i].to_s}
  end
  
end

class Reg
  include OperandType
  
  def initialize(num)
    @num = num
  end

  def encode(env)
    if @num >= 1 << @bit_len || @num < 0
      raise StandardError.new("The number of register:'#{@num}' is in the invalid range")
    end
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
    if env[:labels][@sym].nil? or env[:labels][@sym][:location].nil?
      raise StandardError.new("Label '#{@sym.to_s}' in not found.")
    end
    value = env[:labels][@sym][:location] - (env[:location] + $arch[:instruction_length] / $arch[:addressing_size])
    if value >= 1 << @bit_len || value < -(1 << @bit_len)
      raise StandardError.new("Label '#{@sym.to_s}' is too far for relative expression")
    end
    bit_exp(value)
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
    if env[:labels][@sym].nil? or env[:labels][@sym][:location].nil?
      raise StandardError.new("Label '#{@sym.to_s}' is not found.")
    end
    value = env[:labels][@sym][:location]
    if value >= 1 << @bit_len || value < -(1 << @bit_len)
      raise StandardError.new("The address of Label '#{@sym.to_s}' is too large for the width of absolute labels")
    end
    bit_exp(value)
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
      if @int >= 1 << @bit_len || @int < -(1 << @bit_len)
        raise StandardError.new("Immediate '#{@int}' is too large for the bit width: #{@bit_len}")
      end
      bit_exp(@int)
    else
      label = LabelAbsolute.new(@label)
      label.bit_len = @bit_len
      label.encode(env)
    end
  end

  def self.type_accept?(type)
    type == Fixnum || type == Symbol || type == Float
  end

  def ftoi(f)
    [f].pack("f").unpack("l")[0]
  end

end

class UnsignedImmediate < Immediate

  def encode(env)
    unless @int.nil?
      if @int >= 1 << (@bit_len + 1) || @int < 0
        raise StandardError.new("UnsignedImmediate '#{@int}' is too large for the bit width: #{@bit_len}")
      end
      bit_exp(@int)
    else
      label = LabelAbsolute.new(@label)
      label.bit_len = @bit_len
      label.encode(env)
    end
  end

end

