spec "operations" do
  
  op rtype :add,   "100000"
  op rtype :sub,   "100010"
  op rtype :and,   "100100"
  op rtype :jr_rt, "001000"
  op rtype :nor,   "100111"

  op itype :addi,  "001000"

  op jtype :j,     "000010"
  op jtype :jar,   "000011"

  op branch :beq,  "000100"
  op branch :bne,  "000101"
  op branch :bgtz, "000111"
  op branch :blez, "000110"

  op mem :lw,      "100011"
  op mem :sw,      "101011"

  op io :read,     "011000"
  op io :write,    "011001"

  op shift :sll,   "000000"
  op shift :srl,   "000010"

  raw :val

  macro :jr do |target|
    jr_rt zero, target, zero
  end

  macro :li do |rd, immediate|
    addi rd, zero, immediate
  end

end
