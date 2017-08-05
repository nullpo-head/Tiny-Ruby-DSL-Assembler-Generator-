# -*- coding: utf-8 -*-
spec "operations" do
  
  op rtype :add,             "100000"
  op rtype :sub,             "100010"
  op rtype :and_,            "100100"  # Use 'and_' because 'and' op conflicts with ruby's AND operator.
  op rshift :sllv,           "000100" 
  op rshift :srlv,           "000110" 
  op rtype :jr_rt,           "001000"
  op rtype :jalr_rt,         "001001"
  op rtype :nor,             "100111"
  op rtype :or_,             "100101"  # Use 'or_' because 'or' op conflicts with ruby's OR operator.
  op rtype :xor,             "100110"


  op itype :addi,            "001000"
  op itype :ori,             "001101"


  op jtype :j,               "000010"
  op jtype :jal,             "000011"

  op branch :beq,            "000100"
  op branch :bne,            "000101"
  op branch :bgt,            "000111"
  op branch :ble,            "000110"

  op mem :lw,                "100011"
  op mem :sw,                "101011"
  op mem :swc1,              "111001"
  op mem :lwc1,              "110001"

  op io :read,               "011000"
  op io :write,              "011001"

  op shift :sll,             "000000"
  op shift :srl,             "000010"
  op shift :sra,             "000011"


  op itypeHigher :addi_high, "001000"

  op fRtype :add_dot_s,      "000000"
  op fRtype :fadd,           "000000"
  op fRtype :sub_dot_s,      "000001"
  op fRtype :fsub,           "000001"
  op fRtype :mul_dot_s,      "000010"
  op fRtype :fmul,           "000010"
 #op fRtype :fdiv,           "000011"

  op fItype :abs_dot_s,      "000101"
  op fItype :fabs,           "000101"
  op fItype :mov_dot_s,      "000110"
  op fItype :fmov,           "000110"
  op fItype :neg_dot_s,      "000111"
  op fItype :finv,           "001000" # MIPSにはないので適当なオペコード
  op fItype :inv_dot_s,      "001000"


  op fCtype :c_dot_oeq,      "0010"
  op fCtype :c_dot_eq,       "0010"
  op fCtype :c_dot_olt,      "0100"
  op fCtype :c_dot_ole,      "0110"

  op fMtype :mfc1,           "00000"
  op fMtype :mtc1,           "00100"

  op fBranch :bc1f,          "0"
  op fBranch :bc1t,          "1"

  raw :val

  macro :jr do |rs|
    jr_rt zero, rs, zero
  end
  
  macro :jalr do |rd_rs, rs = nil|
    if rs.nil?
      rd = r31
      rs = rd_rs
    else
      rd = rd_rs
    end
    jalr_rt rd, rs, zero
  end

  macro :li do |rd, immediate|
    addi rd, zero, immediate
  end

  macro :subi do |rd, rs, immediate|
    addi rd, rs, -immediate
  end

  macro :move do |rd, rs|
    add rd, rs, zero
  end

  macro :neg do |rd, rs|
    sub rd, zero, rs
  end

  macro :b do |target|
    j target
  end

  macro :lui do |rt, immediate|
    addi_high rt, zero, immediate
    sll rt, rt, 16
  end

  macro :la do |rt, label|
    lui rt, label
    ori rt, rt, label
  end

  macro :fneg do |ft, fs|
    neg_dot_s ft, fs
  end

  macro :fdiv do |fd, fs, ft|
    finv ft, ft
    fmul fd, fs, ft
  end
  
  macro :div_dot_s do |fd, fs, ft|
    fdiv fd, fs, ft
  end

# macro :fsub do |fd, fs, ft|
#   fneg f31, ft
#   fadd fd, fs, f31
# end

end
