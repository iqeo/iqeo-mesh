require 'iqeo/mesh/edge'

describe 'Edge' do

  before :all do
    @point0 = Iqeo::Mesh::Point.new 100, 200
    @point1 = Iqeo::Mesh::Point.new 300, 400
    @point2 = Iqeo::Mesh::Point.new 800, 100
    @point_collinear = Iqeo::Mesh::Point.new 500, 600
    @point_non_collinear = Iqeo::Mesh::Point.new 500, 650
    @point_contained = Iqeo::Mesh::Point.new 200, 300
  end

  it 'accepts 2 points' do
    edge = nil
    expect { edge = Iqeo::Mesh::Edge.new @point0, @point1 }.to_not raise_error
    edge.points.size.should eq 2
    edge.points[0].should be @point0
    edge.points[1].should be @point1
    edge.polygons.empty?.should be_true
  end

  it 'prints nicely' do
    edge = Iqeo::Mesh::Edge.new @point0, @point1
    edge.to_s.should match( /^.*#{@point0.x}.*#{@point0.y}.*#{@point1.x}.*#{@point1.y}.*$/ )
  end

  it 'is comparable' do
    edge0 = Iqeo::Mesh::Edge.new @point0, @point1
    edge1 = Iqeo::Mesh::Edge.new @point1, @point0
    ( edge0 <=> edge1 ).should eq 0
    ( edge1 <=> edge0 ).should eq 0
    edge2 = Iqeo::Mesh::Edge.new @point1, @point2
    ( edge1 <=> edge2 ).should_not eq 0
    ( edge2 <=> edge1 ).should_not eq 0
  end

  it 'is equivalent with same points in order' do
    edge0 = Iqeo::Mesh::Edge.new @point0, @point1
    edge1 = Iqeo::Mesh::Edge.new @point0, @point1
    edge0.should eq edge1
    edge1.should eq edge0
  end

  it 'is equivalent with same points not in order' do
    edge0 = Iqeo::Mesh::Edge.new @point0, @point1
    edge1 = Iqeo::Mesh::Edge.new @point1, @point0
    edge0.should eq edge1
    edge1.should eq edge0
  end

  it 'can check self for consistency' do
    edge0 = Iqeo::Mesh::Edge.new @point0, @point1
    edge0.consistent?.should be_true
  end

  it 'can check a point is collinear' do
    edge0 = Iqeo::Mesh::Edge.new @point0, @point1
    edge0.collinear?( @point_collinear ).should be_true
  end

  it 'can check a point is non collinear' do
    edge0 = Iqeo::Mesh::Edge.new @point0, @point1
    edge0.collinear?( @point_non_collinear ).should be_false
  end

  it 'can check a point is contained' do
    edge0 = Iqeo::Mesh::Edge.new @point0, @point1
    edge0.contains?( @point_contained ).should be_true
  end

end