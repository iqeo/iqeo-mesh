require 'iqeo/mesh/point'

describe 'Point' do

  before :all do
    @x0, @y0 = 100, 200
    @x1, @y1 = 300, 400
    @x_hi = 200
    @x_lo = 100
    @y_hi = 400
    @y_lo = 300
  end

  it 'accepts xy coordinates' do
    point = nil
    expect { point = Iqeo::Mesh::Point.new @x0, @y0 }.to_not raise_error
    point.x.should eq 100
    point.y.should eq 200
  end

  it 'prints nicely' do
    point = Iqeo::Mesh::Point.new @x0, @y0
    point.to_s.should match( /^.*#{@x0}.*#{@y0}.*$/ )
  end

  it 'is equivalent with identical coordinates' do
    point0 = Iqeo::Mesh::Point.new @x0, @y0
    point1 = Iqeo::Mesh::Point.new @x0, @y0
    point0.should eq point1
    point1.should eq point0
  end

  it 'is not equivalent with different coordinates' do
    point0 = Iqeo::Mesh::Point.new @x0, @y0
    point1 = Iqeo::Mesh::Point.new @x1, @y1
    point0.should_not eq point1
    point1.should_not eq point0
  end

  it 'is comparable by y then x coordinates' do
    point_x_lo_y_hi = Iqeo::Mesh::Point.new @x_lo, @y_hi
    point_x_hi_y_lo = Iqeo::Mesh::Point.new @x_hi, @y_lo
    ( point_x_lo_y_hi <=> point_x_hi_y_lo ).should eq 1
    ( point_x_hi_y_lo <=> point_x_lo_y_hi ).should eq -1
    point_x_lo_y_lo = Iqeo::Mesh::Point.new @x_lo, @y_lo
    ( point_x_hi_y_lo <=> point_x_lo_y_lo ).should eq 1
    ( point_x_lo_y_lo <=> point_x_hi_y_lo ).should eq -1
    point_x_lo_y_hi_again = Iqeo::Mesh::Point.new @x_lo, @y_hi
    ( point_x_lo_y_hi       <=> point_x_lo_y_hi_again ).should eq 0
    ( point_x_lo_y_hi_again <=> point_x_lo_y_hi       ).should eq 0
  end

end