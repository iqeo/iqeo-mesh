require 'iqeo/mesh/directed_edge'

describe 'DirectedEdge' do

  before :all do
    @point0      = Iqeo::Mesh::Point.new 100, 200
    @point1      = Iqeo::Mesh::Point.new 300, 400
    @edge0       = Iqeo::Mesh::Edge.new @point0, @point1
    @point2      = Iqeo::Mesh::Point.new 500, 600
    @point3      = Iqeo::Mesh::Point.new 700, 800
    @edge1       = Iqeo::Mesh::Edge.new @point2, @point3
    @point_right = Iqeo::Mesh::Point.new 200, 500
    @point_left  = Iqeo::Mesh::Point.new 200, 100
    @point_collinear = Iqeo::Mesh::Point.new 500, 600
    @point_non_collinear = Iqeo::Mesh::Point.new 500, 650
    @point_contained = Iqeo::Mesh::Point.new 200, 300
  end

  it 'accepts single edge' do
    de = nil
    expect { de = Iqeo::Mesh::DirectedEdge.new @edge0 }.to_not raise_error
    de.start.should eq @point0
    de.finish.should eq @point1
    de.edge.should be @edge0
    de.points.should be @edge0.points
    de.polygons.should be @edge0.polygons
  end

  it 'accepts single edge and start point' do
    de = nil
    expect { de = Iqeo::Mesh::DirectedEdge.new @edge0, @point1 }.to_not raise_error
    de.start.should eq @point1
    de.finish.should eq @point0
    de.edge.should be @edge0
    de.points.should be @edge0.points
    de.polygons.should be @edge0.polygons
  end

  it 'raises an exception for start point not on edge' do
    expect { Iqeo::Mesh::DirectedEdge.new @edge0, @point2 }.to raise_error
  end

  it 'prints nicely' do
    directed_edge = Iqeo::Mesh::DirectedEdge.new @edge0
    directed_edge.to_s.should match( /^.*#{directed_edge.start.x}.*#{directed_edge.start.y}.*#{directed_edge.finish.x}.*#{directed_edge.finish.y}.*$/ )
  end

  it 'is comparable' do
    de0 = Iqeo::Mesh::DirectedEdge.new @edge0
    de1 = Iqeo::Mesh::DirectedEdge.new @edge0
    ( de0 <=> de1 ).should eq 0
    ( de1 <=> de0 ).should eq 0
    de0 = Iqeo::Mesh::DirectedEdge.new @edge0
    de1 = Iqeo::Mesh::DirectedEdge.new @edge1
    ( de0 <=> de1 ).should_not eq 0
    ( de1 <=> de0 ).should_not eq 0
  end

  it 'is equivalent for same edge in same direction' do
    de0 = Iqeo::Mesh::DirectedEdge.new @edge0
    de1 = Iqeo::Mesh::DirectedEdge.new @edge0
    de0.should eq de1
    de1.should eq de0
  end

  it 'is different for same edge in different direction' do
    de0 = Iqeo::Mesh::DirectedEdge.new @edge0
    de1 = Iqeo::Mesh::DirectedEdge.new @edge0, @edge0.points[1]
    de0.should_not eq de1
    de1.should_not eq de0
  end

  it 'can check a point is right of self' do
    de = Iqeo::Mesh::DirectedEdge.new @edge0
    de.right?( @point_right ).should be_true
    de.left?( @point_right ).should be_false
  end

  it 'can check a point is left of self' do
    de = Iqeo::Mesh::DirectedEdge.new @edge0
    de.left?( @point_left ).should be_true
    de.right?( @point_left ).should be_false
  end

  it 'can check a point is collinear' do
    de = Iqeo::Mesh::DirectedEdge.new @edge0
    de.collinear?( @point_collinear ).should be_true
  end

  it 'can check a point is non collinear' do
    de = Iqeo::Mesh::DirectedEdge.new @edge0
    de.collinear?( @point_non_collinear ).should be_false
  end

  it 'can check a point is contained' do
    de = Iqeo::Mesh::DirectedEdge.new @edge0
    de.contains?( @point_contained ).should be_true
  end

  it 'can check a collinear point is not contained' do
    de = Iqeo::Mesh::DirectedEdge.new @edge0
    de.contains?( @point_collinear ).should be_false
  end

  it 'can check a non collinear point is not contained' do
    de = Iqeo::Mesh::DirectedEdge.new @edge0
    de.contains?( @point_non_collinear ).should be_false
  end

  it 'can check self for consistency' do
    directed_edge = Iqeo::Mesh::DirectedEdge.new @edge0
    directed_edge.consistent?.should be_true
  end

end