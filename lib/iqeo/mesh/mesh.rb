module Iqeo
module Mesh

class Mesh

  require 'set'

  attr_reader :points, :edges, :triangles, :hull, :width, :height, :options

  def initialize width, height, options = {}
    # todo: handle with default or extend mesh as points are added ?
    # todo: is width & height necessary to operation ? or is it just a handy way to keep track of the mesh size ?
    raise 'width and height cannot be nil' if width.nil? || height.nil?
    @width = width
    @height = height
    @options = { listener: nil, triangulation: false, container: :box, voronoi: false }.merge! options
    @points = Set.new
    @edges = Set.new
    @triangles = Set.new
    @hull = nil
    @voronoi = Voronoi.new if @options[:voronoi]
  end

  def notify *args
    @options[:listener].call *args if @options[:listener]
  end

  def add_point_at x, y
    new_point = Point.new( x, y )
    point = new_or_existing_point new_point
    if point == new_point
      notify :point_added, point
      update point
      voronoi point if @options[:voronoi]
    end
    point
  end

  def triangle_at x, y
    triangle_containing Point.new( x, y )
  end

  def add_point point
    new_or_existing_point point
  end

  def new_or_existing_point point
    if ( existing_point = @points.detect { |p| p == point } )
      existing_point
    else
      @points.add point
      point
    end
  end

  def new_or_existing_edge edge
    if ( existing_edge = @edges.detect { |e| e == edge } )
      existing_edge
    else
      @edges.add edge
      edge
    end
  end

  def update point
    case @options[:triangulation]
    when false         then triangulate_simple point
    when :simple       then triangulate_simple point
    when :bowyerwatson then triangulate_bowyerwatson point
    else
      raise "Unknown triangulation: #{@options[:triangulation]}"
    end
  end

  def triangulate_simple point
    return if @points.size < 3   # just collect points
    if @points.size == 3  # first triangle & convex hull
      triangle = Polygon.new self, @points
      @triangles.add triangle
      @hull = Polygon.new self, @points
      return
    end
    # new point may be inside or outside existing convex hull
    point_location = @hull.inside?( point ) ? :inside : :outside
    case point_location
    when :inside
      # split triangle into 3 triangles around point
      triangle = triangle_containing point
      @triangles.delete triangle
      new_triangles = triangle.split( point )
      new_triangles.each { |t| @triangles.add t }
    when :outside
      # create triangles between point and visible edges
      directed_edges_visible = @hull.directed_edges_visible point
      directed_edges_visible.collect(&:edge).each do |edge|
        triangle = Polygon.new self, [ edge, point ]
        @triangles.add triangle
      end
      @hull.expand point, directed_edges_visible
    end
  end

  def triangle_containing point
    # todo: accept triangle to start search at and traverse triangles in direction of point
    # todo: or.. use a tree to track mesh triangle splits then descend from root to leaf triangle
    # using detect because if point is on an edge we only want to pick one triangle
    @triangles.detect { |t| t.inside? point }
  end

  def triangulate_bowyerwatson point
    if @points.size == 1
      container = @options[:container] == :triangle ? container_triangle : container_box
      @triangles += container
      notify :bowyerwatson_container, container
    end
    triangle = triangle_containing point
    if triangle
      notify :bowyerwatson_hole, triangle
      @triangles.delete triangle
      bowyerwatson_boundary_special_case triangle, point
      hole, _ = bowyerwatson_neighbor_recursion triangle, point
      new_triangles = hole.split( point )
      @triangles += new_triangles
      notify :bowyerwatson_split, new_triangles
    else
      # should only happen if point is out of bounds or something is terribly wrong with the mesh
      raise "point #{point.x},#{point.y} is not inside a triangle"
    end
  end

  def container_triangle
    points = []
    points << add_point( Point.new( 0, 0 ) )
    points << add_point( Point.new( @width * 2, 0 ) )
    points << add_point( Point.new( 0, @height * 2 ) )
    [ Polygon.new( self, points ) ]
  end

  def container_box
    a   = add_point( Point.new( 0, 0) )
    ab1 = add_point( Point.new( @width, 0) )
    ab2 = add_point( Point.new( 0, @height) )
    b   = add_point( Point.new( @width, @height) )
    [ Polygon.new( self, [ a, ab1, ab2 ] ), Polygon.new( self, [ b, ab1, ab2 ] ) ]
  end

  def bowyerwatson_boundary_special_case triangle, point
    # delete initial edge if point falls on a boundary edge (for mesh consistency)
    if triangle.neighbors.size < 3 &&
      ( boundary_edges = triangle.edges.select { |e| e.polygons.size == 1 } ) &&
      ( edge_containing_point = boundary_edges.detect { |e| e.contains? point } )
      @edges.delete edge_containing_point
    end
  end

  def bowyerwatson_neighbor_recursion triangle, point, hole = triangle, tested = []
    hole.neighbors.each do |neighbor|
      unless tested.include? neighbor
        tested << neighbor
        if neighbor.circumcircle_contains point
          notify :bowyerwatson_circumcircle_contains_point, neighbor
          common_edge = hole.merge neighbor
          notify :bowyerwatson_hole, hole, common_edge
          hole, tested = bowyerwatson_neighbor_recursion neighbor, point, hole, tested
        else
          notify :bowyerwatson_circumcircle_clear, neighbor
        end
      end
    end
    [ hole, tested ]
  end

  def delaunay_test
    failures = @triangles.each_with_object({}) do |triangle,failures|
      non_delaunay_points = @points.select do |point|
        triangle.circumcircle_contains point unless triangle.points.include? point
      end
      failures[triangle] = non_delaunay_points unless non_delaunay_points.empty?
    end
    notify :delaunay_fail, failures unless failures.empty?
    failures
  end

  def delaunay?
    delaunay_test.empty?
  end

  def consistency
    consistent = {}
    consistent[:edges_okay] = ! @edges.detect { |e| ! e.consistent? }
    consistent[:triangles_okay] = ! @triangles.detect { |t| ! t.consistent? }
    consistent[:edges_consistent] = @edges == @triangles.collect(&:edges).flatten.to_set
    # todo: points_consistent
    consistent
  end

  def consistent?
    ! consistency.values.include? false
  end

  def voronoi point
    ## todo: this is a naive approach, can do something much more efficient within bowyerwatson
    #triangles = @triangles.select { |t| t.points.include? point }
    ## fix: Polygon.new will fail for > 3 points, extend it to work!
    #cell = Polygon.new @voronoi, triangles.collect(&:center)
    #@voronoi.cells << cell
  end

end

end
end
