---
layout: page
title: LLM-readable profile
eyebrow: Structured profile
intro: A plain-language rendering of the same verified data used on the homepage.
permalink: /llm/
---
{% assign profile = site.data.portfolio.profile %}
{% assign experience = site.data.portfolio.experience %}
{% assign projects = site.data.portfolio.projects %}

## Summary

{{ profile.identity.name }} is an engineer and researcher. {{ profile.identity.summary }}

## Experience

{% for role in experience %}
### {{ role.organization }} — {{ role.title }}

{{ role.location }} · {{ role.period }}

{% for item in role.evidence %}- {{ item.text }}
{% endfor %}
{% endfor %}

## Featured projects

{% for project in projects.featured %}
### {{ project.title }}

{{ project.context }}

{% for item in project.my_contribution %}- My contribution: {{ item }}
{% endfor %}
{% for item in project.project_results %}- Project result: {{ item }}
{% endfor %}
{% endfor %}

## Additional projects

{% for project in projects.archive %}- **{{ project.title }}:** {{ project.summary }}
{% endfor %}

## Skills

{% for group in site.data.portfolio.skills %}- **{{ group.name }}:** {{ group.items | join: ", " }}
{% endfor %}

## Education

{% for item in site.data.portfolio.education %}- **{{ item.degree }}**, {{ item.institution }}, {{ item.location }} — {{ item.period }}
{% endfor %}
