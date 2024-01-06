class ScenarioTreeEntry < ApplicationComponent
  attr_reader :scenario

  def initialize(scenario:)
    @scenario = scenario
  end

  def scenario_name
    scenario.name
  end

  def next_entries
    scenario.links
  end

  def state
    scenario.state
  end
end
