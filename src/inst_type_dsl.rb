spec "instruction type" do
  
  type "Rtype" do
    operand_type Reg, Reg, Reg
    bit_length 5, 5, 5
    encode {|mnemonic, rd, rs, rt|
      "000000" + rs + rt + rd + "00000" + mnemonic
    }
  end

  type "Itype" do
    operand_type Reg, Reg, Immediate
    bit_length 5, 5, 16
    encode {|mnemonic, rt, rs, imm|
      mnemonic + rs + rt + imm
    }
  end

  type "Jtype" do
    operand_type LabelAbsolute
    bit_length 26
    encode {|mnemonic, target|
      mnemonic + target
    }
  end

  type "Branch" do
    operand_type Reg, Reg, LabelRelative
    bit_length 5, 5, 16
    encode {|mnemonic, rs, rt, offset|
      mnemonic + rs + rt + offset
    }
  end

  type "Mem" do
    operand_type Reg, Immediate, Reg
    bit_length 5, 16, 5
    encode {|mnemonic, rt, offset, base|
      mnemonic + base + rt + offset
    }
  end

  type "Io" do
    operand_type Reg
    bit_length 5
    encode {|mnemonic, rt|
      mnemonic + "00000" + rt + "0000000000000000"
    }
  end

  type "Shift" do
    operand_type Reg, Reg, Immediate
    bit_length 5, 5, 5
    encode {|mnemonic, rd, rt, sa|
      "000000" + "00000" + rt + rd + sa + mnemonic
    }
  end

end
