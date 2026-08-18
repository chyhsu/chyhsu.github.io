---
layout: page
title: More About Me
eyebrow: Beyond the résumé
description: An unconventional route from civil engineering to AI, backend systems, and applied machine learning.
permalink: /about/
wide: true
---
{% assign profile = site.data.portfolio.profile %}
{% assign experience = site.data.portfolio.experience %}
{% assign education = site.data.portfolio.education %}

<div class="about-layout">
  <div class="prose">
    <h2>From structures to systems</h2>
    <p>I grew up in {{ profile.background.origin }} and began university studying civil engineering at {{ education[2].institution }}. While learning how physical structures are designed, I became increasingly interested in the logic of building software from a blank screen. That interest led me to computer science at {{ education[1].institution }} and research in quantum computing.</p>
    <p>Today, I am studying {{ education[0].degree }} at {{ education[0].institution }}. My work sits where AI, backend systems, and cloud infrastructure meet: from retrieval and developer tools at {{ experience[1].organization }} to AI-agent incident investigation at {{ experience[0].organization }}, and from cross-cloud infrastructure research to interpretable neuroimaging.</p>
    <p>I still think like someone who changed fields. I enjoy learning a system from first principles, tracing how its pieces interact, and turning that understanding into something practical and dependable.</p>

    <img src="{{ '/assets/images/20200711_190244-web.jpg' | relative_url }}"
         alt="Sunset over a seawall and rocky shoreline" class="about-photo"
         width="1600" height="1200" loading="lazy" decoding="async">

    <h2>Earlier roles</h2>
    {% for role in profile.earlier_roles %}
      <h3>{{ role.title }}, {{ role.organization }} — {{ role.period }}</h3>
      <p>{{ role.detail }}</p>
    {% endfor %}

    <h2>Records</h2>
    <ul class="records-list">
      {% for record in profile.records %}
        {% assign href = record.url %}
        {% unless href contains '://' %}{% assign href = href | relative_url %}{% endunless %}
        <li><a href="{{ href }}">{{ record.label }}</a></li>
      {% endfor %}
    </ul>
  </div>

  <aside class="facts-rail" aria-labelledby="facts-title">
    <h2 id="facts-title">At a glance</h2>
    <p><strong>Current study</strong><br>{{ education.first.degree }}<br>{{ education.first.institution }}</p>
    <p><strong>Current work</strong><br>{{ experience.first.organization }} · {{ experience.first.summary }}</p>
    <h3>Outside the terminal</h3>
    <ul>{% for interest in profile.interests %}<li>{{ interest }}</li>{% endfor %}</ul>
  </aside>
</div>
