require 'iqeo/mesh/directed_edge'

describe 'DirectedEdge' do

  POINT0      = Iqeo::Mesh::Point.new 100, 200
  POINT1      = Iqeo::Mesh::Point.new 300, 400
  EDGE0       = Iqeo::Mesh::Edge.new POINT0, POINT1
  POINT2      = Iqeo::Mesh::Point.new 500, 600
  POINT3      = Iqeo::Mesh::Point.new 700, 800
  EDGE1       = Iqeo::Mesh::Edge.new POINT2, POINT3
  POINT_RIGHT = Iqeo::Mesh::Point.new 200, 500
  POINT_LEFT  = Iqeo::Mesh::Point.new 200, 100

  it 'accepts single edge' do
    de = nil
    expect { de = Iqeo::Mesh::DirectedEdge.new EDGE0 }.to_not raise_error
    de.start.should eq POINT0
    de.finish.should eq POINT1
    de.edge.should be EDGE0
    de.points.should be EDGE0.points
    de.polygons.should be EDGE0.polygons
  end

  it 'accepts single edge and start point' do
    de = nil
    expect { de = Iqeo::Mesh::DirectedEdge.new EDGE0, POINT1 }.to_not raise_error
    de.start.should eq POINT1
    de.finish.should eq POINT0
    de.edge.should be EDGE0
    de.points.should be EDGE0.points
    de.polygons.should be EDGE0.polygons
  end

  it 'raises an exception for start point not on edge' do
    expect { Iqeo::Mesh::DirectedEdge.new EDGE0, POINT2 }.to raise_error
  end

  it 'is comparable' do
    de0 = Iqeo::Mesh::DirectedEdge.new EDGE0
    de1 = Iqeo::Mesh::DirectedEdge.new EDGE0
    ( de0 <=> de1 ).should eq 0
    ( de1 <=> de0 ).should eq 0
    de0 = Iqeo::Mesh::DirectedEdge.new EDGE0
    de1 = Iqeo::Mesh::DirectedEdge.new EDGE1
    ( de0 <=> de1 ).should_not eq 0
    ( de1 <=> de0 ).should_not eq 0
  end

  it 'is equivalent for same edge in same direction' do
    de0 = Iqeo::Mesh::DirectedEdge.new EDGE0
    de1 = Iqeo::Mesh::DirectedEdge.new EDGE0
    de0.should eq de1
    de1.should eq de0
  end

  it 'is different for same edge in different direction' do
    de0 = Iqeo::Mesh::DirectedEdge.new EDGE0
    de1 = Iqeo::Mesh::DirectedEdge.new EDGE0, EDGE0.points[1]
    de0.should_not eq de1
    de1.should_not eq de0
  end

  it 'can check a point is right of self' do
    de = Iqeo::Mesh::DirectedEdge.new EDGE0
    de.right?( POINT_RIGHT ).should be_true
    de.left?( POINT_RIGHT ).should be_false
  end

  it 'can check a point is left of self' do
    de = Iqeo::Mesh::DirectedEdge.new EDGE0
    de.left?( POINT_LEFT ).should be_true
    de.right?( POINT_LEFT ).should be_false
  end

  it 'can check self for consistency' do
    directed_edge = Iqeo::Mesh::DirectedEdge.new EDGE0
    directed_edge.check?.should be_true
  end

end