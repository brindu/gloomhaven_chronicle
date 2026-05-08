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

  def initialize(root:)
    @root = root
    @nodes = []
    @edges = []
    @leaf_cursor = 0
    @max_depth = 0
    layout(@root, 0)
    @width  = (@max_depth * COL_W) + NODE_W + (PAD_X * 2)
    @height = (@leaf_cursor * ROW_H) + (PAD_Y * 2)
  end

  def text_start_y(line_count)
    line_count == 1 ? 27 : 20
  end

  private

  def layout(scenario, depth)
    @max_depth = depth if depth > @max_depth
    children = Array(scenario.links).map { |id| site.data.scenarios[id.to_s] }.compact
    child_nodes = children.map { |c| layout(c, depth + 1) }

    y = if child_nodes.empty?
          row = @leaf_cursor
          @leaf_cursor += 1
          PAD_Y + (row * ROW_H) + (ROW_H / 2.0)
        else
          (child_nodes.first.y + child_nodes.last.y) / 2.0
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

    parent_anchor_x = x + NODE_W
    child_nodes.each do |c|
      @edges << Edge.new(x1: parent_anchor_x, y1: y, x2: c.x, y2: c.y)
    end

    node
  end

  def wrap_name(name)
    words = name.to_s.split
    lines = []
    current = ""
    words.each do |w|
      candidate = current.empty? ? w : "#{current} #{w}"
      if candidate.length <= WRAP_CHARS
        current = candidate
      else
        lines << current unless current.empty?
        current = w
      end
    end
    lines << current unless current.empty?
    lines.size > 2 ? [lines.first, lines[1..].join(" ")] : lines
  end
end
