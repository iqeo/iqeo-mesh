module Iqeo
module Mesh

module PointUtilities

  def clockwise points
    points = points.to_a
    # start with top-left point
    min_y = points.min_by { |p| p.y }.y
    start = points.select { |p| p.y == min_y }.min_by { |p| p.x }
    others = points - [ start ]
    # todo: for 3 points only, extend to n points !!!!!!!!!
    case clockwise? [ start ] + others
    when true  then return [ start, others[0], others[1] ]
    when false then return [ start, others[1], others[0] ]
    else return nil  # points are collinear
    end
  end

  def clockwise? points
    # todo: for 3 points only, extend to list of n points
    cp = cross_product points
    return nil if cp == 0
    cp > 0 ? true : false
  end

  def anticlockwise? points
    # todo: for 3 points only, extend to a list of n points
    cp = cross_product points
    return nil if cp == 0
    cp < 0 ? true : false
  end

  def cross_product points
    # 3 points only - by definition
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
    # todo: for 3 points only, extend to list of n points
    cross_product( points ) == 0 ? true : false
  end

end

end
end
