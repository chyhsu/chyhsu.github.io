---
layout: page
title: LLM-readable profile
eyebrow: Structured profile
intro: A plain-language rendering of the same verified data used on the homepage.
permalink: /llm/
---
{% assign profile = site.data.portfolio %}

## Summary

{{ profile.identity.name }} is an engineer and researcher with a background in civil engineering, computer science, and data science. {{ profile.identity.summary }}

## Experience

{% for role in profile.experience %}
### {{ role.organization }} — {{ role.title }}

{{ role.location }} · {{ role.period }}

{% for highlight in role.highlights %}- {{ highlight }}
{% endfor %}
{% endfor %}

## Featured projects

{% for project in profile.featured_projects %}
### {{ project.title }}

{{ project.summary }}

{% for highlight in project.highlights %}- {{ highlight }}
{% endfor %}
{% if project.metrics %}{% for metric in project.metrics %}- Reported result: {{ metric }}
{% endfor %}{% endif %}
{% endfor %}

## Additional projects

{% for project in profile.project_archive %}- **{{ project.title }}:** {{ project.description }}
{% endfor %}

## Skills

{% for group in profile.skill_groups %}- **{{ group.name }}:** {{ group.items | join: ", " }}
{% endfor %}

## Education

{% for item in profile.education %}- **{{ item.degree }}**, {{ item.institution }}, {{ item.location }} — {{ item.period }}
{% endfor %}

## Personal background

Originally from Tainan, Taiwan, Chun-Yuan moved from civil engineering into computer science after discovering a stronger interest in programming. Outside technical work, his interests include sports, fitness, darts, and Linux ricing.
