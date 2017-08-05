class RegistersSpecifier

  def initialize(eval_jail)
    @eval_jail = eval_jail
  end

  def specify(block)
    instance_eval(&block)
  end

  def register(name, num)
    @eval_jail.instance_eval do
      define_method(name) {Reg.new num}
    end
  end

end

