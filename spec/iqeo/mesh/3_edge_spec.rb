require 'iqeo/mesh/edge'

describe 'Edge' do

  it 'accepts 2 points' do
    point0 = Iqeo::Mesh::Point.new 100, 200
    point1 = Iqeo::Mesh::Point.new 300, 400
    edge = nil
    expect { edge = Iqeo::Mesh::Edge.new point0, point1 }.to_not raise_error
    edge.points.size.should eq 2
    edge.points[0].should be point0
    edge.points[1].should be point1
    edge.polygons.empty?.should be_true
  end

  it 'is equivalent with same points in order' do
    point0 = Iqeo::Mesh::Point.new 100, 200
    point1 = Iqeo::Mesh::Point.new 300, 400
    edge0 = Iqeo::Mesh::Edge.new point0, point1
    edge1 = Iqeo::Mesh::Edge.new point0, point1
    edge0.should eq edge1
    edge1.should eq edge0
  end

  it 'is equivalent with same points not in order' do
    point0 = Iqeo::Mesh::Point.new 100, 200
    point1 = Iqeo::Mesh::Point.new 300, 400
    edge0 = Iqeo::Mesh::Edge.new point0, point1
    edge1 = Iqeo::Mesh::Edge.new point1, point0
    edge0.should eq edge1
    edge1.should eq edge0
  end

  it 'is comparable' do
    point0 = Iqeo::Mesh::Point.new 100, 200
    point1 = Iqeo::Mesh::Point.new 300, 400
    edge0 = Iqeo::Mesh::Edge.new point0, point1
    edge1 = Iqeo::Mesh::Edge.new point1, point0
    ( edge0 <=> edge1 ).should eq 0
    ( edge1 <=> edge0 ).should eq 0
    point2 = Iqeo::Mesh::Point.new 500, 600
    edge2 = Iqeo::Mesh::Edge.new point1, point2
    ( edge1 <=> edge2 ).should_not eq 0
    ( edge2 <=> edge1 ).should_not eq 0
  end

  it 'can check self for consistency' do
    point0 = Iqeo::Mesh::Point.new 100, 200
    point1 = Iqeo::Mesh::Point.new 300, 400
    edge0 = Iqeo::Mesh::Edge.new point0, point1
    edge0.check?.should be_true
  end

end