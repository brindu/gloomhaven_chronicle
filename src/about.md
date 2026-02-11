---
layout: page
title: About
---

The chronicles of **Croaky's Waste Management Services** — a ragtag company of adventurers making their way through the shadowed world of Gloomhaven. What started as a simple job retrieving stolen documents has spiraled into a saga of dungeon delving, moral quandaries, and the occasional sandwich.

## The Party

<div class="characters-grid">
  <% site.data.characters.each do |character| %>
    <div class="character-card">
      <div class="character-name"><%= character.name %></div>
      <div class="character-class"><%= character["class"] %></div>
      <% if character.story.to_s.strip.length > 0 %>
        <div class="character-story"><%= character.story %></div>
      <% end %>
    </div>
  <% end %>
</div>
