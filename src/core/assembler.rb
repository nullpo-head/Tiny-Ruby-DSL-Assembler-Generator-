DIR = File.dirname(__FILE__)
SPEC_DIR = DIR + "/../spec_dsl/"

require_relative "../core/eval_inst_type_dsl"
require_relative "../core/eval_registers_dsl"
require_relative "../core/eval_operations_dsl"
require_relative "../core/eval_arch_dsl"
require_relative "../core/operand_types"

$arch = {address_size: 0, data_size: 0, instruction_length: 0}

class Assembler

  def initialize
    @jail_class = Class.new AssemblyEvalJail
    specify = method(:specify)
    Object.instance_eval {
      define_method("spec") do |target, &specification|
        specify.call(target, specification)
      end
    }
    load "#{SPEC_DIR}/arch_dsl.rb"
    load "#{SPEC_DIR}/register_dsl.rb"
    load "#{SPEC_DIR}/inst_type_dsl.rb"
    load "#{SPEC_DIR}/operations_dsl.rb"
  end

  def assemble(filenames)
    jails, state = load_assembly_in_jail(filenames)
    format encode_to_hash(jails, state)
  end

  def format(encoded)
    res = {ascii_with_metadata: "", ascii: "", binary: encoded.map {|e| [e[:bits]].pack("B*")}.join("")}
    encoded.each do |inst|
      res[:ascii_with_metadata] += "#{inst[:bits]}  ##{inst[:metadata][:filename]}:#{inst[:metadata][:line_no]}\n"
      res[:ascii] += inst[:bits] + "\n"
    end
    res
  end

  def load_assembly_in_jail(filenames)
    env = {instruction: nil, labels: nil, base_addr: 0, base_addrs: [0], exported_labels: {}}
    jails = filenames.map do |filename|
        @jail_class.new.eval File.open(filename)
    end
    jails.each.with_index do |jail, i|
      env[:base_addrs][i + 1] = env[:base_addrs][i] + (jail.instructions.length * $arch[:instruction_length] / $arch[:addressing_size]) 
      jail.global_labels.each do |k, v|
        v[:location] += env[:base_addrs][i]
      end
      env[:exported_labels].merge! jail.global_labels
    end
    [jails, env]
  end

  def encode_to_hash(jails, env)
    res = []
    jails.each.with_index do |jail, i|
      env[:instruction] = jail.instructions
      env[:labels] = jail.labels
      env[:base_addr] = env[:base_addrs][i]
      res.push jail.instructions.map.with_index {|inst, j|
        env[:location] = j
        inst.encode(env)
      }
    end
    res.flatten!
  end

  def specify(target, specification)
    case target
    when "architecture"
      arch_specifier = ArchitectureSpecifier.new
      arch_specifier.specify(specification)
      $arch = arch_specifier.arch
    when "registers"
      RegistersSpecifier.new(@jail_class).specify(specification)
    when "instruction type"
      InstructionTypeSpecifier.new().specify(specification)
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
    @export_label_syms = []
  end

  def eval(src_or_file)
    if src_or_file.class == File
      instance_eval src_or_file.read, File.basename(src_or_file.path)
      src_or_file.close
    else
      instance_eval src_or_file
    end
    self
  end

  def label(sym)
    @labels[sym] = {location: @instructions.length}
  end

  def global_labels
    @export_labels ||= Hash[*@export_label_syms.map {|sym|
      raise StandardError.new("The '#{sym}' label is declared as global, but there is no such label.") if @labels[sym].nil?
      [sym, @labels[sym].dup]
    }.flatten(1)]
  end

  # directives
  def dot_globl(label)
    @export_label_syms.push label
  end

end

