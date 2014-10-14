
module InstructionType

  def initialize(*args)
    type_strict args, operand_types 
    @operands = prepare_operand_objs(args)
  end

  def encode(env)
    encode_f.call(*([mnemonic] + @operands.map {|op| op.encode(env)}))
  end

  def type_strict(args, types)
    accpeted = args.length == types.length and args.zip(types).all? {|arg, type| type.type_accept? arg.class}
    raise StandardError.new("Invalid operand error for #{self.class.name}") unless accpeted
  end

  def prepare_operand_objs(args)
    result = []
    types = operand_types
    args.length.times do |i|
      if types[i] != args[i].class
        result.push types[i].new args[i]
      else
        result.push args[i]
      end
      result[-1].bit_len= bit_len[i]
    end
    result
  end

end


class InstructionTypeSpecifier

  def specify(block)
    instance_eval(&block)
  end

  def type(type_name, &specification)
    m = Module.new
    m.method(:include).call(InstructionType)
    builder = InstructionTypeModuleBuilder.new(m)
    builder.instance_eval(&specification)
    Object.const_set(type_name + "Instruction", builder.mod)
  end

  class InstructionTypeModuleBuilder

    attr_reader :mod
    
    def initialize(mod)
      @mod = mod
    end

    def operand_type(*types)
      @mod.module_eval {define_method(:operand_types, lambda{types})}
    end

    def bit_length(*length)
      @mod.module_eval {define_method(:bit_len, lambda{length})}
    end

    def encode(&encode_f)
      @mod.module_eval {define_method(:encode_f, lambda{encode_f})}
    end

  end

end


module RawDataInstructionType
  include InstructionType

  def operand_types
    [Immediate]
  end

  def bit_len
    [INSTRUCTION_BIT_LENGTH]
  end

  def encode_f
    lambda {|mnemonic, val| val}
  end
end

class RawDataInstruction
  include RawDataInstructionType

  def mnemonic
    ""
  end
end
