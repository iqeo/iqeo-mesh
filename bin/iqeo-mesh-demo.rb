#! /usr/bin/env ruby

require 'tk' # RVM needs: "rvm install ruby-1.9.3 --disable-binary" to force compile from source for TCL/TK support
require 'ostruct'
require_relative '../lib/iqeo/mesh'

CHECK_MESH = true
CHECK_DELAUNAY = true
WIDTH = 1000
HEIGHT = 1000
XOFF = 1
YOFF = 1
DELAY = 0.1
POINT_RADIUS = 3
CENTER_RADIUS = 3
EDGE_WIDTH = 1

def start_gui

  @root = TkRoot.new do
    title 'Iqeo::Mesh demo'
    geometry '1200x1200'
  end

  @button_hover = TkCheckButton.new(@root) do
    text 'Hover'
    set_value true
    command '@hover = @button_hover.variable.bool'
    grid row: 0, column: 0, sticky: 'w'
  end

  @button_display_delaunay = TkCheckButton.new(@root) do
    text 'Delaunay'
    set_value true
    command 'display_button @button_display_delaunay, :delaunay'
    grid row: 0, column: 1, sticky: 'w'
  end

  @button_display_voronoi = TkCheckButton.new(@root) do
    text 'Voronoi'
    set_value false
    command 'display_button @button_display_voronoi, :voronoi'
    grid row: 0, column: 2, sticky: 'w'
  end

  @button_display_points = TkCheckButton.new(@root) do
    text 'Points'
    set_value true
    command 'display_button @button_display_points, :point'
    grid row: 0, column: 3, sticky: 'w'
  end

  @button_display_circles = TkCheckButton.new(@root) do
    text 'Circles'
    set_value true
    command 'display_button @button_display_circles, :circle'
    grid row: 0, column: 4, sticky: 'w'
  end

  @button_display_centers = TkCheckButton.new(@root) do
    text 'Centers'
    set_value false
    command 'display_button @button_display_centers, :center'
    grid row: 0, column: 5, sticky: 'w'
  end

  @label = TkLabel.new(@root) do
    text '...'
    justify :left
    anchor :w
    grid row: 1, column: 0, columnspan: 7, sticky: 'ew'
  end

  @canvas = TkCanvas.new(@root) do
    grid row: 2, column: 0, columnspan: 7, sticky: 'nsew'
  end

  TkGrid.rowconfigure    @root, 2, weight: 1
  TkGrid.columnconfigure @root, 6, weight: 1

end

def display_button btn, tag
  @show[tag] = btn.variable.bool
  @show[tag] ? show( tag ) : hide( tag )
end

def listen_for_events
  @canvas.bind('1') { |e| left_click e }
  @canvas.bind('3') { |e| right_click e }
  @canvas.bind('Motion') { |e| motion e }
end

def ignore_events
  @canvas.bind('1') { |e| e }
  @canvas.bind('3') { |e| e }
  @canvas.bind('Motion') { |e| e }
end

def left_click e
  @label[:text] = "Add point: #{e.x},#{e.y}"
  @hover_triangle = nil # prevent redrawing this triangle & circle when removing hover highlight after mesh processing
  @mesh.add_point_at e.x, e.y
  @mesh.check? if CHECK_MESH
  @mesh.delaunay? if CHECK_DELAUNAY
end

def right_click e
  @label[:text] = "Delete point: #{e.x},#{e.y}"
  # todo: implement... @mesh.delete_point_at e.x, e.y
end

def motion e
  @label[:text] = "#{e.x},#{e.y}"
  hover e.x, e.y
end

def hover x, y
  if @hover
    new_hover_triangle = @mesh.triangle_at( x, y )
    unless new_hover_triangle == @hover_triangle
      if @hover_triangle
        # remove highlight from previous hover triangle
        draw_polygon @hover_triangle, options(:delaunay)
        draw_circumcircle @hover_triangle, options(:circle)
        draw_center @hover_triangle, options(:center)
      end
      if new_hover_triangle
        # highlight new hover triangle
        draw_polygon new_hover_triangle, options(:delaunay, :fill => @color.hole, :width => 3)
        draw_circumcircle new_hover_triangle, options(:circle, :outline => @color.hole_circle)
        draw_center new_hover_triangle, options(:center, :outline => @color.hole_center)
      end
      @hover_triangle = new_hover_triangle
    end
  else
    if @hover_triangle
      # remove highlight from previous hover triangle
      draw_polygon @hover_triangle, options(:delaunay)
      draw_circumcircle @hover_triangle, options(:circle)
      draw_center @hover_triangle, options(:center)
    end
    @hover_triangle = nil
  end
end

def mesh_listener message, *args
  ignore_events # prevent re-entry problems due to fast clicking
  @canvas.cursor = 'watch'
  @canvas.update
  # fix: Mesh should maintain the voronoi graph of cells, centers, and borders !?
  # fix: handle voronoi-related callbacks here
  case message
  when :point_added                              then point_added *args
  when :bowyerwatson_container                   then bowyerwatson_container *args
  when :bowyerwatson_hole                        then bowyerwatson_hole *args
  when :bowyerwatson_circumcircle_contains_point then bowyerwatson_circumcircle_contains_point *args
  when :bowyerwatson_circumcircle_clear          then bowyerwatson_circumcircle_clear *args
  when :bowyerwatson_split                       then bowyerwatson_split *args
  when :delaunay_fail                            then delaunay_fail *args
  else
    raise "Unknown callback message #{message}"
  end
  @canvas.update
  sleep DELAY
  @canvas.cursor = ''
  @canvas.update
  listen_for_events
end

def set_colors
  @color = OpenStruct.new
  @color.normal = '#ddd'
  @color.added_point = '#fea'
  @color.hole = '#4cc'
  @color.hole_circle = '#488'
  @color.hole_center = '#6aa'
  @color.circumcircle_contains_point = '#ff8'
  @color.circumcircle_clear = '#8f8'
  @color.circumcircle_contains_point_circle = '#884'
  @color.circumcircle_clear_circle = '#484'
  @color.circumcircle_contains_point_center = '#aa6'
  @color.circumcircle_clear_center = '#6a6'
  @color.failure = '#f4c'
  @color.circle = '#666'
  @color.center = '#aaa'
end

def point_added point
  draw_point @point, options(:point) if @point
  draw_point point, options(:point, :fill => @color.added_point)
  @point = point
end

def bowyerwatson_container triangles
  triangles.each do |t|
    t.points.each { |p| draw_point p, options(:point) }
    draw_polygon t, options(:delaunay)
    draw_circumcircle t, options(:circle)
    draw_center t, options(:center)
  end
end

def bowyerwatson_hole hole, common_edge = nil
  clear common_edge if common_edge
  # remove previous hole highlighting
  if @hole
    draw_polygon @hole, options(:delaunay)       # remove highlight from hole of previous iteration
  else
    clear_circumcircle hole  # initial hole is the triangle containing the added point, clear its unneeded circumcircle
    clear_center hole
  end
  draw_polygon hole, options(:delaunay, :fill => @color.hole, :width => 3)
  @hole = hole
end

def bowyerwatson_circumcircle_contains_point neighbor
  # track highlighted contain neighbors
  @contain_neighbors ||= []
  @contain_neighbors << neighbor
  # highlight contain neighbor
  draw_polygon neighbor, options(:delaunay, :fill => @color.circumcircle_contains_point, :width => 3)
  draw_circumcircle neighbor, options(:circle, :outline => @color.circumcircle_contains_point_circle)
  draw_center neighbor, options(:center, :outline => @color.circumcircle_contains_point_center)
end

def bowyerwatson_circumcircle_clear neighbor
  # track highlighted clear neighbors
  @clear_neighbors ||= []
  @clear_neighbors << neighbor
  # highlight clear neighbor
  draw_polygon neighbor, options(:delaunay, :fill => @color.circumcircle_clear, :width => 3)
  draw_circumcircle neighbor, options(:circle, :outline => @color.circumcircle_clear_circle)
  draw_center neighbor, options(:center, :outline => @color.circumcircle_clear_center)
  @canvas.update
  sleep DELAY
  # re-highlight hole
  draw_polygon @hole, options(:delaunay, :fill => @color.hole, :width => 3) if @hole
end

def bowyerwatson_split triangles
  # remove clear neighbors highlighting
  if @clear_neighbors
    @clear_neighbors.each do |n|
      draw_polygon n, options(:delaunay)
      draw_circumcircle n, options(:circle)
      draw_center n, options(:center)
    end
    @clear_neighbors = nil
  end
  # remove contain neighbors circumcircles
  if @contain_neighbors
    @contain_neighbors.each do |n|
      clear_circumcircle n
      clear_center n
    end
    @contain_neighbors = nil
  end
  # re-highlight hole
  draw_polygon @hole, options(:delaunay, :fill => @color.hole, :width => 3)
  @canvas.update
  sleep DELAY
  # remove hole
  clear_polygon @hole
  @hole = nil
  # highlight split triangles
  triangles.each do |t|
    draw_polygon t, options(:delaunay, :fill => @color.hole, :width => 3)
    draw_circumcircle t, options(:circle)
    draw_center t, options(:center)
  end
  @canvas.update
  sleep DELAY
  # remove split triangles highlight
  triangles.each { |t| draw_polygon t, options(:delaunay) }
  # old hole was current triangle under mouse, forget it to prevent edge & circumcircle redrawing
  @triangle = nil
end

def delaunay_fail failures
  failures.each do |triangle,points|
    draw_polygon triangle, options(:delaunay, :fill => @color.failure, :width => 3)
    draw_circumcircle triangle, options(:circle, :outline => @color.failure)
    draw_center triangle, options(:center, :outline => @color.failure)
    points.each { |p| draw_point p, options(:point, :fill => @color.failure) }
  end
end

def draw_point point, options = {}
    clear point
    tkopts = { :fill => @color.normal, :outline => nil }.merge options
    @shapes[point] = TkcOval.new @canvas, point.x+XOFF-POINT_RADIUS, point.y+YOFF-POINT_RADIUS, point.x+XOFF+POINT_RADIUS+1, point.y+YOFF+POINT_RADIUS+1, tkopts
end

def draw_polygon polygon, options = {}
  polygon.directed_edges.each do |directed_edge|
    draw_directed_edge directed_edge, options
  end
end

def draw_directed_edge directed_edge, options = {}
  clear directed_edge.edge
  tkopts = { :fill => @color.normal, :width => EDGE_WIDTH, :arrow => :none, :capstyle => :round }.merge options
  @shapes[directed_edge.edge] = TkcLine.new @canvas, directed_edge.start.x+XOFF, directed_edge.start.y+YOFF, directed_edge.finish.x+XOFF, directed_edge.finish.y+YOFF, tkopts
end

def draw_edge edge, options = {}
  clear edge
  tkopts = { :fill => @color.normal, :width => EDGE_WIDTH, :arrow => :none, :capstyle => :round }.merge options
  @shapes[edge] = TkcLine.new @canvas, edge.points[0].x+XOFF, edge.points[0].y+YOFF, edge.points[1].x+XOFF, edge.points[1].y+YOFF, tkopts
end

def draw_circumcircle triangle, options = {}
  clear triangle
  tkopts = { :outline => @color.circle, :width => EDGE_WIDTH }.merge options
  c = triangle.center
  r = Math.sqrt triangle.radius2
  @shapes[triangle] = TkcOval.new @canvas, c.x+XOFF-r, c.y+YOFF-r, c.x+XOFF+r, c.y+YOFF+r, tkopts
end

def draw_center triangle, options = {}
  c = triangle.center
  clear c
  tkopts = { :outline => @color.center, :width => EDGE_WIDTH }.merge options
  @shapes[c] = TkcRectangle.new @canvas, c.x+XOFF-CENTER_RADIUS, c.y+YOFF-CENTER_RADIUS, c.x+XOFF+CENTER_RADIUS, c.y+YOFF+CENTER_RADIUS, tkopts
end

def clear_polygon polygon
  polygon.edges.each { |edge| clear edge }
end

def clear_circumcircle triangle
  clear triangle
end

def clear_center triangle
  clear triangle.center
end

def clear key
  if ( s = @shapes[key] )
    @shapes.delete key
    s.delete
  end
end

def show tag
  @canvas.itemconfigure tag.to_s, :state => :normal
  @canvas.raise tag.to_s
  @canvas.update
end

def hide tag
  @canvas.itemconfigure tag.to_s, :state => :hidden
  @canvas.raise tag.to_s
  @canvas.update
end

def options tag, opts={}
  opts.merge( :tags => tag.to_s, :state => ( @show[tag] ? :normal : :hidden ) )
end

def load_points_from_file filename
  points = File.open(filename).collect do |line|
    xy = line.strip.split(/\D+/)
    OpenStruct.new( x: xy[0].to_i, y: xy[1].to_i ) if xy.size == 2
  end
  points.compact
end

@points = []
unless ARGV.empty?
  puts "Loading points from file: #{ARGV[0]}"
  @points = load_points_from_file ARGV[0]
  puts "#{@points.size} points loaded"
end

@mesh = Iqeo::Mesh::Mesh.new WIDTH, HEIGHT,
                 listener: lambda { |cmd,*args| mesh_listener cmd, *args },
                 triangulation: :bowyerwatson,
                 voronoi: false
@shapes = {}
@show = { delaunay: true, circle: true, point: true, voronoi: false, center: false }
@hover = true

set_colors
start_gui
listen_for_events

gui_thread = Thread.new { Tk.mainloop }

sleep DELAY

@points.each do |p|
  puts "#{p.x}, #{p.y}"
  left_click p
end

gui_thread.join

# end
