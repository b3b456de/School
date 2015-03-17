#Samuel Spry
#Hw 03
#Doesn't work, should work if the parser works.  But the parser doesn't generate a valid tree

#todo
#  write the parser
#    Create tree
#    Test Tree
#  test eval function


# .chr() transfer int value to character value  42.chr() == *

class Lex
  def initialize
    @pos = 0
    @tokens = ""
  end

  #read in string of tokens
  def st_lex(raw)
    @tokens = raw.delete(' ').gsub("\n", '')
  end

  def next
    @pos +=1
    if(@pos - 1) < @tokens.length
      return lex_anly(@tokens[@pos-1].chr())
    else
      return nil
    end
  end

  #returns false if check contains any invalid tokens
  def lex_anly(check)
    case check
      when '('
        return "LPAREN", '('
      when ')'
        return "RPAREN", ')'
      when "0".."9"
        number = ""
        #displacement variable
        dis = 0
        if /[1-9]/.match(check)
          number << check
          check = @tokens[@pos]
          while /[0-9]/.match(check)
            number << check
            dis += 1
            check = @tokens[@pos + dis]
          end
          if check == "."
            number << check
            dis += 1
            check = @tokens[@pos+dis]
          else
            @pos += dis
            return "NUMBER", number
          end
          while /[0-9]/.match(check)
            number << check
            dis+=1
            check = @tokens[@pos+dis]
          end
          @pos += dis
          return "NUMBER", number
        end
        return "NUMBER", number
      when '/'
        return "DIV", '/'
      when '+'
        return "ADD", '+'
      when "*"
        return "MUL", "*"
      when "-"
        return "MIN", "-"
      else
        print("lexical error ")
        print(check)
        print(" is not a valid token")
        return "INVALID", check
    end
  end
end

class Parse
  def initialize
    @root = Tree.new("prog")
  end
  def gen_tree(lex)
    look_ahead = lex.next
    while look_ahead != nil
      current = look_ahead
      look_ahead = lex.next
      expr(current, look_ahead,@root)
    end
  end
  def expr(token, look_ahead,node)
    node.data = Tree.new("expr")
    if look_ahead[0] != "MIN" or look_ahead[0] != "ADD"
      node.center = term(token, look_ahead,node.center)
      return node.center
    else
      node.left = expr(token, look_ahead,node.left)
      node.center = add_op(token, look_ahead, node.center)
      node.right = term(token, look_ahead, node.right)
    end
  end
  def term(token, look_ahead,node)
    node.data = Tree.new("term")
    if look_ahead[0] != "MUL" or look_ahead[0] != "DIV"
      node.center = factor(token, look_ahead,node.center)
      return node.center
    else
      node.left = term(token, look_ahead,node.left)
      node.center = mul_op(token, look_ahead, node.center)
      node.right = factor(token, look_ahead, node.center)
    end
  end
  def factor(token, look_ahead,node)
    node.data = Tree.new("factor")
    if token[0] == "NUMBER"
      node.center = number(token, look_ahead,node.center)
    else
      node.right = Tree.new("(")
      node.center = expr(token,look_ahead, node.center)
      node.left = Tree.new(")")
    end
  end
  def add_op(token, look_ahead,node)
    if token == "MIN"
      node.data = "MIN"
      node.center = new Tree("-")
    elsif token == "ADD"
      node.data = "ADD"
      node.center = new Tree("+")
    else
      puts "Semantic Error"
      return nil
    end
  end
  def mul_op(token, look_ahead,node)
    if token =="MUL"
      node.data = "MUL"
      node.center = new Tree("*")
    elsif token == "DIV"
      node.data = "DIV"
      node.center = new Tree("/")
    else
      puts "Syntactic Error"
      return nil
    end
  end
  def number(token, look_ahead,node)
    if token == "NUMBER"
      node.data = "NUMBER"
      node.center = new Tree(token[1])
    elsif
      puts "Syntactic Error"
      return nil
    end
  end

  def evtree
    eval_tree(@root)
  end

  def eval_tree(node)
    if node == nil
      return
    end
    if node.left == nil && node.right == nil
      return eval_tree(node.center)
    elsif node.left.data == "(" && node.right.data == ")"
      return eval_tree(node.center)
    elsif node.center.data = "add_op"
      if node.center.center.data == "+"
        return eval_tree(node.left) + eval_tree(node.right)
      elsif node.center.center.data =="-"
        return eval_tree(node.left) - eval_tree(node.right)
      else
        return "Error"
      end
    elsif node.center.data ="mul_op"
      if node.center.center.data == "*"
        return eval_tree(node.left) * eval_tree(node.right)
      elsif node.center.center.data == "/"
        return eval_tree(node.left) / eval_tree(node.right)
      else
        return "Error"
      end
    elsif node.center.data = "number"
      return node.center.center.data.to_f
    else
      return "Error"
    end
  end
end

class Tree
  attr_accessor :left
  attr_accessor :center
  attr_accessor :right
  attr_accessor :data
  def initialize(v=nil)
    @left = nil
    @center = nil
    @right = nil
    @data = v
  end
end

analyze = Lex.new
parser = Parse.new
parse = true
#while loop doesn't do anything, yet
while(parse)
  parse = false
  print("Enter an expression to parse: ")
  input = gets.chomp
  analyze.st_lex(input)
  for i in 1..5 do
    puts analyze.next
  end
  parser.gen_tree(analyze)
  parser.evtree
end
