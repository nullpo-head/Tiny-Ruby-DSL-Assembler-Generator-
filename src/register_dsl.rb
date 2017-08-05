spec "registers" do

  register "zero", 0
  register "at", 1
  register "v0", 2
  register "v1", 3
  4.times {|i|
    register "a#{i}", i + 4
  }
  8.times {|i|
    register "t#{i}", i + 8
  }
  8.times {|i|
    register "s#{i}", i + 16
  }
  2.times {|i|
    register "t#{i+8}", i + 24
  }
  2.times {|i|
    register "k#{i}", i + 26
  }
  register "gp", 28
  register "sp", 29
  register "fp", 30
  register "ra", 31

  32.times {|i|
    register "r#{i}", i
  }
  32.times {|i|
    register "f#{i}", i
  }
end
