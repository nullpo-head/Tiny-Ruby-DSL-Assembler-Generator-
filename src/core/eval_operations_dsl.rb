class OperationsSpecifier

  def initialize(eval_jail)
    @eval_jail = eval_jail
  end

  def specify(block)
    instance_eval(&block)
  end
  
  def op(instruction)
    @eval_jail.instance_eval {
      define_method(instruction[:name]) {|*args|
        instructions.push instruction[:class_object].new(*args)
      }
    }
  end

  def raw(inst_name)
    @eval_jail.instance_eval {
      define_method(inst_name) {|data|
        instructions.push RawDataInstruction.new(data)
      }
    }
  end

  def macro(inst_name, &block)
    @eval_jail.instance_eval {
      define_method(inst_name, &block)
    }
  end

  def method_missing(name, *args)
    capitalize_first = -> str {str.split('').map.with_index {|c, i| i == 0 ? c.upcase : c}.join("")}
    inst_type_name = capitalize_first.call(name.to_s) + "Instruction"
    begin
      inst_type_module = Object.const_get(inst_type_name)
      op_class = Class.new
      op_class.method(:include).call(inst_type_module)
      op_class.instance_eval do
        define_method(:mnemonic) do
          args[1]
        end
      end
      op_class.instance_eval do
        define_method(:function) do 
          args[2] ? args[2] : nil
        end
      end
      Object.const_set(capitalize_first.call(args[0].to_s) + "Instruction", op_class)
      {name: args[0].to_s, class_object: op_class}
      
    rescue NameError => e
      puts "error in method_missing in eval_operations_dsl.rb: #{e}"
      exit
    end
  end

end


