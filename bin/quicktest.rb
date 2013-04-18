#! /usr/bin/env ruby

require_relative '../lib/iqeo/mesh'

@mesh_height = 1000
@mesh_width  = 2000
@mesh = Iqeo::Mesh::Mesh.new @mesh_width, @mesh_height

@pt0 = Iqeo::Mesh::Point.new 20, 10
@pt1 = Iqeo::Mesh::Point.new 30, 20
@pt2 = Iqeo::Mesh::Point.new 10, 30
@triangle_points = [ @pt0, @pt1, @pt2 ]

@pcon0 = Iqeo::Mesh::Point.new 25, 15
@pcon1 = Iqeo::Mesh::Point.new 20, 25
@pcon2 = Iqeo::Mesh::Point.new 15, 20
@edge_contained_points = [ @pcon0, @pcon1, @pcon2 ]

@pcol0 = Iqeo::Mesh::Point.new 40, 30
@pcol1 = Iqeo::Mesh::Point.new 0, 35
@pcol2 = Iqeo::Mesh::Point.new 25, 0
@edge_collinear_points = [ @pcol0, @pcol1, @pcol2 ]

@poly = Iqeo::Mesh::Polygon.new @mesh, @triangle_points

print "poly: "
@poly.points.each { |p| print "#{p.x},#{p.y}->" }
puts

def tell a
  case a
  when nil then 'nil  '
  when true then 'true '
  when false then 'false'
  else a
  end
end

def tell_edge_relations point
  @poly.directed_edges.each do |de|
    print "edge: #{de.start.x},#{de.start.y}->#{de.finish.x},#{de.finish.y} - "
    print "collinear? #{tell de.collinear?(point)} "
    print "contains? #{tell de.contains?(point)} "
    print "left? #{tell de.left?(point)} "
    print "right? #{tell de.right?(point)} "
    puts
  end
end

def tell_poly_relations point
  print "inside? #{tell @poly.inside?(point)} "
  print "outside? #{tell @poly.outside?(point)} "
  puts
end

def tell_point point
  puts "point: #{point.x},#{point.y}"
  tell_edge_relations point
  tell_poly_relations point
end

puts '--- edge contained points ---'
@edge_contained_points.each { |point| tell_point point }
puts '--- edge collinear points ---'
@edge_collinear_points.each { |point| tell_point point }
