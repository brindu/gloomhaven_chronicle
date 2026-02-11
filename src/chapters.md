---
layout: page
title: Chapters
---

<ul class="chapter-list">
  <% collections.chapters.resources.each do |chapter| %>
    <li>
      <a href="<%= chapter.relative_url %>">
        <span class="day">Day <%= chapter.data.day %></span>
        <span class="title"><%= chapter.data.title %></span>
      </a>
    </li>
  <% end %>
</ul>
