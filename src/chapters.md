---
layout: page
title: Chapters
---

<ul>
  <% collections.chapters.resources.each do |chapter| %>
    <li>
      <a href="<%= chapter.relative_url %>">Day <%= chapter.data.day %> - <%= chapter.data.title %></a>
    </li>
  <% end %>
</ul>
