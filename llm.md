---
layout: page
title: LLM-readable profile
eyebrow: Structured profile
description: A plain-language rendering of the verified data used by the human-facing portfolio.
permalink: /llm/
---
{% assign profile = site.data.portfolio.profile %}
{% assign experience = site.data.portfolio.experience %}
{% assign projects = site.data.portfolio.projects %}

## Identity and contact

**{{ profile.identity.name }} ({{ profile.identity.native_name }})** — {{ profile.identity.positioning }}

{{ profile.identity.summary }}

- Email: [{{ profile.contact.email }}](mailto:{{ profile.contact.email }})
- GitHub: [{{ profile.contact.github }}]({{ profile.contact.github }})
- LinkedIn: [{{ profile.contact.linkedin }}]({{ profile.contact.linkedin }})
- CV: [Download CV]({{ profile.contact.cv | relative_url }})

## Experience

{% for role in experience %}
### {{ role.organization }} — {{ role.title }}

{{ role.location }} · {{ role.period }}

{% for item in role.evidence %}- {{ item.text }}
{% endfor %}
{% if role.secondary_evidence != empty %}Secondary verified detail:
{% for item in role.secondary_evidence %}- {{ item }}
{% endfor %}{% endif %}

**Technologies:** {{ role.technologies | join: ", " }}
{% endfor %}

## Featured projects

{% for project in projects.featured %}
### {{ project.title }}

**Context:** {{ project.context }}

**My contribution:**
{% for item in project.my_contribution %}- {{ item }}
{% endfor %}

**Project result:**
{% for item in project.project_results %}- {{ item }}
{% endfor %}

**Technologies:** {{ project.technologies | join: ", " }}

**Evidence links:**
{% assign verified_links = project.links | where: "verified", true %}
{% for link in verified_links %}{% assign href = link.url %}{% unless href contains '://' %}{% assign href = href | relative_url %}{% endunless %}- [{{ link.label }}]({{ href }})
{% endfor %}
{% endfor %}

## Additional projects

{% for project in projects.archive %}{% assign verified_links = project.links | where: "verified", true %}- **{{ project.title }} ({{ project.provenance }}):** {{ project.summary }} {% for link in verified_links %}{% assign href = link.url %}{% unless href contains '://' %}{% assign href = href | relative_url %}{% endunless %}[{{ link.label }}]({{ href }}){% unless forloop.last %}; {% endunless %}{% endfor %}
{% endfor %}

## Skills

{% for group in site.data.portfolio.skills %}- **{{ group.name }}:** {{ group.items | join: ", " }}
{% endfor %}

## Education

{% for item in site.data.portfolio.education %}- **{{ item.degree }}**, {{ item.institution }}, {{ item.location }} — {{ item.period }}
{% endfor %}

## Earlier roles

{% for role in profile.earlier_roles %}- **{{ role.title }}, {{ role.organization }} — {{ role.period }}:** {{ role.detail }}
{% endfor %}

## Records

{% for record in profile.records %}{% assign href = record.url %}{% unless href contains '://' %}{% assign href = href | relative_url %}{% endunless %}- [{{ record.label }}]({{ href }})
{% endfor %}

## Personal background

Originally from {{ profile.background.origin }}, Chun-Yuan's path followed {{ profile.background.transition | downcase }}. Outside technical work, his interests include {{ profile.interests | join: ", " }}.
