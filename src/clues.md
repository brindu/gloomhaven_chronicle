---
layout: page
title: Clues
---

This list all the clues we have found so far.

<% site.data.clues.each do |clue| %>
  <h3><%= clue.origin %></h3>

  <p><i><%= clue.text %></i></p>
<% end %>
