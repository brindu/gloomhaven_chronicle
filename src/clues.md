---
layout: page
title: Clues
---

Fragments of mystery gathered along the way. Each clue brings us closer to unraveling the truth.

<% site.data.clues.each do |clue| %>
  <div class="clue-card">
    <h3><%= clue.origin %></h3>
    <p><%= clue.text %></p>
  </div>
<% end %>
