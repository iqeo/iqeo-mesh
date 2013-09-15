require 'iqeo/mesh/point_utilities'
require 'iqeo/mesh/point'
require 'iqeo/mesh/edge'

describe 'PointUtilities' do

  include Iqeo::Mesh::PointUtilities

  before :all do

    # points in a triangle
    @p0 = Iqeo::Mesh::Point.new 20, 10
    @p1 = Iqeo::Mesh::Point.new 30, 20
    @p2 = Iqeo::Mesh::Point.new 10, 30

    # collinear points
    @p3 = Iqeo::Mesh::Point.new 50, 60
    @p4 = Iqeo::Mesh::Point.new 60, 70
    @p5 = Iqeo::Mesh::Point.new 70, 80

    @triangle_point_combos = {
      [ @p0, @p1, @p2 ] => { clockwise: true,  anticlockwise: false, collinear: false, cross_product:  300 },
      [ @p0, @p2, @p1 ] => { clockwise: false, anticlockwise: true,  collinear: false, cross_product: -300 },
      [ @p1, @p0, @p2 ] => { clockwise: false, anticlockwise: true,  collinear: false, cross_product: -300 },
      [ @p1, @p2, @p0 ] => { clockwise: true,  anticlockwise: false, collinear: false, cross_product:  300 },
      [ @p2, @p0, @p1 ] => { clockwise: true,  anticlockwise: false, collinear: false, cross_product:  300 },
      [ @p2, @p1, @p0 ] => { clockwise: false, anticlockwise: true,  collinear: false, cross_product: -300 }
    }

    @collinear_point_combos = {
      [ @p3, @p4, @p5 ] => { clockwise: true, anticlockwise: true, collinear: true, cross_product: 0 },
      [ @p3, @p5, @p4 ] => { clockwise: true, anticlockwise: true, collinear: true, cross_product: 0 },
      [ @p4, @p3, @p5 ] => { clockwise: true, anticlockwise: true, collinear: true, cross_product: 0 },
      [ @p4, @p5, @p3 ] => { clockwise: true, anticlockwise: true, collinear: true, cross_product: 0 },
      [ @p5, @p3, @p4 ] => { clockwise: true, anticlockwise: true, collinear: true, cross_product: 0 },
      [ @p5, @p4, @p3 ] => { clockwise: true, anticlockwise: true, collinear: true, cross_product: 0 }
    }

    @collinear_points_top_left = @p3

    @all_3point_combos = @triangle_point_combos.merge @collinear_point_combos

    @unique_points = [ @p0, @p1, @p2, @p3, @p4, @p5 ]

    # polygon points
    @pp0 = Iqeo::Mesh::Point.new 180, 200
    @pp1 = Iqeo::Mesh::Point.new 200, 200
    @pp2 = Iqeo::Mesh::Point.new 220, 220
    @pp3 = Iqeo::Mesh::Point.new 220, 240
    @pp4 = Iqeo::Mesh::Point.new 200, 260
    @pp5 = Iqeo::Mesh::Point.new 180, 260
    @pp6 = Iqeo::Mesh::Point.new 160, 240
    @pp7 = Iqeo::Mesh::Point.new 160, 220
    @barycenter_polygon_points = Iqeo::Mesh::Point.new 190, 230
    @polygon_points_clockwise = [ @pp0, @pp1, @pp2, @pp3, @pp4, @pp5, @pp6, @pp7 ]
    @polygon_points_mixed     = [ @pp1, @pp7, @pp3, @pp6, @pp5, @pp4, @pp0, @pp2 ]
    @polygon_points_anticlockwise = @polygon_points_clockwise.reverse
    @polygon_points_spiral_clockwise = [ @pp0, @pp2, @pp4, @pp6, @pp1, @pp3, @pp5, @pp7 ]
    @polygon_points_spiral_anticlockwise = @polygon_points_spiral_clockwise.reverse

    # collinear points
    @pc11 = Iqeo::Mesh::Point.new 100,100
    @pc22 = Iqeo::Mesh::Point.new 200,200
    @pc33 = Iqeo::Mesh::Point.new 300,300
    @pc44 = Iqeo::Mesh::Point.new 400,400
    @pc55 = Iqeo::Mesh::Point.new 500,500
    @pc66 = Iqeo::Mesh::Point.new 600,600
    @pc12 = Iqeo::Mesh::Point.new 100,200
    @pc21 = Iqeo::Mesh::Point.new 200,100
    @pc13 = Iqeo::Mesh::Point.new 100,300
    @pc31 = Iqeo::Mesh::Point.new 300,100
    @pc14 = Iqeo::Mesh::Point.new 100,400
    @pc41 = Iqeo::Mesh::Point.new 400,100
    @pc15 = Iqeo::Mesh::Point.new 100,500
    @pc51 = Iqeo::Mesh::Point.new 500,100
    @pc16 = Iqeo::Mesh::Point.new 100,600
    @pc61 = Iqeo::Mesh::Point.new 600,100
    @collinear_points_vertical = [ @pc11, @pc21, @pc31, @pc41, @pc51, @pc61 ]
    @collinear_points_horizontal = [ @pc11, @pc12, @pc13, @pc14, @pc15, @pc16 ]
    @collinear_points_diagonal = [ @pc11, @pc22, @pc33, @pc44, @pc55, @pc66 ]

  end

  it 'calculates the cross product of 3 points' do
    @all_3point_combos.each do |points,answer|
      cross_product( points ).should eq answer[:cross_product]
    end
  end

  it 'tests 3 points are ordered clockwise' do
    @all_3point_combos.each do |points,answer|
      clockwise?( points ).should eq answer[:clockwise]
    end
  end

  it 'tests >3 points are ordered clockwise' do
    clockwise?( @polygon_points_clockwise ).should be_true
    clockwise?( @polygon_points_anticlockwise ).should be_false
    clockwise?( @polygon_points_mixed ).should be_false
  end

  it 'tests 3 points are ordered anti-clockwise' do
    @all_3point_combos.each do |points,answer|
      anticlockwise?( points ).should eq answer[:anticlockwise]
    end
  end

  it 'tests >3 points are ordered anti-clockwise' do
    anticlockwise?( @polygon_points_anticlockwise ).should be_true
    anticlockwise?( @polygon_points_clockwise ).should be_false
    anticlockwise?( @polygon_points_mixed ).should be_false
  end

  it 'tests 3 points are collinear' do
    @all_3point_combos.each do |points,answer|
      collinear?( points ).should eq answer[:collinear]
    end
  end

  it 'tests >3 points are collinear' do
    collinear?( @polygon_points_clockwise ).should be_false
    collinear?( @polygon_points_anticlockwise ).should be_false
    collinear?( @polygon_points_mixed ).should be_false
    collinear?( @collinear_points_vertical).should be_true
    collinear?( @collinear_points_horizontal).should be_true
    collinear?( @collinear_points_diagonal).should be_true
  end

  it 'orders 3 points clockwise' do
    points_clockwise_from_topleft = [ @p0, @p1, @p2 ]
    @triangle_point_combos.keys.each do |points|
      clockwise( points ).should eq points_clockwise_from_topleft
    end
  end

  it 'orders >3 points clockwise' do
    clockwise( @polygon_points_mixed ).should eq @polygon_points_clockwise
    clockwise( @polygon_points_anticlockwise ).should eq @polygon_points_clockwise
  end

  it 'orders random shuffles of >3 points clockwise' do
    1000.times do 
      clockwise( @polygon_points_clockwise.shuffle ).should eq @polygon_points_clockwise
    end
  end

  it 'orders a range of point arrays clockwise' do
    min = 1
    limit = 10
    point_arrays = ((min+1)..limit).collect do |max|
      (min..max).collect do |x|
        (min..max).collect do |y|
          Iqeo::Mesh::Point.new(x*10,y*10) #if ( [min,max].include?(x) || [min,max].include?(y) )
        end.compact
      end.flatten
    end
    point_arrays.each do |points|
      sh_points = points.shuffle
      print "#{sh_points.inspect} (#{barycenter sh_points}) => "
      cw_points = clockwise( sh_points )
      puts "#{cw_points.inspect}"
      clockwise?( cw_points ).should be_true
    end
  end

  it 'orders clockwise spiral of >3 points to clockwise polygon' do
    clockwise( @polygon_points_spiral_clockwise ).should eq @polygon_points_clockwise
  end
  
  it 'orders anti-clockwise spiral of >3 points to clockwise polygon' do
    clockwise( @polygon_points_spiral_anticlockwise ).should eq @polygon_points_clockwise
  end
  
  it 'indeterminately orders collinear points clockwise with top-left first' do
    @collinear_point_combos.keys.each do |points|
      clockwise( points ).first.should eq @collinear_points_top_left
    end
  end

  it 'calculates barycenter of points' do
    barycenter( @polygon_points_mixed ).should eq @barycenter_polygon_points
  end

  describe 'reduces collections of pointy things to a set of unique points' do

    it 'accepts a collection of points' do
      unique = unique_points @all_3point_combos.keys.flatten
      unique.should be_an_instance_of Set
      unique.size.should eq @unique_points.size
      @unique_points.each { |point| unique.should include point }
    end

    it 'accepts a collection of edges' do
      edges = []
      @unique_points.each do |start|
        @unique_points.each do |finish|
          edges << Iqeo::Mesh::Edge.new( start, finish ) unless start == finish
        end
      end
      edges.size.should eq 30
      unique = unique_points edges
      unique.should be_an_instance_of Set
      unique.size.should eq @unique_points.size
      @unique_points.each { |point| unique.should include point }
    end

    it 'raises an exception for non-pointy things' do
      expect { unique_points [ :non, :pointy, :things ] }.to raise_error
    end

  end


end