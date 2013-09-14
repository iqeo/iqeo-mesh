module Iqeo
module Mesh

module PointUtilities

=begin

  we only clockwise sort in Polygon.new
  ... using crossproduct to sort clockwise does not work for > 3 points (not a transitive sort function)
  ... do we actually call Polygon.new with > 3 points ? - probably for the 'hole' polygon in bowyer-watson

=end

  def clockwise points
    points = points.to_a
    center = barycenter points
    north, south           = points.partition { |point| point.y <  center.y }
    north_west, north_east =  north.partition { |point| point.x <= center.x }  # <= keeps infinite vertical slope in order in correct quadrant
    south_west, south_east =  south.partition { |point| point.x <= center.x }  # <= keeps infinite vertical slope in order in correct quadrant
    # ordered quadrants clockwise and sort points by slope to center
    cw_points = [ north_west, north_east, south_east, south_west ].collect do |quadrant|
      quadrant.sort_by do |point|
        slope = ( center.y - point.y ).to_f / (center.x - point.x).to_f        # FIX: use LCM instead of FP division for integer slope comparison
      end
    end.flatten
    cw_points.rotate( cw_points.index( top_left cw_points ) )    # start with top-left point
  end

  #def gen_points size = 4
  #  (1..size).collect do |x|
  #    (1..size).collect do |y|
  #      Iqeo::Mesh::Point.new(x*10,y*10) if ( [1,size].include?(x) || [1,size].include?(y) )
  #    end.compact
  #  end.flatten
  #end

  def sign n
    return 0 if n == 0
    n > 0 ? 1 : -1
  end

  def top_left points
    min_y = points.min_by { |p| p.y }.y
    points.select { |p| p.y == min_y }.min_by { |p| p.x }
  end

  def barycenter points
    cx = points.inject(0) { |a,p| a += p.x } / points.size
    cy = points.inject(0) { |a,p| a += p.y } / points.size
    Iqeo::Mesh::Point.new cx, cy
  end

  def clockwise? points
    center = barycenter points
    cps = points.each_cons(2).collect do |point_pair|
      cross_product( [ center ] + point_pair )
    end
    case
    when cps.all? { |cp| cp >  0 } then true
    when cps.all? { |cp| cp == 0 } then nil
    else false
    end
  end

  def anticlockwise? points
    center = barycenter points
    cps = points.each_cons(2).collect do |point_pair|
      cross_product( [ center ] + point_pair )
    end
    case
    when cps.all? { |cp| cp <  0 } then true
    when cps.all? { |cp| cp == 0 } then nil
    else false
    end
  end

  def cross_product points
    # FIX: should accept 3 points only - by definition of cross-product
    # + clockwise / - anticlockwise : sign of normal (x2-x1)(y3-y1)-(y2-y1)(x3-x1) gives direction of vector rotation
    ((points[1].x-points[0].x)*(points[2].y-points[0].y))-((points[1].y-points[0].y)*(points[2].x-points[0].x))
  end

  def unique_points pointy_things
    # accepts edges and/or points
    points = Set.new
    pointy_things.each do |thing|
      case
      when thing.kind_of?( Point )
        points.add thing
      when thing.respond_to?( :points )
        points.merge thing.points
      else
        raise 'Not a pointy thing'
      end
    end
    points
  end

  def collinear? points
    points.each_cons(3).collect do |points_triplet|
      cross_product( points_triplet ) == 0 ? true : false
    end.all?
  end

  def collinear_same_side? c, a, b
    # a & b on same side of c ? ...for collinear points c,a,b
    # shift points a & b to center
    an = Point.new a.x - c.x, a.y - c.y
    bn = Point.new b.x - c.x, b.y - c.y
    sign(an.x) == sign(bn.x) && sign(an.y) == sign(bn.y)
  end

  def collinear_opposite_side? c, a, b
    # a & b on opposite side of c ? ...for collinear points c,a,b
    ! collinear_same_side? c, a, b
  end

  def compare_distance c, a, b
    an = Point.new a.x - c.x, a.y - c.y   # translate a to new a relative to center
    bn = Point.new b.x - c.x, b.y - c.y   # translate b to new b relative to center
    an_length2 = an.x**2 + an.y**2        # new a length squared (sqrt not needed for comparison)
    bn_length2 = bn.x**2 + bn.y**2        # new b length squared (sqrt not needed for comparison)
    sign( an - bn )                       # -1/0/+1 same semantics as an <=> bn
  end

end

end
end
