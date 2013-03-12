
class Edge

  include Comparable

  attr_reader :points, :polygons

  def initialize start, finish
    @points = [ start, finish ]
    @polygons = Set.new
  end

  def hash
    # hash is independent of order of points for non-directed edge
    # in mesh set of edges, makes edges with reversed points the same edge (polygon will determine edge direction)
    # original formula ( @points[0].hash * @points[1].hash ) had a degenerate case for point 0,0 (part of super-triangle)
    #  point 0,0 has hash == 0 causing all edges it is part of having the same hash == 0
    @hash ||= ( ( ( ( @points[0].hash & @points[1].hash ) << 32 ) + ( @points[0].hash | @points[1].hash ) ) << 32 ) + 'edge'.unpack('L')[0]
  end

  def eql? other
    hash == other.hash ? true : false
  end

  def == other
    eql? other
  end

  def <=> other
    hash <=> other.hash
  end

  def check
    res = {}
    res[:two_points] = @points.size == 2
    res[:nonzero_length] = @points[0] != @points[1]
    res[:two_polygons_max] = @polygons.size <= 2
    # no check for polygon uniqueness: @polygons is a set, so they must not be the same
    res
  end

  def check?
    ! check.values.include? false
  end

end
