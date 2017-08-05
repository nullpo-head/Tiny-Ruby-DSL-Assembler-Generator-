
module InstructionType

  def initialize(*args)
    type_strict args, operand_types 
    @operands = prepare_operand_objs(args)
    @metadata = {line_no: get_src_info[0], filename: get_src_info[1]}
  end

  def encode(env)
    operand_bits = @operands.map {|op|
      if op.name.end_with?("lower")
        op.encode(env)[-16..-1]
      elsif op.name.end_with?("higher")
        op.encode(env)[-32..-17]
      elsif op.name.end_with?("fullwidthbits")
        op.encode(env)[-32..-1]
      else
        op.encode(env)[(-op.bit_len)..-1]
      end
    }
    {bits: encode_f.call(*([mnemonic] + operand_bits)), metadata: @metadata}
  end

  def type_strict(args, types)
    accpeted = args.length == types.length && args.zip(types).all? {|arg, type| type.type_accept? arg.class}
    raise StandardError.new("Invalid operand type error for #{self.class.name}") unless accpeted
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
      result[-1].name= operand_names[i]
    end
    result
  end

  def get_src_info
    traces = caller.map{|trace| trace.split(":")}
    srcfile_trace = traces.select{|trace| (trace[0] =~ /.*dsl.rb/).nil?} # Dirty hard coding. Fix this.
    [srcfile_trace.first[0], srcfile_trace.first[1]]
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
      @mod.module_eval {define_method(:operand_types, lambda {types})}
    end

    def bit_length(*length)
      @mod.module_eval {define_method(:bit_len, lambda {length})}
    end

    def encode(&encode_f)
      @mod.module_eval {define_method(:encode_f, lambda {encode_f})}
      param_names = encode_f.parameters.map {|is_req, name| name.to_s}
      @mod.module_eval {define_method(:operand_names, lambda {param_names[1..-1]})} # remove 'mnemonic'
    end

  end

end

# Op for embedding raw data, you can refer this as an example of what module is generated by methods like "rtype :raw, '000000'"

module RawDataInstructionType
  include InstructionType

  def operand_names
    ["val_fullwidthbits"]
  end

  def operand_types
    [Immediate]
  end

  def bit_len
    [INSTRUCTION_BIT_LENGTH]
  end

  def encode_f
    lambda {|mnemonic, val_fullwidthbits| val_fullwidthbits}
  end
end

# Op for embedding raw dara, you can refer this as an example of what class is generated by DSL like "op footype :raw, '000000'"

class RawDataInstruction
  include RawDataInstructionType

  def mnemonic
    ""
  end
end
