class ArchitectureSpecifier

  attr_reader :arch

  def initialize()
    @arch = {address_size: 0, data_size: 0, instruction_length: 0}
  end

  def specify(block)
    instance_eval(&block)
  end

  def addressing_size(size)
    @arch[:addressing_size] = size
  end

  def data_size(size)
    @arch[:data_size] = size
  end

  def instruction_length(len)
    @arch[:instruction_length] = len
  end

end

