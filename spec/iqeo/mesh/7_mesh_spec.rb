require 'iqeo/mesh'

describe 'Mesh' do


  before :all do
    @height = 1000
    @width  = 2000
    # triangle points
    @pt0 = Iqeo::Mesh::Point.new 20, 10
    @pt1 = Iqeo::Mesh::Point.new 30, 20
    @pt2 = Iqeo::Mesh::Point.new 10, 30
    @triangle_points = [ @pt0, @pt1, @pt2 ]
    # triangle edges
    @edge0 = Iqeo::Mesh::Edge.new @pt0, @pt1
    @edge1 = Iqeo::Mesh::Edge.new @pt1, @pt2
    @edge2 = Iqeo::Mesh::Edge.new @pt2, @pt0
    @triangle_edges = [ @edge0, @edge1, @edge2 ]
    # points inside triangle
    @pi0 = Iqeo::Mesh::Point.new 20, 13
    @pi1 = Iqeo::Mesh::Point.new 13, 27
    @pi2 = Iqeo::Mesh::Point.new 28, 20
    @points_inside_triangle = [ @pi0, @pi1, @pi2 ]
     # points outside triangle, single edge visible
    @pos0 = Iqeo::Mesh::Point.new 30, 10
    @pos1 = Iqeo::Mesh::Point.new 30, 30
    @pos2 = Iqeo::Mesh::Point.new 10, 10
    @points_outside_single = [ @pos0, @pos1, @pos2 ]
    @single_directed_edges_visible = { @pos0 => [ @de0 ], @pos1 => [ @de1 ], @pos2 => [ @de2 ] }
    @single_edges_visible = { @pos0 => [ @edge0 ], @pos1 => [ @edge1 ], @pos2 => [ @edge2 ] }
    # points outside triangle, multiple edges visible
    @pom0 = Iqeo::Mesh::Point.new 40, 20
    @pom1 = Iqeo::Mesh::Point.new 0, 40
    @pom2 = Iqeo::Mesh::Point.new 20, 0
    @points_outside_multiple = [ @pom0, @pom1, @pom2 ]
    @multiple_directed_edges_visible = { @pom0 => [ @de0, @de1 ], @pom1 => [ @de1, @de2 ], @pom2 => [ @de2, @de0 ] }
    @multiple_edges_visible = { @pom0 => [ @edge0, @edge1 ], @pom1 => [ @edge1, @edge2 ], @pom2 => [ @edge2, @edge0 ] }
  end

  context 'initialization' do

    it 'accepts height and width' do
      mesh = nil
      expect { mesh = Iqeo::Mesh::Mesh.new @width, @height }.to_not raise_error
      mesh.width.should            eq @width
      mesh.height.should           eq @height
      mesh.points.empty?.should    be_true
      mesh.edges.empty?.should     be_true
      mesh.triangles.empty?.should be_true
      mesh.hull.should             be_nil
    end

    it 'raises exception on nil height & width' do
      expect { Iqeo::Mesh::Mesh.new nil, nil }.to raise_error RuntimeError, 'width and height cannot be nil'
    end

    it 'has default options' do
      mesh = nil
      expect { mesh = Iqeo::Mesh::Mesh.new @width, @height }.to_not raise_error
      mesh.options[:listener].should      be_nil
      mesh.options[:triangulation].should be_false
      mesh.options[:container].should     eq :triangulated_box
    end

    it 'accepts options' do
      mesh = nil
      expect { mesh = Iqeo::Mesh::Mesh.new @width, @height, listener: true, triangulation: true, container: true }.to_not raise_error
      mesh.options[:listener].should      be_true
      mesh.options[:triangulation].should be_true
      mesh.options[:container].should     be_true
    end

  end

  context 'keeps unique' do

    it 'points via new_or_existing_point' do
      mesh = Iqeo::Mesh::Mesh.new @width, @height
      @triangle_points.each do |point|
        first_point = mesh.new_or_existing_point point
        second_point = mesh.new_or_existing_point point
        first_point.should be second_point
      end
      mesh.points.size.should eq 3
      mesh.edges.should be_empty
      mesh.triangles.should be_empty
    end

    it 'points via add_point' do
      mesh = Iqeo::Mesh::Mesh.new @width, @height
      @triangle_points.each do |point|
        first_point = mesh.add_point point
        second_point = mesh.add_point point
        first_point.should be second_point
      end
      mesh.points.size.should eq 3
      mesh.edges.should be_empty
      mesh.triangles.should be_empty
    end

    it 'edges via new_or_existing_edge' do
      mesh = Iqeo::Mesh::Mesh.new @width, @height
      @triangle_edges.each do |edge|
        first_edge = mesh.new_or_existing_edge edge
        second_edge = mesh.new_or_existing_edge edge
        first_edge.should be second_edge
      end
      mesh.edges.size.should eq 3
      mesh.points.should be_empty
      mesh.triangles.should be_empty
    end

  end

  context 'adds points' do

    it 'at coordinates' do
      mesh = Iqeo::Mesh::Mesh.new @width, @height
      mesh.add_point_at @pt0.x, @pt0.y
      mesh.points.size.should eq 1
      mesh.add_point_at @pt1.x , @pt1.y
      mesh.points.size.should eq 2
    end

    it 'or raises exception for bogus triangulation' do
      mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :bogus
      expect { mesh.add_point_at @pt0.x, @pt0.y }.to raise_error 'Unknown triangulation: bogus'
    end

  end

  context 'performs simple triangulation' do

    it 'by default' do
      mesh = Iqeo::Mesh::Mesh.new @width, @height
      @triangle_points.each { |point| mesh.add_point_at point.x, point.y }
      mesh.points.size.should eq 3
      mesh.edges.size.should eq 3
      mesh.triangles.size.should eq 1
    end

    it 'when specified' do
      mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :simple
      @triangle_points.each { |point| mesh.add_point_at point.x, point.y }
      mesh.points.size.should eq 3
      mesh.edges.size.should eq 3
      mesh.triangles.size.should eq 1
    end

    context 'for point added' do

      it  'inside triangle'

      context 'outside triangle' do

        it 'with single edge visible'

        it 'with multiple edges visible'

      end

    end

  end

  context 'detects triangle' do

    it 'at coordinates' do
      mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :simple
      @triangle_points.each { |point| mesh.add_point_at point.x, point.y }
      @points_inside_triangle.each do |point|
        mesh.triangle_at( point.x, point.y ).should_not be_nil
      end
    end

    it 'containing point' do
      mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :simple
      @triangle_points.each { |point| mesh.add_point_at point.x, point.y }
      @points_inside_triangle.each do |point|
        mesh.triangle_containing( point ).should_not be_nil
      end
    end

    it 'does not contain point' do
      mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :simple
      @triangle_points.each { |point| mesh.add_point_at point.x, point.y }
      @points_outside_single.each do |point|
        mesh.triangle_containing( point ).should be_nil
      end
    end

  end

end