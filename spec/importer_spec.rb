require 'dry/dependency_injection/importer'
$LOAD_PATH << 'example'

describe Dry::DependencyInjection::Importer do

  it 'imports the example plugins' do
    require 'setup'

    result = App.new.run
    expect(result.keys).to match_array ['first', 'second', 'ng.third']
    expect(result.values.collect{|v| v.sub(/:0.*/, '')}).to match_array ['#<First', '#<Second', '#<Ng::Third']
  end
end
