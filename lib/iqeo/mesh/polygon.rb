module Iqeo
module Mesh

class Polygon

  include PointUtilities

  PRECISION = 8

  attr_reader :points, :directed_edges, :radius2, :center, :center_exact_x, :center_exact_y

  def initialize mesh, pointy_things
    # fix: initializes for 3 points only due to clockwise, extend to n points
    @mesh = mesh
    @points = clockwise unique_points pointy_things
    raise 'points are collinear' if @points.nil?
    calculate_circumcircle
    @directed_edges = directed_edges_for @points
    update_edges_polygons edges
  end

  def edges
    @directed_edges.collect(&:edge)
  end

  def insert_points at, points
    @points.insert @points.index( at ), *points
  end

  def delete_points points
    points.each { |p| @points.delete p }
  end

  def insert_directed_edges at, directed_edges
    @directed_edges.insert @directed_edges.index( at ), *directed_edges
    update_edges_polygons directed_edges.collect(&:edge)
  end

  def update_edges_polygons edges_to_update
    edges_to_update.each { |edge| edge.polygons.add self }
  end

  def delete_directed_edges directed_edges
    directed_edges.collect(&:edge).each { |edge| edge.polygons.delete self }
    @directed_edges.delete_if { |de| directed_edges.include? de }
  end

  def outside? point
    # outside point could be left or right of directed edges, so invert inside? instead
    ! inside? point
  end

  def inside? point
    # inside point is right of all directed edges
    @directed_edges.all? do |de|
      r = de.right?(point)
      c = de.contains?(point)
      r || c
    end
  end

  def edges_visible_to_outside_point point
    directed_edges_visible_to_outside_point( point ).collect(&:edge)
  end

  def directed_edges_visible_to_outside_point point
    raise 'point is not outside' unless outside? point
    # returns [directed edges...] for outside point, [] for inside point
    # visible directed edges (v) are a single contiguous group (...vvv...) but may wrap around (vvv...vvv) the edge list
    # for (vvv...vvv) head and tail lists contain visible edges, tail + head = contiguous list of edges
    # for (vvv......) head list contains visible edges, tail list is empty, tail + head == head
    # for (...vvv...) & (......vvv) head list is empty, tail list contain visible edges, tail + head == tail
    visible_directed_edges_head = @directed_edges.take_while { |edge| edge.left? point }
    invisible_directed_edges    = @directed_edges[visible_directed_edges_head.size..-1].take_while { |edge| edge.right? point }
    visible_directed_edges_tail = @directed_edges[(visible_directed_edges_head.size+invisible_directed_edges.size)..-1].take_while { |edge| edge.left? point }
    visible_directed_edges_tail + visible_directed_edges_head
  end

  def expand point, directed_edges_visible = nil
    directed_edges_visible = directed_edges_visible_to_outside_point point unless directed_edges_visible
    expansion_start_point = directed_edges_visible.first.start
    expansion_finish_point = directed_edges_visible.last.finish
    remove_section directed_edges_visible
    insert_point_between expansion_start_point, point, expansion_finish_point
  end

  def split point
    edges.collect do |edge|
      edge.polygons.delete self
      Polygon.new @mesh, [ edge, point ] unless collinear? edge.points + [ point ]
    end.compact
  end

  def border_directed_edges polygon
    directed_edges.select { |de| de.edge.polygons.include? polygon }
  end

  def merge triangle
    if ( border_directed_edge = border_directed_edges(triangle).first )
      @mesh.triangles.delete triangle
      @mesh.edges.delete border_directed_edge.edge
      triangle.edges.each { |e| e.polygons.delete triangle }
      far_point = ( triangle.points - border_directed_edge.edge.points ).first
      expand far_point, [ border_directed_edge ]
    end
    border_directed_edge.edge
  end

  def neighbors
    # edges know which polygons (only 1 or 2) they are part of, collect polygons excluding self
    #  reject nils for edges along outside of mesh as they have no (other) polygons
    edges.collect { |edge| edge.polygons.detect { |polygon| polygon != self  } }.reject(&:nil?)
  end

  def calculate_circumcircle
    if ( a = @points.detect { |p| p.x == 0 && p.y == 0 } )
      # triangle already at origin
      b, c = @points - [ a ]
    else
      # translate triangle via first point to origin
      a = @points[0]
      b = Point.new @points[1].x-a.x, @points[1].y-a.y
      c = Point.new @points[2].x-a.x, @points[2].y-a.y
    end
    # calculate translated circumcenter with simplified formula for a = 0
    d = ( b.x * c.y - b.y * c.x ) * 2
    b2 = b.x**2 + b.y**2
    c2 = c.x**2 + c.y**2
    ux = ( c.y * b2 - b.y * c2 ) / d.to_f # division in floating point for precise circumcircle center and radius
    uy = ( b.x * c2 - c.x * b2 ) / d.to_f # division in floating point for precise circumcircle center and radius
    # calculate radius squared while we're still at origin
    @radius2 = ( ux**2 + uy**2 ).round PRECISION
    # translate back to actual circumcenter
    @center_exact_x = ( ux+a.x ).round PRECISION
    @center_exact_y = ( uy+a.y ).round PRECISION
    @center = Point.new @center_exact_x.to_i, @center_exact_y.to_i
  end

  def circumcircle_contains point
    ( ( point.x - @center_exact_x ) **2 + ( point.y - @center_exact_y ) **2 ).round( PRECISION ) < @radius2
  end

  def check
    res = {}
    des = @directed_edges
    res[:directed_edges_okay] = ! des.detect { |de| ! de.check? }
    res[:directed_edges_enclose] = des[0].start == des[2].finish && des[1].start == des[0].finish && des[2].start == des[1].finish
    # todo: directed_edges_clockwise , points_okay ?, points_consistent
    res
  end

  def check?
    ! check.values.include? false
  end

  private

  def directed_edges_for points
    # assumes points are sorted clockwise - join points with edges
    points.each_cons(2).collect do |p_start,p_finish|
      DirectedEdge.new @mesh.new_or_existing_edge( Edge.new( p_start, p_finish ) ), p_start
    end << DirectedEdge.new( @mesh.new_or_existing_edge( Edge.new( points.last, points.first ) ), points.last ) # edge for last to first point to close loop
  end

  def remove_section directed_edges
    delete_directed_edges directed_edges
    points = directed_edges.collect { |de| de.start } # first points of edges (we don't delete last point of last edge, it also belongs to an edge we will keep)
    points.shift                                      # don't delete first point (it also belongs to an edge we will keep)
    delete_points points                              # beware! this polygon is now 'open'
  end

  def insert_point_between start, point, finish
    # todo: we could use a linked list for this (.before, .after, .between, etc..)
    insert_points finish, [ point ]
    directed_edge_after_break = @directed_edges.detect { |e| e.start == finish }
    directed_edges_to_insert = [
      DirectedEdge.new( @mesh.new_or_existing_edge( Edge.new( start, point ) ), start ),
      DirectedEdge.new( @mesh.new_or_existing_edge( Edge.new( point, finish ) ), point )
    ]
    insert_directed_edges directed_edge_after_break, directed_edges_to_insert
  end

end

end
end
