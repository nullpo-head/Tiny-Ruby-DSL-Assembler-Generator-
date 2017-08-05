spec "instruction type" do

  type "Rtype" do
    operand_type Reg, Reg, Reg
    bit_length 5, 5, 5
    encode {|mnemonic, rd, rs, rt|
      "000000" + rs + rt + rd + "00000" + mnemonic
    }
  end

  type "Rshift" do
    operand_type Reg, Reg, Reg
    bit_length 5, 5, 5
    encode {|mnemonic, rd, rt, rs|
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

  type "ItypeHigher" do
    operand_type Reg, Reg, Immediate
    bit_length 5, 5, 16
    encode {|mnemonic, rt, rs, imm_higher| # an operand which ends with 'higher' passes higher 16bits
      mnemonic + rs + rt + imm_higher
    }
  end

  type "FRtype" do
    operand_type Reg, Reg, Reg
    bit_length 5, 5, 5
    encode {|mnemonic, fd, fs, ft|
      "010001" + "10000" + ft + fs + fd + mnemonic
    }
  end

  type "FItype" do #1-ary
    operand_type Reg, Reg
    bit_length 5, 5
    encode {|mnemonic, fd, fs|
      "010001" + "10000" + "00000" + fs + fd + mnemonic
    }
  end

  type "FCtype" do #compare
    operand_type Reg, Reg
    bit_length 5, 5
    encode {|mnemonic, fs, ft|
      "010001" + "10000" + ft + fs + "000" + "00" + "11" + mnemonic
    }
  end

  type "FMtype" do #move between GPR and FPR
    operand_type Reg, Reg
    bit_length 5, 5
    encode {|mnemonic, rt, fs|
      "010001" + mnemonic + rt + fs + "00000" + "000000"
    }
  end

  type "FBranch" do #branch
    operand_type LabelRelative
    bit_length 16
    encode {|flag, offset|
      "010001" + "01000" + "000" + "0" + flag + offset
    }
  end
end
