DIR = File.dirname(__FILE__)

require "#{DIR}/eval_inst_type_dsl"
require "#{DIR}/eval_registers_dsl"
require "#{DIR}/eval_operations_dsl"
require "#{DIR}/operand_types"

INSTRUCTION_BIT_LENGTH = 32

class Assembler

  def initialize
    @jail_class = Class.new AssemblyEvalJail
    specify = method(:specify)
    Object.instance_eval {
      define_method("spec") do |target, &specification|
        specify.call(target, specification)
      end
    }
    load "#{DIR}/register_dsl.rb"
    load "#{DIR}/inst_type_dsl.rb"
    load "#{DIR}/operations_dsl.rb"
  end

  def assemble(filename)
    jail = @jail_class.new
    jail.eval File.read(filename)
    env = {instructions: jail.instructions, labels: jail.labels}
    jail.instructions.map.with_index {|inst, i|
      env[:location] = i
      inst.encode(env)
    }.join("\n")
  end

  def specify(target, specification)
    case target
    when "instruction type"
      InstructionTypeSpecifier.new().specify(specification)
    when "registers"
      RegistersSpecifier.new(@jail_class).specify(specification)
    when "operations"
      OperationsSpecifier.new(@jail_class).specify(specification)
    end
  end

end

class AssemblyEvalJail
  attr_accessor :instructions, :labels

  def initialize
    @instructions = []
    @labels = {}
  end

  def eval(src)
    instance_eval src
  end

  def label(sym)
    @labels[sym] = {location: @instructions.length}
  end

end

