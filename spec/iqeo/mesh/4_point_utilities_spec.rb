require 'iqeo/mesh/point_utilities'

describe 'PointUtilities' do

  include Iqeo::Mesh::PointUtilities

  # points in a triangle
  P0 = Iqeo::Mesh::Point.new 20, 10
  P1 = Iqeo::Mesh::Point.new 30, 20
  P2 = Iqeo::Mesh::Point.new 10, 30

  # colinear points
  P3 = Iqeo::Mesh::Point.new 50, 60
  P4 = Iqeo::Mesh::Point.new 60, 70
  P5 = Iqeo::Mesh::Point.new 70, 80

  TRIANGLE_POINT_COMBOS = {
    [ P0, P1, P2 ] => { clockwise: true,  cross_product:  300 },
    [ P0, P2, P1 ] => { clockwise: false, cross_product: -300 },
    [ P1, P0, P2 ] => { clockwise: false, cross_product: -300 },
    [ P1, P2, P0 ] => { clockwise: true,  cross_product:  300 },
    [ P2, P0, P1 ] => { clockwise: true,  cross_product:  300 },
    [ P2, P1, P0 ] => { clockwise: false, cross_product: -300 }
  }

  COLINEAR_POINT_COMBOS = {
    [ P3, P4, P5 ] => { clockwise: nil,   cross_product:    0 },
    [ P3, P5, P4 ] => { clockwise: nil,   cross_product:    0 },
    [ P4, P3, P5 ] => { clockwise: nil,   cross_product:    0 },
    [ P4, P5, P3 ] => { clockwise: nil,   cross_product:    0 },
    [ P5, P3, P4 ] => { clockwise: nil,   cross_product:    0 },
    [ P5, P4, P3 ] => { clockwise: nil,   cross_product:    0 }
  }

  ALL_POINT_COMBOS = TRIANGLE_POINT_COMBOS.merge COLINEAR_POINT_COMBOS

  UNIQUE_POINTS = [ P0, P1, P2, P3, P4, P5 ]

  it 'calculates the cross product of 3 points' do
    ALL_POINT_COMBOS.each do |points,answer|
      cross_product( points ).should eq answer[:cross_product]
    end
  end

  it 'tests 3 points are ordered clockwise' do
    ALL_POINT_COMBOS.each do |points,answer|
      clockwise?( points ).should eq answer[:clockwise]
    end
  end

  it 'tests 3 points are ordered anti-clockwise' do
    ALL_POINT_COMBOS.each do |points,answer|
      anticlockwise?( points ).should eq ( answer[:clockwise].nil? ? nil : ! answer[:clockwise] )
    end
  end

  it 'orders 3 points clockwise' do
    points_clockwise_from_topleft = [ P0, P1, P2 ]
    TRIANGLE_POINT_COMBOS.keys.each do |points|
      clockwise( points ).should eq points_clockwise_from_topleft
    end
  end

  it 'does not reorder colinear points clockwise' do
    COLINEAR_POINT_COMBOS.keys.each do |points|
      clockwise( points ).should eq points
    end
  end

  describe 'reduces collections of pointy things to a set of unique points' do

    it 'accepts a collection of points' do
      unique = unique_points ALL_POINT_COMBOS.keys.flatten
      unique.should be_an_instance_of Set
      unique.size.should eq UNIQUE_POINTS.size
      UNIQUE_POINTS.each { |point| unique.should include point }
    end

    it 'accepts a collection of edges' do
      edges = []
      UNIQUE_POINTS.each do |start|
        UNIQUE_POINTS.each do |finish|
          edges << Iqeo::Mesh::Edge.new( start, finish ) unless start == finish
        end
      end
      edges.size.should eq 30
      unique = unique_points edges
      unique.should be_an_instance_of Set
      unique.size.should eq UNIQUE_POINTS.size
      UNIQUE_POINTS.each { |point| unique.should include point }
    end

    it 'raises an exception for non-pointy things' do
      expect { unique_points [ :non, :pointy, :things ] }.to raise_error
    end

  end


end