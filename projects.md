---
layout: page
title: Projects
eyebrow: Complete work index
description: Production tools, systems coursework, and research—with contribution and outcome kept distinct.
permalink: /projects/
wide: true
body_class: projects-page
---
{% assign projects = site.data.portfolio.projects %}

<section class="projects-featured" aria-labelledby="featured-projects-title">
  <h2 id="featured-projects-title">Featured evidence</h2>
  {% for project in projects.featured %}
    {% include components/evidence-row.html project=project show_technologies=true %}
  {% endfor %}
</section>

<section class="projects-index" aria-labelledby="complete-projects-title">
  <h2 id="complete-projects-title">Complete project archive</h2>
  {% for group in projects.groups %}
    <section class="project-group" aria-labelledby="group-{{ group.id }}">
      <h2 id="group-{{ group.id }}">{{ group.label }}</h2>
      {% assign group_projects = projects.archive | where: "group", group.id %}
      <div class="project-index-list">
        {% for project in group_projects %}
          <article class="project-index-row" id="{{ project.id }}">
            <div class="project-index-row__heading">
              <p class="project-provenance">{{ project.provenance }}</p>
              <h3>{{ project.title }}</h3>
            </div>
            <div>
              <p>{{ project.summary }}</p>
              <p class="technology-line"><span>Technologies</span> {{ project.technologies | join: " · " }}</p>
              {% include components/project-links.html links=project.links title=project.title %}
            </div>
          </article>
        {% endfor %}
      </div>
    </section>
  {% endfor %}
</section>
