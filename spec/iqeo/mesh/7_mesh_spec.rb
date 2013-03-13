require 'iqeo/mesh'

describe 'Mesh' do

  HEIGHT = 1000
  WIDTH  = 2000

  it 'accepts height and width' do
    mesh = nil
    expect { mesh = Iqeo::Mesh::Mesh.new WIDTH, HEIGHT }.to_not raise_error
    mesh.width.should            eq WIDTH
    mesh.height.should           eq HEIGHT
    mesh.points.empty?.should    be_true
    mesh.edges.empty?.should     be_true
    mesh.triangles.empty?.should be_true
    mesh.hull.should             be_nil
  end

  it 'has default options' do
    mesh = nil
    expect { mesh = Iqeo::Mesh::Mesh.new WIDTH, HEIGHT }.to_not raise_error
    mesh.options[:listener].should      be_nil
    mesh.options[:triangulation].should be_nil
    mesh.options[:container].should     eq :triangulated_box
  end

  it 'accepts options' do
    mesh = nil
    expect { mesh = Iqeo::Mesh::Mesh.new WIDTH, HEIGHT, listener: true, triangulation: true, container: true }.to_not raise_error
    mesh.options[:listener].should      be_true
    mesh.options[:triangulation].should be_true
    mesh.options[:container].should     be_true
  end

end