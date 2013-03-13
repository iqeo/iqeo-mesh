
require 'iqeo/mesh/version.rb'

describe 'VERSION' do

  it 'provides a semantic version string' do
    version = Iqeo::Mesh::VERSION
    version.should be_an_instance_of String
    version.should match /[0-9]+\.[0-9]+\.[0-9]+/ # semantic versioning
  end

end
