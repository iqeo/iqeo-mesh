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
      [ @p0, @p1, @p2 ] => { clockwise: true,  collinear: false, cross_product:  300 },
      [ @p0, @p2, @p1 ] => { clockwise: false, collinear: false, cross_product: -300 },
      [ @p1, @p0, @p2 ] => { clockwise: false, collinear: false, cross_product: -300 },
      [ @p1, @p2, @p0 ] => { clockwise: true,  collinear: false, cross_product:  300 },
      [ @p2, @p0, @p1 ] => { clockwise: true,  collinear: false, cross_product:  300 },
      [ @p2, @p1, @p0 ] => { clockwise: false, collinear: false, cross_product: -300 }
    }

    @collinear_point_combos = {
      [ @p3, @p4, @p5 ] => { clockwise: nil, collinear: true, cross_product: 0 },
      [ @p3, @p5, @p4 ] => { clockwise: nil, collinear: true, cross_product: 0 },
      [ @p4, @p3, @p5 ] => { clockwise: nil, collinear: true, cross_product: 0 },
      [ @p4, @p5, @p3 ] => { clockwise: nil, collinear: true, cross_product: 0 },
      [ @p5, @p3, @p4 ] => { clockwise: nil, collinear: true, cross_product: 0 },
      [ @p5, @p4, @p3 ] => { clockwise: nil, collinear: true, cross_product: 0 }
    }

    @all_point_combos = @triangle_point_combos.merge @collinear_point_combos

    @unique_points = [ @p0, @p1, @p2, @p3, @p4, @p5 ]

  end

  it 'calculates the cross product of 3 points' do
    @all_point_combos.each do |points,answer|
      cross_product( points ).should eq answer[:cross_product]
    end
  end

  it 'tests 3 points are ordered clockwise' do
    @all_point_combos.each do |points,answer|
      clockwise?( points ).should eq answer[:clockwise]
    end
  end

  it 'tests 3 points are ordered anti-clockwise' do
    @all_point_combos.each do |points,answer|
      anticlockwise?( points ).should eq ( answer[:clockwise].nil? ? nil : ! answer[:clockwise] )
    end
  end

  it 'tests 3 points are collinear' do
    @all_point_combos.each do |points,answer|
      collinear?( points ).should eq answer[:collinear]
    end
  end

  it 'orders 3 points clockwise' do
    points_clockwise_from_topleft = [ @p0, @p1, @p2 ]
    @triangle_point_combos.keys.each do |points|
      clockwise( points ).should eq points_clockwise_from_topleft
    end
  end

  it 'does not reorder colinear points clockwise' do
    @collinear_point_combos.keys.each do |points|
      clockwise( points ).should be_nil
    end
  end

  describe 'reduces collections of pointy things to a set of unique points' do

    it 'accepts a collection of points' do
      unique = unique_points @all_point_combos.keys.flatten
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