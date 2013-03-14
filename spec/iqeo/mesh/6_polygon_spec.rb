require 'iqeo/mesh/polygon'
require 'iqeo/mesh/mesh'

describe 'Polygon' do

  HEIGHT = 1000
  WIDTH  = 2000
  MESH = Iqeo::Mesh::Mesh.new WIDTH, HEIGHT

  P0 = Iqeo::Mesh::Point.new 20, 10
  P1 = Iqeo::Mesh::Point.new 30, 20
  P2 = Iqeo::Mesh::Point.new 10, 30
  CENTER = Iqeo::Mesh::Point.new 18, 21
  RADIUS2 = 125
  EDGE0 = Iqeo::Mesh::Edge.new P0, P1
  EDGE1 = Iqeo::Mesh::Edge.new P1, P2
  EDGE2 = Iqeo::Mesh::Edge.new P2, P0
  DE0 = Iqeo::Mesh::DirectedEdge.new EDGE0
  DE1 = Iqeo::Mesh::DirectedEdge.new EDGE1
  DE2 = Iqeo::Mesh::DirectedEdge.new EDGE2

  it 'accepts mesh and clockwise points' do
    poly = nil
    expect { poly = Iqeo::Mesh::Polygon.new MESH, [ P0, P1, P2 ] }.to_not raise_error
    poly.points.should eq [ P0, P1, P2 ]
    poly.center.should eq CENTER
    poly.radius2.should eq RADIUS2
    poly.directed_edges.should eq [ DE0, DE1, DE2 ]
    poly.edges.should eq [ EDGE0, EDGE1, EDGE2 ]
  end

  it 'accepts mesh and non-clockwise points' do
    poly = nil
    expect { poly = Iqeo::Mesh::Polygon.new MESH, [ P2, P1, P0 ] }.to_not raise_error
    poly.points.should eq [ P0, P1, P2 ]
    poly.center.should eq CENTER
    poly.radius2.should eq RADIUS2
    poly.directed_edges.should eq [ DE0, DE1, DE2 ]
    poly.edges.should eq [ EDGE0, EDGE1, EDGE2 ]
  end

end