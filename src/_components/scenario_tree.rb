class ScenarioTree < ApplicationComponent
  NODE_W = 180
  NODE_H = 44
  ROW_H  = 56
  COL_W  = 220
  PAD_X  = 12
  PAD_Y  = 24
  WRAP_CHARS = 20
  LINE_DY = "1.15em".freeze

  Node = Struct.new(:name, :state, :x, :y, :depth, :name_lines, keyword_init: true)
  Edge = Struct.new(:x1, :y1, :x2, :y2, keyword_init: true)

  attr_reader :nodes, :edges, :width, :height

  def initialize(root_id:)
    @root_id = root_id.to_s
    @nodes_by_id = {}
    @edges = []
    @pending_edges = []
    @deferred_ids = []
    @leaf_cursor = 0
    @max_depth = 0
    @parents_of = build_parents_map

    layout(@root_id, 0)
    place_deferred
    resolve_pending_edges

    @nodes = @nodes_by_id.values
    @width  = (@max_depth * COL_W) + NODE_W + (PAD_X * 2)
    @height = (@leaf_cursor * ROW_H) + (PAD_Y * 2)
  end

  def text_start_y(line_count)
    line_count == 1 ? 27 : 20
  end

  private

  def build_parents_map
    map = Hash.new { |h, k| h[k] = [] }
    site.data.scenarios.each do |pid, sc|
      Array(sc.links).each { |c| map[c.to_s] << pid.to_s }
    end
    map
  end

  def multi_parent?(id)
    @parents_of[id].size >= 2
  end

  def child_ids(scenario)
    Array(scenario.links).map(&:to_s).select { |cid| site.data.scenarios.key?(cid) }
  end

  def layout(id, depth)
    return @nodes_by_id[id] if @nodes_by_id.key?(id)
    if id != @root_id && multi_parent?(id)
      @deferred_ids << id unless @deferred_ids.include?(id)
      return nil
    end
    @max_depth = depth if depth > @max_depth

    scenario = site.data.scenarios[id]
    return nil if scenario.nil?

    own_children = []
    child_ids(scenario).each do |cid|
      if multi_parent?(cid)
        @deferred_ids << cid unless @deferred_ids.include?(cid)
        @pending_edges << [id, cid]
      else
        c = layout(cid, depth + 1)
        own_children << c if c
      end
    end

    y = compute_y(own_children)
    x = PAD_X + (depth * COL_W)
    node = make_node(id, scenario, x, y, depth)

    own_children.each do |c|
      @edges << Edge.new(x1: node.x + NODE_W, y1: node.y, x2: c.x, y2: c.y)
    end
    node
  end

  def place_deferred
    loop do
      id = @deferred_ids.find do |did|
        !@nodes_by_id.key?(did) &&
          @parents_of[did].all? { |pid| @nodes_by_id.key?(pid) }
      end
      break unless id
      @deferred_ids.delete(id)
      place_deferred_node(id)
    end
  end

  def place_deferred_node(id)
    parents = @parents_of[id].map { |pid| @nodes_by_id[pid] }
    depth = parents.map(&:depth).max + 1
    @max_depth = depth if depth > @max_depth
    y = parents.map(&:y).sum / parents.size.to_f
    x = PAD_X + (depth * COL_W)

    scenario = site.data.scenarios[id]
    node = make_node(id, scenario, x, y, depth)

    child_ids(scenario).each do |cid|
      if multi_parent?(cid)
        @deferred_ids << cid unless @deferred_ids.include?(cid)
        @pending_edges << [id, cid]
      else
        c = layout(cid, depth + 1)
        @edges << Edge.new(x1: node.x + NODE_W, y1: node.y, x2: c.x, y2: c.y) if c
      end
    end
  end

  def resolve_pending_edges
    @pending_edges.each do |from_id, to_id|
      from = @nodes_by_id[from_id]
      to = @nodes_by_id[to_id]
      next unless from && to
      @edges << Edge.new(x1: from.x + NODE_W, y1: from.y, x2: to.x, y2: to.y)
    end
  end

  def compute_y(own_children)
    if own_children.empty?
      row = @leaf_cursor
      @leaf_cursor += 1
      PAD_Y + (row * ROW_H) + (ROW_H / 2.0)
    else
      ys = own_children.map(&:y)
      (ys.min + ys.max) / 2.0
    end
  end

  def make_node(id, scenario, x, y, depth)
    node = Node.new(
      name: scenario.name,
      state: scenario.state,
      x: x, y: y, depth: depth,
      name_lines: wrap_name(scenario.name),
    )
    @nodes_by_id[id] = node
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
