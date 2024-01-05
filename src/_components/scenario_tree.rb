class ScenarioTree < ApplicationComponent
  attr_reader :root

  def initialize(root:)
    @root = root
  end
end
