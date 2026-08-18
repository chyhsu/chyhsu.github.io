# frozen_string_literal: true

require_relative "helper"

class PortfolioDataTest < Test::Unit::TestCase
  include PortfolioTestSupport

  REQUIRED_KEYS = %w[
    identity contact experience featured_projects project_archive
    skill_groups education
  ].freeze

  def test_top_level_contract
    assert_equal(REQUIRED_KEYS.sort, portfolio_data.keys.sort)
  end

  def test_authoritative_experience_order_and_dates
    roles = portfolio_data.fetch("experience")
    assert_equal(%w[tsmc qnap], roles.map { |role| role.fetch("id") })
    assert_equal("May 2026 – Present", roles[0].fetch("period"))
    assert_equal("Jan 2025 – Jul 2025", roles[1].fetch("period"))
  end

  def test_authoritative_featured_project_order
    projects = portfolio_data.fetch("featured_projects")
    assert_equal(
      %w[lilac brain_age_ad vizthinker],
      projects.map { |project| project.fetch("id") }
    )
  end

  def test_cv_metrics_are_exact
    brain_age = portfolio_data.fetch("featured_projects")[1]
    assert_equal(
      ["0.873 diagnostic accuracy", "0.775 macro F1", "3.54-year MAE", "0.966 R²"],
      brain_age.fetch("metrics")
    )
    qnap = portfolio_data.fetch("experience")[1]
    assert(qnap.fetch("highlights").any? { |item| item.include?("50%") })
    assert(qnap.fetch("highlights").any? { |item| item.include?("30%") })
  end

  def test_every_current_site_project_is_preserved
    titles = portfolio_data.fetch("project_archive").map { |project| project.fetch("title") }
    expected = [
      "Jira Issue Search",
      "Issue Search MCP",
      "File Translator",
      "AZtec Image Comparison",
      "MIPS CPU Architecture",
      "OS Nachos",
      "Advanced Compiler",
      "Quantum Event Identification and Simulation of Quantum Event-Learning Procedures"
    ]
    assert_equal(expected, titles)
  end

  def test_optional_links_are_real_urls_or_site_paths
    records = portfolio_data.fetch("featured_projects") +
      portfolio_data.fetch("project_archive")
    records.flat_map { |record| record.fetch("links", []) }.each do |link|
      url = link.fetch("url")
      assert_match(%r{\A(?:https://|/)}, url, "Invalid URL: #{url}")
    end
  end
end
