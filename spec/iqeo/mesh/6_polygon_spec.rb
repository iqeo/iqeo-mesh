require 'iqeo/mesh/polygon'
require 'iqeo/mesh/mesh'

describe Iqeo::Mesh::Polygon do

  before :all do
    # triangle points
    @p0 = Iqeo::Mesh::Point.new 20, 10
    @p1 = Iqeo::Mesh::Point.new 30, 20
    @p2 = Iqeo::Mesh::Point.new 10, 30
    # point sequences
    @points = [ @p0, @p1, @p2 ]
    @points_clockwise     = [ [ @p0, @p1, @p2 ], [ @p1, @p2, @p0 ], [ @p2, @p0, @p1 ] ]
    @points_anticlockwise = [ [ @p0, @p2, @p1 ], [ @p1, @p0, @p2 ], [ @p2, @p1, @p0 ] ]
    # triangle attributes
    @center = Iqeo::Mesh::Point.new 18, 21
    @radius2 = 125
    # triangle edges
    @edge0 = Iqeo::Mesh::Edge.new @p0, @p1
    @edge1 = Iqeo::Mesh::Edge.new @p1, @p2
    @edge2 = Iqeo::Mesh::Edge.new @p2, @p0
    # triangle directed edges
    @de0 = Iqeo::Mesh::DirectedEdge.new @edge0
    @de1 = Iqeo::Mesh::DirectedEdge.new @edge1
    @de2 = Iqeo::Mesh::DirectedEdge.new @edge2
    # colinear points
    @p3 = Iqeo::Mesh::Point.new 50, 60
    @p4 = Iqeo::Mesh::Point.new 60, 70
    @p5 = Iqeo::Mesh::Point.new 70, 80
    # other points
    @point_inside = Iqeo::Mesh::Point.new 20, 20
    @point_outside = Iqeo::Mesh::Point.new 15, 15
    @po0 = Iqeo::Mesh::Point.new 40, 1 #30, 10
    @po1 = Iqeo::Mesh::Point.new 40, 40 #30, 30
    @po2 = Iqeo::Mesh::Point.new 1, 1 #10, 10
    @points_outside = [ @po0, @po1, @po2 ]
    @directed_edges_visible = { @po0 => [ @de0 ], @po1 => [ @de1 ], @po2 => [ @de2 ] }
    @edges_visible = { @po0 => [ @edge0 ], @po1 => [ @edge1 ], @po2 => [ @edge2 ] }
    # mesh
    height = 1000
    width  = 2000
    @mesh = Iqeo::Mesh::Mesh.new width, height
    @all_points = [ @p0, @p1, @p2, @p3, @p4, @p5, @po0, @po1, @po2 ]
    @all_points.each { |point| @mesh.add_point point }
  end

  context 'initialization' do

    it 'accepts mesh and clockwise points' do
      poly = nil
      expect { poly = Iqeo::Mesh::Polygon.new @mesh, [ @p0, @p1, @p2 ] }.to_not raise_error
      poly.points.should eq [ @p0, @p1, @p2 ]
      poly.center.should eq @center
      poly.radius2.should eq @radius2
      poly.directed_edges.should eq [ @de0, @de1, @de2 ]
      poly.edges.should eq [ @edge0, @edge1, @edge2 ]
    end

    it 'accepts mesh and non-clockwise points' do
      poly = nil
      expect { poly = Iqeo::Mesh::Polygon.new @mesh, [ @p2, @p1, @p0 ] }.to_not raise_error
      poly.points.should eq [ @p0, @p1, @p2 ]
      poly.center.should eq @center
      poly.radius2.should eq @radius2
      poly.directed_edges.should eq [ @de0, @de1, @de2 ]
      poly.edges.should eq [ @edge0, @edge1, @edge2 ]
    end

    it 'raises exception for colinear points' do
      expect { Iqeo::Mesh::Polygon.new @mesh, [ @p3, @p4, @p5 ] }.to raise_error
    end

  end

  context 'point relationship' do

    it 'checks inside point is inside' do
      poly = Iqeo::Mesh::Polygon.new @mesh, @points
      poly.inside?( @point_inside ).should be_true
    end

    it 'checks inside point is not outside' do
      poly = Iqeo::Mesh::Polygon.new @mesh, @points
      poly.outside?( @point_inside ).should be_false
    end

    it 'checks outside points are outside' do
      poly = Iqeo::Mesh::Polygon.new @mesh, @points
      @points_outside.each { |point| poly.outside?(point).should be_true }
    end

    it 'checks outside points are not inside' do
      poly = Iqeo::Mesh::Polygon.new @mesh, @points
      @points_outside.each { |point| poly.inside?(point).should be_false }
    end

  end

  context 'detecting directed_edges visible to outside point' do

    it 'raises exception if point is not outside' do
      poly = Iqeo::Mesh::Polygon.new @mesh, @points
      expect { poly.directed_edges_visible_to_outside_point( @point_inside ) }.to raise_error
    end

    it 'detects single directed_edge visible' do
      poly = Iqeo::Mesh::Polygon.new @mesh, @points
      @points_outside.each do |point|
        poly.directed_edges_visible_to_outside_point( point ).should eq @directed_edges_visible[ point ]
      end
    end

    it 'detects multiple directed_edges visible'

  end

  context 'detecting edges visible to outside point' do

    it 'raises exception if point is not outside' do
      poly = Iqeo::Mesh::Polygon.new @mesh, @points
      expect { poly.edges_visible_to_outside_point( @point_inside ) }.to raise_error
    end

    it 'detects single edge visible' do
      poly = Iqeo::Mesh::Polygon.new @mesh, @points
      @points_outside.each do |point|
        poly.edges_visible_to_outside_point( point ).should eq @edges_visible[ point ]
      end
    end

    it 'detects multiple edges visible'

  end

  it 'checks self for consistency' do
    pending 'why is this broken ?'
    poly = Iqeo::Mesh::Polygon.new @mesh, [ @p0, @p1, @p2 ]
    poly.check?.should be_true
  end

end