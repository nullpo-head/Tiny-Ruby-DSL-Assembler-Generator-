require 'tempfile'

class Converter
  def convert(filename)
    @temp = Tempfile::new(File.basename(filename))
    File.open(filename){|f|
      while line = f.gets
        offset = line.index(/\S/)
        if offset != nil then
          if line[offset] == "." then
            line.sub!(".") {"dot_"}
          else
            if line[offset,offset+1] == "or" && line[offset+2] != "i" then
              line.sub!("or") {"or_"}
            end
            if line[offset,offset+1] == "and" && line[offset+2] != "i" then
              line.sub!("and") {"and_"}
            end
            line.sub!("c.ole") {"c_dot_ole"}
            line.sub!("c.olt") {"c_dot_olt"}
            line.sub!("c.oeq") {"c_dot_oeq"}
            line.sub!("c.eq")  {"c_dot_eq"}
            line.sub!("add.s") {"add_dot_s"}
            line.sub!("sub.s") {"sub_dot_s"}
            line.sub!("mul.s") {"mul_dot_s"}
            line.sub!("div.s") {"div_dot_s"}
            line.sub!("abs.s") {"abs_dot_s"}
            line.sub!("mov.s") {"mov_dot_s"}
            line.sub!("inv.s") {"add_dot_s"}
            line.sub!("neg.s") {"neg_dot_s"}
          end
        end
        @temp.write(line)
      end
    }
    @temp.close
    @temp.open
    @temp
  end

  def close()
    @temp.close
  end
end
