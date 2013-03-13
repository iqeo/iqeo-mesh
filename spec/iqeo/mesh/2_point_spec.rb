require 'iqeo/mesh/point'

describe 'Point' do

  it 'accepts xy coordinates' do
    point = nil
    expect { point = Iqeo::Mesh::Point.new 100, 200 }.to_not raise_error
    point.x.should eq 100
    point.y.should eq 200
  end

  it 'is equivalent with identical coordinates' do
    point1 = Iqeo::Mesh::Point.new 100, 200
    point2 = Iqeo::Mesh::Point.new 100, 200
    point1.should eq point2
    point2.should eq point1
  end

  it 'is not equivalent with different coordinates' do
    point1 = Iqeo::Mesh::Point.new 100, 200
    point2 = Iqeo::Mesh::Point.new 300, 400
    point1.should_not eq point2
    point2.should_not eq point1
  end

  it 'is comparable by y then x coordinates' do
    point1 = Iqeo::Mesh::Point.new 100, 400
    point2 = Iqeo::Mesh::Point.new 200, 300
    ( point1 <=> point2 ).should eq 1
    ( point2 <=> point1 ).should eq -1
    point3 = Iqeo::Mesh::Point.new 100, 300
    ( point2 <=> point3 ).should eq 1
    ( point3 <=> point2 ).should eq -1
    point4 = Iqeo::Mesh::Point.new 100, 400
    ( point1 <=> point4 ).should eq 0
    ( point4 <=> point1 ).should eq 0
  end

end