require 'iqeo/mesh/polygon'
require 'iqeo/mesh/mesh'

describe 'Polygon' do

  before :all do
    # mesh
    height = 1000
    width  = 2000
    @mesh = Iqeo::Mesh::Mesh.new width, height
    # triangle points
    @p0 = Iqeo::Mesh::Point.new 20, 10
    @p1 = Iqeo::Mesh::Point.new 30, 20
    @p2 = Iqeo::Mesh::Point.new 10, 30
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
  end

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

  it 'can check self for consistency' do
    pending 'todo: why is this broken ?'
    poly = Iqeo::Mesh::Polygon.new @mesh, [ @p0, @p1, @p2 ]
    poly.check?.should be_true
  end

end