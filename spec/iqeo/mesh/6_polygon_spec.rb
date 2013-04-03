require 'iqeo/mesh/polygon'
require 'iqeo/mesh/mesh'

describe 'Polygon' do

  before :all do
    # triangle points
    @pt0 = Iqeo::Mesh::Point.new 20, 10
    @pt1 = Iqeo::Mesh::Point.new 30, 20
    @pt2 = Iqeo::Mesh::Point.new 10, 30
    @triangle_points = [ @pt0, @pt1, @pt2 ]
    # triangle edges
    @edge0 = Iqeo::Mesh::Edge.new @pt0, @pt1
    @edge1 = Iqeo::Mesh::Edge.new @pt1, @pt2
    @edge2 = Iqeo::Mesh::Edge.new @pt2, @pt0
    @triangle_edges = [ @edge0, @edge1, @edge2 ]
    # triangle directed edges
    @de0 = Iqeo::Mesh::DirectedEdge.new @edge0
    @de1 = Iqeo::Mesh::DirectedEdge.new @edge1
    @de2 = Iqeo::Mesh::DirectedEdge.new @edge2
    @triangle_directed_edges = [ @de0, @de1, @de2 ]
    # points collinear with triangle edges
    @pcol0 = Iqeo::Mesh::Point.new 40, 30
    @pcol1 = Iqeo::Mesh::Point.new 0, 35
    @pcol2 = Iqeo::Mesh::Point.new 25, 0
    @edge_collinear_points = [ @pcol0, @pcol1, @pcol2 ]
    # points contained on triangle edges
    @pcon0 = Iqeo::Mesh::Point.new 25, 15
    @pcon1 = Iqeo::Mesh::Point.new 20, 25
    @pcon2 = Iqeo::Mesh::Point.new 15, 20
    @edge_contained_points = [ @pcon0, @pcon1, @pcon2 ]
    # triangle point sequences
    @triangles_clockwise     = [ [ @pt0, @pt1, @pt2 ], [ @pt1, @pt2, @pt0 ], [ @pt2, @pt0, @pt1 ] ]
    @triangles_anticlockwise = [ [ @pt0, @pt2, @pt1 ], [ @pt1, @pt0, @pt2 ], [ @pt2, @pt1, @pt0 ] ]
    # triangle attributes
    @center = Iqeo::Mesh::Point.new 18, 21
    @radius2 = 138
    # points inside triangle
    @pi0 = Iqeo::Mesh::Point.new 20, 13
    @pi1 = Iqeo::Mesh::Point.new 13, 27
    @pi2 = Iqeo::Mesh::Point.new 28, 20
    @points_inside_triangle = [ @center, @pi0, @pi1, @pi2 ]
    # points outside triangle, single edge visible
    @pos0 = Iqeo::Mesh::Point.new 30, 10
    @pos1 = Iqeo::Mesh::Point.new 30, 30
    @pos2 = Iqeo::Mesh::Point.new 10, 10
    @points_outside_single = [ @pos0, @pos1, @pos2 ]
    @single_directed_edges_visible = { @pos0 => [ @de0 ], @pos1 => [ @de1 ], @pos2 => [ @de2 ] }
    @single_edges_visible = { @pos0 => [ @edge0 ], @pos1 => [ @edge1 ], @pos2 => [ @edge2 ] }
    # points outside triangle, multiple edges visible
    @pom0 = Iqeo::Mesh::Point.new 40, 20
    @pom1 = Iqeo::Mesh::Point.new 0, 40
    @pom2 = Iqeo::Mesh::Point.new 20, 0
    @points_outside_multiple = [ @pom0, @pom1, @pom2 ]
    @multiple_directed_edges_visible = { @pom0 => [ @de0, @de1 ], @pom1 => [ @de1, @de2 ], @pom2 => [ @de2, @de0 ] }
    @multiple_edges_visible = { @pom0 => [ @edge0, @edge1 ], @pom1 => [ @edge1, @edge2 ], @pom2 => [ @edge2, @edge0 ] }
    # collinear points
    @pl0 = Iqeo::Mesh::Point.new 50, 60
    @pl1 = Iqeo::Mesh::Point.new 60, 70
    @pl2 = Iqeo::Mesh::Point.new 70, 80
    @collinear_points = [ @pl0, @pl1, @pl2 ]
    # points inside circumcircle
    @pic0 = Iqeo::Mesh::Point.new 13, 17
    @pic1 = Iqeo::Mesh::Point.new 26, 14
    @pic2 = Iqeo::Mesh::Point.new 23, 27
    @points_inside_circumcircle = [ @pic0, @pic1, @pic2 ]
    # points outside circumcircle
    @points_outside_circumcircle = @points_outside_single + @points_outside_multiple
    # triangles with point at origin
    @pao = Iqeo::Mesh::Point.new 0,0
    @triangles_at_origin = [ [ @pao, @pt1, @pt2,], [ @pao, @pt2, @pt1 ], [ @pt1, @pao, @pt2 ], [ @pt1, @pt2, @pao ], [ @pt2, @pao, @pt1 ], [ @pt2, @pao, @pt1 ] ]
    @center_tao = Iqeo::Mesh::Point.new 13, 12
    @radius2_tao = 331
    # mesh
    @mesh_height = 1000
    @mesh_width  = 2000
    @mesh = Iqeo::Mesh::Mesh.new @mesh_width, @mesh_height
  end

  context 'initialization' do

    it 'accepts mesh and clockwise points' do
      @triangles_clockwise.each do |points|
        poly = nil
        expect { poly = Iqeo::Mesh::Polygon.new @mesh, points }.to_not raise_error
        poly.points.should eq @triangle_points
        poly.center.should eq @center
        poly.radius2.to_i.should eq @radius2
        poly.edges.should eq @triangle_edges
        poly.directed_edges.should eq @triangle_directed_edges
      end
    end

    it 'accepts mesh and non-clockwise points' do
      @triangles_anticlockwise.each do |points|
        poly = nil
        expect { poly = Iqeo::Mesh::Polygon.new @mesh, points }.to_not raise_error
        poly.points.should eq @triangle_points
        poly.center.should eq @center
        poly.radius2.to_i.should eq @radius2
        poly.edges.should eq @triangle_edges
        poly.directed_edges.should eq @triangle_directed_edges
      end
    end

    it 'accepts mesh and points with one at origin for special case circumcircle' do
      @triangles_at_origin.each do |points|
        poly = nil
        expect { poly = Iqeo::Mesh::Polygon.new @mesh, points }.to_not raise_error
        poly.center.should eq @center_tao
        poly.radius2.to_i.should eq @radius2_tao
      end
    end

    it 'raises exception for collinear points' do
      expect { Iqeo::Mesh::Polygon.new @mesh, @collinear_points }.to raise_error
    end

  end

  it 'checks self for consistency' do
    # fix: make tests independent
    # keep this test near top as poly tests below will add > 2 polys to @edge?s, this will not happen with a single @Mesh
    @poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points
    @poly.check?.should be_true
  end

  context 'detects points are' do

    before :all do
      @poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points
    end

    it 'inside' do
      @points_inside_triangle.each { |point| @poly.inside?( point ).should be_true }
    end

    it 'not outside' do
      @points_inside_triangle.each { |point| @poly.outside?( point ).should be_false }
    end

    it 'outside' do
      @points_outside_single.each { |point| @poly.outside?(point).should be_true }
    end

    it 'not inside' do
      @points_outside_single.each { |point| @poly.inside?(point).should be_false }
    end

    it 'within circumcircle' do
      @points_inside_circumcircle.each { |point| @poly.circumcircle_contains(point).should be_true }
    end

    it 'not within circumcircle' do
      @points_outside_circumcircle.each { |point| @poly.circumcircle_contains(point).should be_false }
    end

    it 'outside when collinear non contained with edge' do
      @edge_collinear_points.each do |point|
        @poly.directed_edges.any? { |de| de.collinear? point }.should be_true
        @poly.outside?(point).should be_true
      end
    end

    it 'inside when collinear contained on edge' do
      @edge_contained_points.each do |point|
        @poly.directed_edges.any? { |de| de.contains? point }.should be_true
        @poly.inside?(point).should be_true
      end
    end

  end

  context 'detecting directed_edges visible to outside point' do

    before :all do
      @poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points
    end

    it 'raises exception if point is not outside' do
      @points_inside_triangle.each do |point|
        expect { @poly.directed_edges_visible_to_outside_point( point ) }.to raise_error
      end
    end

    it 'detects single directed_edge visible' do
      @points_outside_single.each do |point|
        @poly.directed_edges_visible_to_outside_point( point ).should eq @single_directed_edges_visible[ point ]
      end
    end

    it 'detects multiple directed_edge visible' do
      @points_outside_multiple.each do |point|
        @poly.directed_edges_visible_to_outside_point( point ).should eq @multiple_directed_edges_visible[ point ]
      end
    end

  end

  context 'detecting edges visible to outside point' do

    before :all do
      @poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points
    end

    it 'raises exception if point is not outside' do
      expect { @poly.edges_visible_to_outside_point( @point_inside ) }.to raise_error
    end

    it 'detects single edge visible' do
      @points_outside_single.each do |point|
        @poly.edges_visible_to_outside_point( point ).should eq @single_edges_visible[ point ]
      end
    end

    it 'detects multiple edge visible' do
      @points_outside_multiple.each do |point|
        @poly.edges_visible_to_outside_point( point ).should eq @multiple_edges_visible[ point ]
      end
    end

  end

  it 'splits into multiple triangles around point' do
    @points_inside_triangle.each do |point|
      @poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points
      triangles = @poly.split point
      triangles.size.should eq 3
      triangles.each { |t| t.points.should include point }
    end
  end

  context 'expands' do

    it 'to a point with single visible edge' do
      @poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points
      @poly.expand @pos2
      @poly.points.should include @pos2
      # todo: if expanded a second time: undefined method `start' for nil:NilClass ./lib/iqeo/mesh/polygon.rb:75:in `expand
      # todo: we don't use expand anymore, until we use triangulation: none !?
      #@points_outside_single.each_with_index do |point,i|
      #  @poly.expand point
      #  @poly.points.should include point
      #  #@poly.edges.size.should eq ( 4 + i )
      #end
    end

    it 'to a point with multiple visible edges' do
      @poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points
      @points_outside_multiple.each do |point|
        @poly.expand point
        @poly.points.should include point
        @poly.edges.size.should eq 3
      end
    end

  end

  context 'neighbors' do

    before :all do
      @mesh = Iqeo::Mesh::Mesh.new @mesh_width, @mesh_height
      @poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points
    end

    it 'may not exist' do
      @poly.neighbors.should be_empty
    end

    context 'can be' do

      before :all do
        @neighbors = @points_outside_single.collect { |point| Iqeo::Mesh::Polygon.new @mesh, [ point, *@single_edges_visible[point] ] }
      end

      it 'known' do
        @poly.neighbors.should eq @neighbors
      end

      it 'merged' do
        @neighbors.each { |neighbor| @poly.merge neighbor }
        @poly.neighbors.should be_empty
        @poly.points.size.should eq 6
        @poly.edges.size.should eq 6
      end

    end

  end

end