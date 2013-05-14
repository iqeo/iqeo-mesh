require 'iqeo/mesh/polygon'
require 'iqeo/mesh/mesh'

describe 'Polygon' do

  before :all do
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
    # triangle directed edges
    @de0 = Iqeo::Mesh::DirectedEdge.new @edge0, @edge0.points[0]
    @de1 = Iqeo::Mesh::DirectedEdge.new @edge1, @edge1.points[0]
    @de2 = Iqeo::Mesh::DirectedEdge.new @edge2, @edge2.points[0]
    @triangle_directed_edges = [ @de0, @de1, @de2 ]
    # points collinear with triangle edges
    @pcol0 = Iqeo::Mesh::Point.new 40, 30
    @pcol1 = Iqeo::Mesh::Point.new 0, 35
    @pcol2 = Iqeo::Mesh::Point.new 25, 0
    @edge_collinear_points = [ @pcol0, @pcol1, @pcol2 ]
    # points contained on triangle edges
    @pcon0 = Iqeo::Mesh::Point.new 25, 15
    @pcon1 = Iqeo::Mesh::Point.new 20, 25
    @pcon2 = Iqeo::Mesh::Point.new 15, 20
    @edge_contained_points = [ @pcon0, @pcon1, @pcon2 ]
    # triangle point sequences
    @triangles_clockwise     = [ [ @pt0, @pt1, @pt2 ], [ @pt1, @pt2, @pt0 ], [ @pt2, @pt0, @pt1 ] ]
    @triangles_anticlockwise = [ [ @pt0, @pt2, @pt1 ], [ @pt1, @pt0, @pt2 ], [ @pt2, @pt1, @pt0 ] ]
    # triangle attributes
    @center = Iqeo::Mesh::Point.new 18, 21
    @radius2 = 138
    # points inside triangle
    @pi0 = Iqeo::Mesh::Point.new 20, 13
    @pi1 = Iqeo::Mesh::Point.new 13, 27
    @pi2 = Iqeo::Mesh::Point.new 28, 20
    @points_inside_triangle = [ @center, @pi0, @pi1, @pi2 ]
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
    # collinear points
    @pl0 = Iqeo::Mesh::Point.new 50, 60
    @pl1 = Iqeo::Mesh::Point.new 60, 70
    @pl2 = Iqeo::Mesh::Point.new 70, 80
    @pl3 = Iqeo::Mesh::Point.new 80, 90
    @pl4 = Iqeo::Mesh::Point.new 90, 100
    @pl5 = Iqeo::Mesh::Point.new 100, 110
    @pl6 = Iqeo::Mesh::Point.new 110, 120
    @collinear_points = [ @pl0, @pl1, @pl2, @pl3, @pl4, @pl5, @pl6 ]
    # points inside circumcircle
    @pic0 = Iqeo::Mesh::Point.new 13, 17
    @pic1 = Iqeo::Mesh::Point.new 26, 14
    @pic2 = Iqeo::Mesh::Point.new 23, 27
    @points_inside_circumcircle = [ @pic0, @pic1, @pic2 ]
    # points outside circumcircle
    @points_outside_circumcircle = @points_outside_single + @points_outside_multiple
    # triangles with point at origin
    @pao = Iqeo::Mesh::Point.new 0,0
    @triangles_at_origin = [ [ @pao, @pt1, @pt2,], [ @pao, @pt2, @pt1 ], [ @pt1, @pao, @pt2 ], [ @pt1, @pt2, @pao ], [ @pt2, @pao, @pt1 ], [ @pt2, @pao, @pt1 ] ]
    @center_tao = Iqeo::Mesh::Point.new 13, 12
    @radius2_tao = 331
    # mesh
    @mesh_height = 1000
    @mesh_width  = 2000
    @mesh = Iqeo::Mesh::Mesh.new @mesh_width, @mesh_height

    # regular polygon points
    @pp0 = Iqeo::Mesh::Point.new 180, 200
    @pp1 = Iqeo::Mesh::Point.new 200, 200
    @pp2 = Iqeo::Mesh::Point.new 220, 220
    @pp3 = Iqeo::Mesh::Point.new 220, 240
    @pp4 = Iqeo::Mesh::Point.new 200, 260
    @pp5 = Iqeo::Mesh::Point.new 180, 260
    @pp6 = Iqeo::Mesh::Point.new 160, 240
    @pp7 = Iqeo::Mesh::Point.new 160, 220
    @polygon_points = [ @pp0, @pp1, @pp2, @pp3, @pp4, @pp5, @pp6, @pp7 ]
    @polygon_points_mixed = [ @pp0, @pp2, @pp4, @pp7, @pp5, @pp6, @pp3, @pp1 ]
    @polygon_center = Iqeo::Mesh::Point.new 190,230
    @polygon_radius2 = 1000
    @pe01 = Iqeo::Mesh::Edge.new @pp0, @pp1
    @pe12 = Iqeo::Mesh::Edge.new @pp1, @pp2
    @pe23 = Iqeo::Mesh::Edge.new @pp2, @pp3
    @pe34 = Iqeo::Mesh::Edge.new @pp3, @pp4
    @pe45 = Iqeo::Mesh::Edge.new @pp4, @pp5
    @pe56 = Iqeo::Mesh::Edge.new @pp5, @pp6
    @pe67 = Iqeo::Mesh::Edge.new @pp6, @pp7
    @pe70 = Iqeo::Mesh::Edge.new @pp7, @pp0
    @polygon_edges = [ @pe01, @pe12, @pe23, @pe34, @pe45, @pe56, @pe67, @pe70 ]
    @polygon_directed_edges = @polygon_edges.collect { |e| Iqeo::Mesh::DirectedEdge.new e, e.points[0] }
    # irregular polygon
    @irregular_polygon_points = [ @pp0, @pp1, @pp3, @pp4, @pp6, @pp7 ]
    @irregular_polygon_points_mixed = [ @pp0, @pp4, @pp7, @pp6, @pp3, @pp1 ]
    @pe13 = Iqeo::Mesh::Edge.new @pp1, @pp3
    @pe46 = Iqeo::Mesh::Edge.new @pp4, @pp6
    @irregular_polygon_edges = [ @pe01, @pe13, @pe34, @pe46, @pe67, @pe70 ]
    @irregular_polygon_directed_edges = @irregular_polygon_edges.collect { |e| Iqeo::Mesh::DirectedEdge.new e, e.points[0] }
  end

  context 'initialization' do

    it 'accepts mesh and 3 clockwise points' do
      @triangles_clockwise.each do |points|
        poly = nil
        expect { poly = Iqeo::Mesh::Polygon.new @mesh, points }.to_not raise_error
        poly.points.should eq @triangle_points
        poly.center.should eq @center
        poly.radius2.to_i.should eq @radius2
        poly.edges.should eq @triangle_edges
        poly.directed_edges.should eq @triangle_directed_edges
      end
    end

    it 'accepts mesh and 3 non-clockwise points' do
      @triangles_anticlockwise.each do |points|
        poly = nil
        expect { poly = Iqeo::Mesh::Polygon.new @mesh, points }.to_not raise_error
        poly.points.should eq @triangle_points
        poly.center.should eq @center
        poly.radius2.to_i.should eq @radius2
        poly.edges.should eq @triangle_edges
        poly.directed_edges.should eq @triangle_directed_edges
      end
    end

    it 'accepts mesh and 3 points with one at origin for special case circumcircle' do
      @triangles_at_origin.each do |points|
        poly = nil
        expect { poly = Iqeo::Mesh::Polygon.new @mesh, points }.to_not raise_error
        poly.center.should eq @center_tao
        poly.radius2.to_i.should eq @radius2_tao
      end
    end

    it 'accepts mesh and >3 clockwise points for a regular polygon' do
      poly = nil
      expect { poly = Iqeo::Mesh::Polygon.new @mesh, @polygon_points }.to_not raise_error
      poly.points.should eq @polygon_points
      poly.edges.should eq @polygon_edges
      poly.directed_edges.should eq @polygon_directed_edges
      poly.center.should eq @polygon_center
      poly.radius2.to_i.should eq @polygon_radius2
    end

    it 'accepts mesh and >3 non-clockwise points for a regular polygon' do
      poly = nil
      expect { poly = Iqeo::Mesh::Polygon.new @mesh, @polygon_points_mixed }.to_not raise_error
      poly.points.should eq @polygon_points
      poly.edges.should eq @polygon_edges
      poly.directed_edges.should eq @polygon_directed_edges
      poly.center.should eq @polygon_center
      poly.radius2.to_i.should eq @polygon_radius2
    end

    it 'accepts mesh and >3 clockwise points for an irregular polygon and does not calculate circumcircle' do
      poly = nil
      expect { poly = Iqeo::Mesh::Polygon.new @mesh, @irregular_polygon_points }.to_not raise_error
      poly.points.should eq @irregular_polygon_points
      poly.edges.should eq @irregular_polygon_edges
      poly.directed_edges.should eq @irregular_polygon_directed_edges
      poly.center.should be_nil
      poly.radius2.should be_nil
    end

    it 'accepts mesh and >3 non-clockwise points for an irregular polygon and does not calculate circumcircle' do
      poly = nil
      expect { poly = Iqeo::Mesh::Polygon.new @mesh, @irregular_polygon_points_mixed }.to_not raise_error
      poly.points.should eq @irregular_polygon_points
      poly.edges.should eq @irregular_polygon_edges
      poly.directed_edges.should eq @irregular_polygon_directed_edges
      poly.center.should be_nil
      poly.radius2.should be_nil
    end

    it 'raises exception for 3 collinear points' do
      @collinear_points.each_cons(3) do |points_triplet|
        expect { Iqeo::Mesh::Polygon.new @mesh, points_triplet }.to raise_error
      end
    end

    it 'raises exception for >3 collinear points' do
      4.upto(@collinear_points.size) do |width|
        @collinear_points.each_cons(width) do |points_triplet|
          expect { Iqeo::Mesh::Polygon.new @mesh, points_triplet }.to raise_error
        end
      end
    end

  end

  it 'checks self for consistency' do
    # fix: make tests independent
    # keep this test near top as poly tests below will add > 2 polys to @edge?s, this will not happen with a single @Mesh
    @poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points
    @poly.should be_consistent
  end

  it 'prints nicely' do
    @poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points
    directed_edges = @poly.directed_edges
    ders = directed_edges.collect { |de| /#{de.start.x}.*#{de.start.y}.*#{de.finish.x}.*#{de.finish.y}/ }
    @poly.to_s.should match( /^.*#{ders[0]}.*#{ders[1]}.*#{ders[2]}.*$/ )
  end

  context 'detects points are' do

    before :all do
      @poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points
    end

    it 'inside' do
      @points_inside_triangle.each { |point| @poly.inside?( point ).should be_true }
    end

    it 'not outside' do
      @points_inside_triangle.each { |point| @poly.outside?( point ).should be_false }
    end

    it 'outside' do
      @points_outside_single.each { |point| @poly.outside?(point).should be_true }
    end

    it 'not inside' do
      @points_outside_single.each { |point| @poly.inside?(point).should be_false }
    end

    it 'within circumcircle' do
      @points_inside_circumcircle.each { |point| @poly.circumcircle_contains(point).should be_true }
    end

    it 'not within circumcircle' do
      @points_outside_circumcircle.each { |point| @poly.circumcircle_contains(point).should be_false }
    end

    it 'outside when collinear not contained on edge' do
      @edge_collinear_points.each do |point|
        @poly.directed_edges.any? { |de| de.collinear? point }.should be_true
        @poly.outside?(point).should be_true
      end
    end

    it 'inside when collinear contained on edge' do
      @edge_contained_points.each do |point|
        @poly.directed_edges.any? { |de| de.contains? point }.should be_true
        @poly.inside?(point).should be_true
      end
    end

  end

  context 'detecting directed_edges visible to outside point' do

    before :all do
      @poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points
    end

    it 'raises exception if point is not outside' do
      @points_inside_triangle.each do |point|
        expect { @poly.directed_edges_visible( point ) }.to raise_error
      end
    end

    it 'detects single directed_edge visible' do
      @points_outside_single.each do |point|
        @poly.directed_edges_visible( point ).should eq @single_directed_edges_visible[ point ]
      end
    end

    it 'detects multiple directed_edge visible' do
      @points_outside_multiple.each do |point|
        @poly.directed_edges_visible( point ).should eq @multiple_directed_edges_visible[ point ]
      end
    end

  end

  context 'detecting edges visible to outside point' do

    before :all do
      @poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points
    end

    it 'raises exception if point is not outside' do
      expect { @poly.edges_visible( @point_inside ) }.to raise_error
    end

    it 'detects single edge visible' do
      @points_outside_single.each do |point|
        @poly.edges_visible( point ).should eq @single_edges_visible[ point ]
      end
    end

    it 'detects multiple edge visible' do
      @points_outside_multiple.each do |point|
        @poly.edges_visible( point ).should eq @multiple_edges_visible[ point ]
      end
    end

  end

  it 'splits into multiple triangles around point' do
    @points_inside_triangle.each do |point|
      @poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points
      triangles = @poly.split point
      triangles.size.should eq 3
      triangles.each { |t| t.points.should include point }
    end
  end

  context 'expands' do

    it 'to a point with single visible edge' do
      @poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points
      @poly.expand @pos2
      @poly.points.should include @pos2
      # todo: if expanded a second time: undefined method `start' for nil:NilClass ./lib/iqeo/mesh/polygon.rb:75:in `expand
      # todo: we don't use expand anymore, until we use triangulation: none !?
      #@points_outside_single.each_with_index do |point,i|
      #  @poly.expand point
      #  @poly.points.should include point
      #  #@poly.edges.size.should eq ( 4 + i )
      #end
    end

    it 'to a point with multiple visible edges' do
      @poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points
      @points_outside_multiple.each do |point|
        @poly.expand point
        @poly.points.should include point
        @poly.edges.size.should eq 3
      end
    end

  end

  context 'neighbors' do

    before :all do
      @mesh = Iqeo::Mesh::Mesh.new @mesh_width, @mesh_height
      @poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points
    end

    it 'may not exist' do
      @poly.neighbors.should be_empty
    end

    context 'can be' do

      before :all do
        @neighbors = @points_outside_single.collect { |point| Iqeo::Mesh::Polygon.new @mesh, [ point, *@single_edges_visible[point] ] }
      end

      it 'known' do
        @poly.neighbors.should eq @neighbors
      end

      it 'merged' do
        @neighbors.each { |neighbor| @poly.merge neighbor }
        @poly.neighbors.should be_empty
        @poly.points.size.should eq 6
        @poly.edges.size.should eq 6
      end

    end

  end

end