module Iqeo
module Mesh

class Point

  include Comparable

  attr_reader :x, :y

  def initialize x, y
    @x, @y = x, y
  end

  def hash
    # also determines order for <=> by y then x coordinates
    @hash ||= ( @y << 16 ) + @x
  end

  def eql? other
    hash == other.hash ? true : false
  end

  def == other
    eql? other
  end

  def <=> other
    hash <=> other.hash
  end

end

end
end
