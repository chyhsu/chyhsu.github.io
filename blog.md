---
layout: page
title: Blog
permalink: /blog/
---


<div class="posts-container">
  {% for post in site.posts %}
    <div class="post-card">
      <h3><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h3>
      <p class="post-meta">{{ post.date | date: "%B %d, %Y" }}</p>
      <p>{{ post.excerpt | strip_html | truncatewords: 30 }}</p>
      <a href="{{ post.url | relative_url }}" class="read-more-btn">Read More</a>
    </div>
  {% endfor %}
</div>