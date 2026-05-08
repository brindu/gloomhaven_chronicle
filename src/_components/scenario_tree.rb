class ScenarioTree < ApplicationComponent
  NODE_W = 180
  NODE_H = 44
  ROW_H  = 56
  COL_W  = 220
  PAD_X  = 12
  PAD_Y  = 24
  WRAP_CHARS = 20
  LINE_DY = "1.15em".freeze

  Node = Struct.new(:name, :state, :x, :y, :name_lines, keyword_init: true)
  Edge = Struct.new(:x1, :y1, :x2, :y2, keyword_init: true)

  attr_reader :nodes, :edges, :width, :height

  def initialize(root_id:)
    @root_id = root_id.to_s
    @nodes = []
    @edges = []
    @leaf_cursor = 0
    @max_depth = 0
    @laid_out = {}
    layout(@root_id, 0)
    @width  = (@max_depth * COL_W) + NODE_W + (PAD_X * 2)
    @height = (@leaf_cursor * ROW_H) + (PAD_Y * 2)
  end

  def text_start_y(line_count)
    line_count == 1 ? 27 : 20
  end

  private

  def layout(id, depth)
    @max_depth = depth if depth > @max_depth
    return @laid_out[id] if @laid_out.key?(id)

    scenario = site.data.scenarios[id]
    return nil if scenario.nil?

    children_ids = Array(scenario.links).map(&:to_s).select { |cid| site.data.scenarios.key?(cid) }
    own_children = []
    cross_children = []
    children_ids.each do |cid|
      if @laid_out.key?(cid)
        cross_children << @laid_out[cid]
      else
        node = layout(cid, depth + 1)
        own_children << node if node
      end
    end

    y = if own_children.empty?
          row = @leaf_cursor
          @leaf_cursor += 1
          PAD_Y + (row * ROW_H) + (ROW_H / 2.0)
        else
          ys = own_children.map(&:y)
          (ys.min + ys.max) / 2.0
        end

    x = PAD_X + (depth * COL_W)
    node = Node.new(
      name: scenario.name,
      state: scenario.state,
      x: x,
      y: y,
      name_lines: wrap_name(scenario.name),
    )
    @nodes << node
    @laid_out[id] = node

    parent_anchor_x = x + NODE_W
    (own_children + cross_children).each do |c|
      @edges << Edge.new(x1: parent_anchor_x, y1: y, x2: c.x, y2: c.y)
    end

    node
  end

  def wrap_name(name)
    return [name.to_s] if name.to_s.length <= WRAP_CHARS
    words = name.to_s.split
    return words if words.size <= 1

    best = (1...words.size).min_by do |i|
      line1 = words[0...i].join(" ").length
      line2 = words[i..].join(" ").length
      [[line1, line2].max, (line1 - line2).abs]
    end
    [words[0...best].join(" "), words[best..].join(" ")]
  end
end
