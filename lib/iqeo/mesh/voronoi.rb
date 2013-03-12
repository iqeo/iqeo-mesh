module Iqeo
module Mesh

class Voronoi

  # todo: Voronoi class is graph-like ? look for commonalities with Mesh to extract into a superclass

  attr_reader :cells, :edges, :points

  def initialize
    @cells = Set.new
    @edges = Set.new
    @points = Set.new
  end

end

end
end
