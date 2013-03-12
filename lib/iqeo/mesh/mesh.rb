module Iqeo
module Mesh


class Mesh

  require 'set'

  attr_reader :points, :edges, :triangles, :hull

  def initialize width, height, options = {}
    @width = width
    @height = height
    @options = { listener: nil, triangulation: nil, container: :triangulated_box, voronoi: false }.merge! options
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

  def voronoi point
    # todo: this is a naive approach, can do something much more efficient within bowyerwatson
    triangles = @triangles.select { |t| t.points.include? point }
    # todo : order triangles by neighbor - not needed because Polygon.new will order points clockwise ?
    #ordered = [ triangles.shift ]
    #until triangles.empty?
    #  triangles = triangles - ordered
    #  triangles.each_with_object(ordered) { |t, ot| ot << t if t.neighbors.include? ot.last }
    #end
    # fix: Polygon.new will fail for > 3 points, extend it to work!
    cell = Polygon.new @voronoi, triangles.collect(&:center)
    @voronoi.cells << cell
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
    when nil                    then triangulate_none point
    when false                  then triangulate_none point
    when :delaunay_bowyerwatson then triangulate_bowyerwatson point
    else
      raise "Unknown triangulation: #@options[:triangulation]"
    end
  end

  def triangle_containing point
    # todo: accept triangle to start search at and traverse triangles in direction of point
    # todo: or.. use a tree to track mesh triangle splits then descend from root to leaf triangle
    @triangles.detect { |t| t.inside? point }
  end

  def container_super_triangle
    points = []
    points << add_point( Point.new( 0, 0 ) )
    points << add_point( Point.new( @width * 2, 0 ) )
    points << add_point( Point.new( 0, @height * 2 ) )
    [ Polygon.new( self, points ) ]
  end

  def container_triangulated_box
    a   = add_point( Point.new( 0, 0) )
    ab1 = add_point( Point.new( @width, 0) )
    ab2 = add_point( Point.new( 0, @height) )
    b   = add_point( Point.new( @width, @height) )
    [ Polygon.new( self, [ a, ab1, ab2 ] ), Polygon.new( self, [ b, ab1, ab2 ] ) ]
  end

  def triangulate_bowyerwatson point
    if @points.size == 1
      container = @options[:container] == :super_triangle ? container_super_triangle : container_triangulated_box
      @triangles += container
      notify :bowyerwatson_container, container
    end
    triangle = triangle_containing point
    notify :bowyerwatson_hole, triangle
    @triangles.delete triangle
    hole, _ = bowyerwatson_neighbor_recursion triangle, point
    new_triangles = hole.split( point )
    @triangles += new_triangles
    notify :bowyerwatson_split, new_triangles
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

  def triangulate_none point
    return if @points.size < 3   # just collect points
    if @points.size == 3  # first triangle & convex hull
      triangle = Polygon.new self, @points
      @triangles.add triangle
      #notify :triangle, triangle
      @hull = Polygon.new self, @points
      #notify :hull, @hull
      return
    end
    # new point may be inside or outside existing convex hull
    directed_edges_visible_to_outside_point = @hull.directed_edges_visible_to_outside_point point
    point_location = directed_edges_visible_to_outside_point.empty? ? :inside : :outside
    case point_location
    when :inside
      # split triangle into 3 triangles around point
      triangle = triangle_containing point
      @triangles.delete triangle
      #notify :delete_triangle, triangle
      #notify :hull, @hull
      new_triangles = triangle.split( point )
      new_triangles.each do |t|
        @triangles.add t
        #notify :triangle, t
        #notify :hull, @hull
      end
    when :outside
      # create triangles between point and visible edges
      directed_edges_visible_to_outside_point.collect(&:edge).each do |edge|
        #notify :edge_point_outside, edge
        triangle = Polygon.new self, [ edge, point ]
        @triangles.add triangle
        #notify :triangle, triangle
      end
      @hull.expand point, directed_edges_visible_to_outside_point
      #notify :hull, @hull
    else
      raise "Unknown point_location #{point_location}"
    end
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

  def check_mesh
    @check = {}
    @check[:edges_okay] = ! @edges.detect { |e| ! e.check? }
    @check[:triangles_okay] = ! @triangles.detect { |t| ! t.check? }
    @check[:edges_consistent] = @edges == @triangles.collect(&:edges).flatten.to_set
    # todo: points_okay ? points_consistent
    @check
  end

  def check?
    ! check_mesh.values.include? false
  end

end

end
end
