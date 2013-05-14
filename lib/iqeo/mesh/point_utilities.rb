module Iqeo
module Mesh

module PointUtilities

  def clockwise points
    points = points.to_a
    center = barycenter points
    cw_points = points.sort do |point_a,point_b|
      cross_product [ center, point_b, point_a ]
    end
    # start list with top-left point for consistency
    cw_points.rotate( cw_points.index( top_left cw_points ) )
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
    cps = points.each_cons(3).collect do |points_triplet|
      cross_product( points_triplet )
    end
    case
    when cps.all? { |cp| cp >  0 } then true
    when cps.all? { |cp| cp == 0 } then nil
    else false
    end
  end

  def anticlockwise? points
    cps = points.each_cons(3).collect do |points_triplet|
      cross_product( points_triplet )
    end
    case
    when cps.all? { |cp| cp <  0 } then true
    when cps.all? { |cp| cp == 0 } then nil
    else false
    end
  end

  def cross_product points
    # 3 points only - by definition of cross-product
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

end

end
end
