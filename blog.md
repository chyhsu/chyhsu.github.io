---
layout: page
title: Blog
eyebrow: Field notes
intro: Project updates, course reflections, and notes from learning in public.
permalink: /blog/
---
<div class="posts-container">
  {% for post in site.posts %}
    <article class="post-card">
      <p class="post-meta"><time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%B %-d, %Y" }}</time></p>
      <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
      <p>{{ post.excerpt | strip_html | truncatewords: 30 }}</p>
      <a href="{{ post.url | relative_url }}" aria-label="Read {{ post.title }}">Read article</a>
    </article>
  {% endfor %}
</div>
