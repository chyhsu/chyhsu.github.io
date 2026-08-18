# frozen_string_literal: true

require_relative "helper"

class ContentContractTest < Test::Unit::TestCase
  include PortfolioTestSupport

  FEATURED_IDS = %w[lilac brain_age_ad vizthinker].freeze
  ARCHIVE_IDS = %w[
    jira_issue_search issue_search_mcp file_translator aztec_image_comparison
    mips_cpu os_nachos advanced_compiler quantum_event
  ].freeze

  def test_authoritative_role_order_dates_and_exact_cv_evidence
    roles = portfolio_file("experience")
    assert_equal(%w[tsmc qnap], roles.map { |role| role.fetch("id") })
    assert_equal(
      [
        ["TSMC", "Digital Workflow Development Department Intern", "Hsinchu, Taiwan"],
        ["QNAP", "Backend R&D Internship", "Taiwan"]
      ],
      roles.map { |role| role.values_at("organization", "title", "location") }
    )
    assert_equal("May 2026 – Aug 2026", roles[0].fetch("period"))
    assert_equal("Jan 2025 – Jul 2025", roles[1].fetch("period"))
    assert_equal(3, roles[0].fetch("evidence").length)
    assert_equal(4, roles[1].fetch("evidence").length)
    assert_equal(2, roles[0].fetch("evidence").count { |item| item.fetch("homepage") })
    assert_equal(2, roles[1].fetch("evidence").count { |item| item.fetch("homepage") })
    qnap_text = roles[1].fetch("evidence").map { |item| item.fetch("text") }.join(" ")
    assert_include(qnap_text, "50%")
    assert_include(qnap_text, "30%")
  end

  def test_exact_cv_evidence_text_and_order
    roles = portfolio_file("experience")
    assert_equal(
      [
        "Developed an AI-agent workflow with the Claude Agent SDK to automatically triage backend alerts and generate structured incident-analysis reports.",
        "Built integrations to ingest alerts from Alertmanager and retrieve logs and metrics from Kubernetes workloads via ELK and Prometheus.",
        "Designed a hypothesis-driven investigation loop that correlates alerts, logs, and metrics to identify likely root causes and summarize actionable findings for engineering teams."
      ],
      roles.fetch(0).fetch("evidence").map { |item| item.fetch("text") }
    )
    assert_equal(
      [
        "Built a retrieval-augmented Jira issue search system using AWS Bedrock and ChromaDB embeddings, increasing developer issue-resolution efficiency by 50%.",
        "Developed an MCP-based Jira search server that integrates with IDEs, enabling developers to query and explore issues directly from their coding workflow.",
        "Refactored Device Avatar microservices from Python to Go, achieving a 30% performance gain and optimizing deployment on Kubernetes.",
        "Diagnosed and patched a critical memory leak in cloud production by correlating Grafana metrics with execution traces."
      ],
      roles.fetch(1).fetch("evidence").map { |item| item.fetch("text") }
    )
  end

  def test_project_order_inventory_and_exact_brain_age_results
    projects = portfolio_file("projects")
    assert_equal(FEATURED_IDS, projects.fetch("featured").map { |project| project.fetch("id") })
    assert_equal(ARCHIVE_IDS, projects.fetch("archive").map { |project| project.fetch("id") })
    brain_age = projects.fetch("featured").fetch(1)
    assert_equal(
      [
        "0.873 diagnostic accuracy",
        "0.775 macro F1",
        "3.54-year MAE",
        "0.966 R²"
      ],
      brain_age.fetch("project_results")
    )
    assert_equal(
      [
        "Jira Issue Search",
        "Issue Search MCP",
        "File Translator",
        "AZtec Image Comparison",
        "MIPS CPU Architecture",
        "OS Nachos",
        "Advanced Compiler",
        "Quantum Event Identification and Simulation of Quantum Event-Learning Procedures"
      ],
      projects.fetch("archive").map { |project| project.fetch("title") }
    )
  end

  def test_lilac_and_brain_age_attribution_is_narrow
    featured = portfolio_file("projects").fetch("featured")
    lilac = featured.fetch(0)
    contribution = lilac.fetch("my_contribution").join(" ")
    assert_include(contribution, "Azure")
    assert_include(contribution, "GCP")
    assert_not_match(/implemented[^.]*AWS/i, contribution)
    assert_not_match(/higher accuracy|superior|Terraformer/i, contribution)

    brain_age = featured.fetch(1)
    brain_contribution = brain_age.fetch("my_contribution").join(" ")
    assert_include(brain_contribution, "infrastructure")
    assert_include(brain_contribution, "data processing")
    assert_include(brain_contribution, "embeddings")
    assert_include(brain_contribution, "coordinates")
    assert_not_match(/trained|model design/i, brain_contribution)
  end

  def test_archive_provenance_is_explicit
    archive = portfolio_file("projects").fetch("archive")
    assert_equal("QNAP internship work", archive.fetch(0).fetch("provenance"))
    assert_equal("QNAP internship work", archive.fetch(1).fetch("provenance"))
    assert_equal("NTHU thesis and research project", archive.fetch(7).fetch("provenance"))
  end

  def test_education_and_skills_keep_cv_order
    assert_equal(
      [
        "Master of Science in Data Science",
        "Master of Science in Computer Science",
        "Bachelor of Science in Civil Engineering"
      ],
      portfolio_file("education").map { |item| item.fetch("degree") }
    )
    assert_equal(
      ["Sep 2025 – Present", "Sep 2022 – Jan 2025", "Sep 2018 – Jun 2022"],
      portfolio_file("education").map { |item| item.fetch("period") }
    )
    assert_equal(
      ["Languages", "AI & ML", "Cloud & DevOps", "Frameworks & Systems"],
      portfolio_file("skills").map { |group| group.fetch("name") }
    )
    assert_equal(["Python", "C++", "Go"], portfolio_file("skills").first.fetch("items"))
    assert_equal("Scrum", portfolio_file("skills").last.fetch("items").last)
  end
end
