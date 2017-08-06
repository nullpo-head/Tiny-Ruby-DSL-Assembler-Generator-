DIR = File.dirname(__FILE__)
SPEC_DIR = DIR + "/../spec_dsl/"

require_relative "../core/eval_inst_type_dsl"
require_relative "../core/eval_registers_dsl"
require_relative "../core/eval_operations_dsl"
require_relative "../core/eval_arch_dsl"
require_relative "../core/operand_types"

$arch = {address_size: 0, data_size: 0, instruction_length: 0, endian: :big}

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
    jails = prepare_assembler_jail(filenames)
    global_labels = jails.inject({}) {|acc, jail| acc.merge! jail.global_labels}
    format encode(jails, global_labels)
  end

  def format(encoded)
    res = {ascii_with_metadata: "", ascii: "", binary: encoded.map {|e| [e[:bits]].pack("B*")}.join("")}
    encoded.each do |inst|
      res[:ascii_with_metadata] += "#{inst[:bits]}  ##{inst[:metadata][:filename]}:#{inst[:metadata][:line_no]}\n"
      res[:ascii] += inst[:bits] + "\n"
    end
    res
  end

  def prepare_assembler_jail(filenames)
    base_addr = 0
    jails = []
    filenames.each do |filename|
      jail = @jail_class.new(base_addr)
      jail.eval File.open(filename)
      base_addr = jail.end_addr
      jails.push jail
    end
    jails
  end

  def convert_endian(bits)
    return bits if $arch[:endian] == :big
    bits[:bits] = bits[:bits].scan(/.{1,#{$arch[:addressing_size]}}/).reverse.join("")
    bits
  end

  def encode(jails, global_labels)
    state = {location: 0, labels: nil, base_addr: 0}
    res = []
    jails.each.with_index do |jail, i|
      state[:labels] = jail.labels.merge global_labels
      state[:base_addr] = jail.base_addr
      res.push jail.instructions.map.with_index {|inst, j|
        state[:location] = j * $arch[:instruction_length]
        convert_endian(inst.encode(state))
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
  attr_accessor :instructions, :labels, :base_addr

  def initialize(base_addr)
    @instructions = []
    @labels = {}
    @export_label_syms = []
    @base_addr = base_addr
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

  def end_addr
    @instructions.length * $arch[:instruction_length] / $arch[:addressing_size] + @base_addr
  end

  def label(sym)
    @labels[sym] = {location: @instructions.length * $arch[:instruction_length] / $arch[:addressing_size] + @base_addr}
  end

  def global_labels
    @global_labels if @global_labels
    @global_labels = {}
    @export_label_syms.each do |sym|
      raise StandardError.new("The '#{sym}' label is declared as global, but there is no such label.") if @labels[sym].nil?
      @global_labels[sym] = @labels[sym]
    end
    @global_labels
  end

  # directives
  def dot_globl(label)
    @export_label_syms.push label
  end

end

