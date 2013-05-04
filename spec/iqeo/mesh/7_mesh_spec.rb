require 'iqeo/mesh'

describe 'Mesh' do

  before :all do
    @height = 1000
    @width  = 1000
    # container box points
    @pcb0 = Iqeo::Mesh::Point.new 0, 0
    @pcb1 = Iqeo::Mesh::Point.new 0, @height
    @pcb2 = Iqeo::Mesh::Point.new @width, 0
    @pcb3 = Iqeo::Mesh::Point.new @width, @height
    @container_box_points = [ @pcb0, @pcb1, @pcb2, @pcb3 ]
    # container triangle points
    @pct0 = Iqeo::Mesh::Point.new 0, 0
    @pct1 = Iqeo::Mesh::Point.new 0,@height * 2
    @pct2 = Iqeo::Mesh::Point.new @width * 2, 0
    @container_triangle_points = [ @pct0, @pct1, @pct2 ]
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
    # points inside triangle, with no collinear points
    @pi0 = Iqeo::Mesh::Point.new 22, 16
    @pi1 = Iqeo::Mesh::Point.new 16, 24
    @pi2 = Iqeo::Mesh::Point.new 24, 22
    @points_inside_triangle = [ @pi0, @pi1, @pi2 ]
    # points outside triangle, single edge visible, with no collinear points
    @pos0 = Iqeo::Mesh::Point.new 28, 12
    @pos1 = Iqeo::Mesh::Point.new 28, 27
    @pos2 = Iqeo::Mesh::Point.new 12, 13
    @points_outside_single = [ @pos0, @pos1, @pos2 ]
    # points outside triangle, multiple edges visible
    @pom0 = Iqeo::Mesh::Point.new 40, 20
    @pom1 = Iqeo::Mesh::Point.new 1, 40
    @pom2 = Iqeo::Mesh::Point.new 20, 0
    @points_outside_multiple = [ @pom0, @pom1, @pom2 ]
    # point sequence to fail delaunay for simple triangulation
    @points_failing_delaunay_for_simple_triangulation = @triangle_points + @points_outside_multiple
    @points_passing_delaunay_for_simple_triangulation = @triangle_points
    # collinear points
    @pl0 = Iqeo::Mesh::Point.new 50, 60
    @pl1 = Iqeo::Mesh::Point.new 60, 70
    @pl2 = Iqeo::Mesh::Point.new 70, 80
    @collinear_points = [ @pl0, @pl1, @pl2 ]
    # points inside triangle, with collinear points
    @pic0 = Iqeo::Mesh::Point.new 16, 16
    @pic1 = Iqeo::Mesh::Point.new 18, 18
    @pic2 = Iqeo::Mesh::Point.new 22, 22
    @points_inside_triangle_collinear = [ @pic0, @pic1, @pic2 ]
    # points outside triangle, single edge visible, with collinear points
    @posc0 = Iqeo::Mesh::Point.new 28, 12
    @posc1 = Iqeo::Mesh::Point.new 28, 28
    @posc2 = Iqeo::Mesh::Point.new 12, 12
    @points_outside_single_collinear = [ @posc0, @posc1, @posc2 ]
    # square grid of points
    @square_grid = 6.times.inject([]) { |a,x| a = a + 6.times.collect { |y| Iqeo::Mesh::Point.new (x+1)*100, (y+1)*100 } }
    # points on bounding box
    @bp0 = Iqeo::Mesh::Point.new    0,  100
    @bp1 = Iqeo::Mesh::Point.new  100,    0
    @bp2 = Iqeo::Mesh::Point.new 1000,  200
    @bp3 = Iqeo::Mesh::Point.new  200, 1000
    @box_points = [ @bp0, @bp1, @bp2, @bp3 ]
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
      mesh.options[:container].should     eq :box
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

  it 'checks self for consistency' do
    mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :simple
    mesh.check?.should be_true
    @triangle_points.each { |point| mesh.add_point_at point.x, point.y }
    mesh.check?.should be_true
  end

  context 'simple triangulation' do

    it 'is default' do
      mesh = Iqeo::Mesh::Mesh.new @width, @height
      @triangle_points.each { |point| mesh.add_point_at point.x, point.y }
      mesh.points.size.should eq 3
      mesh.edges.size.should eq 3
      mesh.triangles.size.should eq 1
      mesh.check?.should be_true
    end

    it 'can be specified' do
      mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :simple
      @triangle_points.each { |point| mesh.add_point_at point.x, point.y }
      mesh.points.size.should eq 3
      mesh.edges.size.should eq 3
      mesh.triangles.size.should eq 1
      mesh.check?.should be_true
    end

    context 'adds points' do

      it  'inside triangle' do
        mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :simple
        @triangle_points.each { |point| mesh.add_point_at point.x, point.y }
        mesh.triangles.size.should eq 1
        @points_inside_triangle.each_with_index do |point,i|
          mesh.add_point_at point.x, point.y
          mesh.triangles.size.should eq ( 1 + ( ( i + 1 ) * 2 ) )                  # 1 -> 3 -> 5 -> 7 triangles
          mesh.triangles.select { |t| t.points.include? point }.size.should eq 3  # always 3 triangles centered around new point
        end
        mesh.check?.should be_true
      end

      context 'outside triangle' do

        it 'with single edge visible' do
          mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :simple
          @triangle_points.each { |point| mesh.add_point_at point.x, point.y }
          mesh.triangles.size.should eq 1
          @points_outside_single.each_with_index do |point,i|
            mesh.add_point_at point.x, point.y
            mesh.triangles.size.should eq ( i + 2 )
          end
          mesh.check?.should be_true
        end

        it 'with multiple edges visible' do
          mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :simple
          @triangle_points.each { |point| mesh.add_point_at point.x, point.y }
          mesh.triangles.size.should eq 1
          @points_outside_multiple.each_with_index do |point,i|
            mesh.add_point_at point.x, point.y
            mesh.triangles.size.should eq ( 1 + ( ( i + 1 ) * 2 ) )  # 1 -> 3 -> 5 -> 7 triangles
            mesh.hull.points.size.should eq 3                        # hull stays a triangle as each vertex is extended to new point
          end
          mesh.check?.should be_true
        end

      end

    end

    context 'does not maintain delaunay' do

      it 'test may pass' do
        mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :simple
        @points_passing_delaunay_for_simple_triangulation.each { |point| mesh.add_point_at point.x, point.y }
        mesh.should be_delaunay
      end

      it 'test may fail' do
        mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :simple
        @points_failing_delaunay_for_simple_triangulation.each { |point| mesh.add_point_at point.x, point.y }
        mesh.should_not be_delaunay
      end

    end

  end

  context 'bowyer-watson triangulation' do

    context 'when specified' do

      it 'defaults to container box' do
        mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :bowyerwatson
        mesh.options[:container].should eq :box
        mesh.points.should be_empty
        mesh.add_point_at @pt0.x, @pt0.y
        mesh.triangles.size.should eq 4
        mesh.points.should eq ( @container_box_points + [ @pt0 ] ).to_set
        mesh.check?.should be_true
      end

      it 'accepts container box' do
        mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :bowyerwatson, container: :box
        mesh.options[:container].should eq :box
        mesh.points.should be_empty
        mesh.add_point_at @pt0.x, @pt0.y
        mesh.triangles.size.should eq 4
        mesh.points.should eq ( @container_box_points + [ @pt0 ] ).to_set
        mesh.check?.should be_true
      end

      it 'accepts container triangle' do
        mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :bowyerwatson, container: :triangle
        mesh.options[:container].should eq :triangle
        mesh.points.should be_empty
        mesh.add_point_at @pt0.x, @pt0.y
        mesh.triangles.size.should eq 3
        mesh.points.should eq ( @container_triangle_points + [ @pt0 ] ).to_set
        mesh.check?.should be_true
      end

    end

    context 'adds points' do

      it 'of a small triangle in container box' do
        mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :bowyerwatson, container: :box
        @triangle_points.each { |point| mesh.add_point_at point.x, point.y }
        mesh.triangles.size.should eq 8
        mesh.check?.should be_true
      end

      it 'of a small triangle in container triangle' do
        mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :bowyerwatson, container: :triangle
        @triangle_points.each { |point| mesh.add_point_at point.x, point.y }
        mesh.triangles.size.should eq 7
        mesh.check?.should be_true
      end

      it 'does not raise exception for small triangle and collinear points' do
        mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :bowyerwatson, container: :box
        @triangle_points.each { |point| mesh.add_point_at point.x, point.y }
        @collinear_points.each do |point|
          expect { mesh.add_point_at point.x, point.y }.to_not raise_error
          mesh.should be_check
          mesh.should be_delaunay
        end
      end

    end

    context 'maintains delaunay mesh' do

      it 'for small triangle' do
        mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :bowyerwatson, container: :box
        @triangle_points.each do |point|
          mesh.add_point_at point.x, point.y
          mesh.check?.should be_true
          mesh.should be_delaunay
        end
      end

      context 'with non-collinear points' do

        it 'for small triangle and points inside' do
          mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :bowyerwatson, container: :box
          ( @triangle_points + @points_inside_triangle ).each do |point|
            mesh.add_point_at point.x, point.y
            mesh.check?.should be_true
            mesh.should be_delaunay
          end
        end

        it 'for small triangle and points outside' do
          mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :bowyerwatson, container: :box
          ( @triangle_points + @points_outside_single ).each do |point|
            mesh.add_point_at point.x, point.y
            mesh.check?.should be_true
            mesh.should be_delaunay
          end
        end

      end

      context 'with collinear points' do

        it 'for small triangle and points inside' do
          mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :bowyerwatson, container: :box
          ( @triangle_points + @points_inside_triangle_collinear ).each do |point|
            mesh.add_point_at point.x, point.y
            mesh.should be_check
            mesh.should be_delaunay
          end
        end

        it 'for small triangle and points outside' do
          mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :bowyerwatson, container: :box
          ( @triangle_points + @points_outside_single_collinear ).each do |point|
            mesh.add_point_at point.x, point.y
            mesh.should be_check
            mesh.should be_delaunay
          end
        end

      end

      it 'with square grid of points (collinear and 4 points on circumcircle)' do
        mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :bowyerwatson, container: :box
        @square_grid.each do |point|
          mesh.add_point_at point.x, point.y
          mesh.check?.should be_true
          mesh.should be_delaunay
        end
      end

      it 'with points on bounding box and pushing fp precision in poly.circumcircle_contains' do
        mesh = Iqeo::Mesh::Mesh.new @width, @height, triangulation: :bowyerwatson, container: :box
        @box_points.each do |point|
          mesh.add_point_at point.x, point.y
          mesh.should be_check
          mesh.should be_delaunay
        end
      end

    end

  end

end