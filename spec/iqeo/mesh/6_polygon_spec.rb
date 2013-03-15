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
    # triangle point sequences
    @triangles_clockwise     = [ [ @pt0, @pt1, @pt2 ], [ @pt1, @pt2, @pt0 ], [ @pt2, @pt0, @pt1 ] ]
    @triangles_anticlockwise = [ [ @pt0, @pt2, @pt1 ], [ @pt1, @pt0, @pt2 ], [ @pt2, @pt1, @pt0 ] ]
    # triangle attributes
    @center = Iqeo::Mesh::Point.new 18, 21
    @radius2 = 125
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
    # mesh
    height = 1000
    width  = 2000
    @mesh = Iqeo::Mesh::Mesh.new width, height
  end

  context 'initialization' do

    it 'accepts mesh and clockwise points' do
      @triangles_clockwise.each do |points|
        poly = nil
        expect { poly = Iqeo::Mesh::Polygon.new @mesh, points }.to_not raise_error
        poly.points.should eq @triangle_points
        poly.center.should eq @center
        poly.radius2.should eq @radius2
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
        poly.radius2.should eq @radius2
        poly.edges.should eq @triangle_edges
        poly.directed_edges.should eq @triangle_directed_edges
      end
    end

    it 'raises exception for collinear points' do
      expect { Iqeo::Mesh::Polygon.new @mesh, @collinear_points }.to raise_error
    end

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

  end

  context 'detecting directed_edges visible to outside point' do

    before :all do
      @poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points
    end

    it 'raises exception if point is not outside' do
      expect { @poly.directed_edges_visible_to_outside_point( @point_inside ) }.to raise_error
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
      triangles.each { |t| t.points.include?( point ).should be_true }
    end
  end

  context 'expands' do

    it 'to a point with single visible edge' do
      pending # fix: undefined method `start' for nil:NilClass ./lib/iqeo/mesh/polygon.rb:75:in `expand
      @poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points
      @points_outside_single.each_with_index do |point,i|
        @poly.expand point
        @poly.points.include?( point ).should be_true
        @poly.edges.size.should eq ( 4 + i )
      end
    end

    it 'to a point with multiple visible edges' do
      @poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points
      @points_outside_multiple.each do |point|
        @poly.expand point
        @poly.points.include?( point ).should be_true
        @poly.edges.size.should eq 3
      end
    end

  end

  context 'neighbors' do

    it 'are known' do
      pending
    end

    it 'are merged' do
      pending
    end

  end

  it 'checks self for consistency' do
    pending # fix: 'why is this returning false ?'
    @poly.check?.should be_true
  end

end