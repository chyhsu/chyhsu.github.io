---
layout: page
title: Blog
eyebrow: Field notes
description: Project updates, course reflections, and notes from learning in public.
permalink: /blog/
wide: true
---
{% assign posts_by_year = site.posts | group_by_exp: "post", "post.date | date: '%Y'" %}
<div class="blog-archive">
  {% for year in posts_by_year %}
    <section class="blog-year" aria-labelledby="posts-{{ year.name }}">
      <h2 id="posts-{{ year.name }}">{{ year.name }}</h2>
      <div class="post-list">
        {% for post in year.items %}
          {% include components/post-row.html post=post heading_level=3 %}
        {% endfor %}
      </div>
    </section>
  {% endfor %}
</div>
