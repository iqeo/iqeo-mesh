require 'iqeo/mesh/polygon'
require 'iqeo/mesh/mesh'

describe 'Polygon' do

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
    @po0 = Iqeo::Mesh::Point.new 30, 10
    @po1 = Iqeo::Mesh::Point.new 30, 30
    @po2 = Iqeo::Mesh::Point.new 10, 10
    @points_outside_single = [ @po0, @po1, @po2 ]
    @single_directed_edges_visible = { @po0 => [ @de0 ], @po1 => [ @de1 ], @po2 => [ @de2 ] }
    @single_edges_visible = { @po0 => [ @edge0 ], @po1 => [ @edge1 ], @po2 => [ @edge2 ] }
    @po3 = Iqeo::Mesh::Point.new 40, 20
    @po4 = Iqeo::Mesh::Point.new 0, 40
    @po5 = Iqeo::Mesh::Point.new 20, 0
    @points_outside_multiple = [ @po3, @po4, @po5 ]
    @multiple_directed_edges_visible = { @po3 => [ @de0, @de1 ], @po4 => [ @de1, @de2 ], @po5 => [ @de2, @de0 ] }
    @multiple_edges_visible = { @po3 => [ @edge0, @edge1 ], @po4 => [ @edge1, @edge2 ], @po5 => [ @edge2, @edge0 ] }
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

    it 'raises exception for collinear points' do
      expect { Iqeo::Mesh::Polygon.new @mesh, [ @p3, @p4, @p5 ] }.to raise_error
    end

  end

  context 'relationship with' do

    before :all do
      @poly = Iqeo::Mesh::Polygon.new @mesh, @points
    end

    it 'inside point is inside' do
      @poly.inside?( @point_inside ).should be_true
    end

    it 'inside point is not outside' do
      @poly.outside?( @point_inside ).should be_false
    end

    it 'outside points are outside' do
      @points_outside_single.each { |point| @poly.outside?(point).should be_true }
    end

    it 'outside points are not inside' do
      @points_outside_single.each { |point| @poly.inside?(point).should be_false }
    end

  end

  context 'detecting directed_edges visible to outside point' do

    before :all do
      @poly = Iqeo::Mesh::Polygon.new @mesh, @points
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
      @poly = Iqeo::Mesh::Polygon.new @mesh, @points
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
    @poly = Iqeo::Mesh::Polygon.new @mesh, @points
    triangles = @poly.split @point_inside
    triangles.size.should eq 3                                               # 3 triangles
    triangles.each { |t| t.points.include?( @point_inside ).should be_true } # common point @point_inside
  end

  context 'expands' do

    it 'to a point with single visible edge' do
      pending # fix: undefined method `start' for nil:NilClass ./lib/iqeo/mesh/polygon.rb:75:in `expand
      @poly = Iqeo::Mesh::Polygon.new @mesh, @points
      @points_outside_single.each_with_index do |point,i|
        @poly.expand point
        @poly.points.include?( point ).should be_true
        @poly.edges.size.should eq ( 4 + i )
      end
    end

    it 'to a point with multiple visible edges' do
      @poly = Iqeo::Mesh::Polygon.new @mesh, @points
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