
class Item
  attr_accessor :line
  attr_accessor :children

  def parse raw
    takeLines! self.class.indentScan raw
  end

  def takeLines! aoh
    return if aoh.empty?
    @children = [ ]
    min = aoh.map{ _1[:indent] }.min
    aoh = aoh.clone
    while i = aoh.rindex{ _1[:indent] == min }
      head = aoh.slice!(i)
      rest = aoh.slice!(i..)
      newitem = Item.new
      newitem.line = head[:line]
      newitem.takeLines! rest
      @children.unshift newitem
    end
    unless aoh.empty?
      raise SyntaxError,
        "broken indent:\n#{aoh.map{_1[:line]}.join("\n")}"
    end
    self
  end

  def inspect
    self.class.to_s self
  end

  def self.to_s o, indent:2
    l = "#{o.line ? o.line : o.line.inspect}\n"
    if o.children
      l += o.children
        .map{ to_s _1, indent:indent }
        .join
        .gsub(/^/, ' ' * indent)
    end
    l
  end

  def self.indentScan raw
    raw.each_line.map do
      l = _1.partition(/\s\#|\#\s/).first
      i = (l =~ /[^ ]/)
      l.strip!
      unless l.empty?
        { indent:i, line:l }
      end
    end.compact
  end
end

