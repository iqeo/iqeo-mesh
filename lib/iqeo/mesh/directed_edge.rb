require_relative 'point_utilities'

module Iqeo
module Mesh

class DirectedEdge

  include Comparable
  include PointUtilities

  attr_reader :edge, :start, :finish

  def initialize edge, start = nil
    @edge = edge
    if start
      raise 'Start point not on edge' unless @edge.points.include? start
      @start = start
      @finish = @edge.points.detect { |p| p != @start }
    else
      @start = @edge.points[0]
      @finish = @edge.points[1]
    end
  end

  def points
    @edge.points
  end

  def polygons
    @edge.polygons
  end

  def hash
    # hash is dependent upon order of points for directed edge
    @hash ||= ( ( ( @start.hash << 32 ) + @finish.hash ) << 32 ) + 'dire'.unpack('L')[0]
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

  def left? point
    anticlockwise? [ @start, @finish, point ]
  end

  def right? point
    clockwise? [ @start, @finish, point ]
  end

  def collinear? point
    @edge.collinear? point
  end

  def contains? point
    @edge.contains? point
  end

  def check
    res = {}
    res[:edge_okay] = @edge.check?
    res[:edge_points_match_directed_edge] = ( @edge.points.include?( @start ) && @edge.points.include?( @finish ) )
    res
  end

  def check?
    ! check.values.include? false
  end

end

end
end