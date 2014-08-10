class ConspireInspired
  attr_reader :data

  def initialize(path)
    @data = get_data(path)

  end

  def get_data(path)
    result = []
    this_path = path + "/*.eml"
    Dir.glob(this_path).each do |file|
      result << File.read(file)
    end
    result
  end
end