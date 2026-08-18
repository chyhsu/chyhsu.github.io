# frozen_string_literal: true

require "uri"
require_relative "helper"

class PortfolioSchemaTest < Test::Unit::TestCase
  include PortfolioTestSupport

  def test_required_data_files_and_root_types
    assert_kind_of(Hash, portfolio_file("profile"))
    assert_kind_of(Array, portfolio_file("experience"))
    assert_kind_of(Hash, portfolio_file("projects"))
    assert_kind_of(Array, portfolio_file("education"))
    assert_kind_of(Array, portfolio_file("skills"))
  end

  def test_profile_education_and_skill_nested_types
    profile = portfolio_file("profile")
    assert_equal(%w[background contact earlier_roles identity interests records], profile.keys.sort)
    assert_equal(%w[alt src], profile.dig("identity", "portrait").keys.sort)
    assert_equal(%w[name native_name portrait positioning seo_description summary], profile.fetch("identity").keys.sort)
    assert_equal(%w[origin transition], profile.fetch("background").keys.sort)
    assert_equal(%w[cv email github linkedin], profile.fetch("contact").keys.sort)
    assert(profile.fetch("earlier_roles").all? { |role| role.is_a?(Hash) })
    assert(profile.fetch("interests").all? { |interest| interest.is_a?(String) })
    assert(profile.fetch("records").all? { |record| record.keys.sort == %w[label url] })

    portfolio_file("education").each do |item|
      assert_equal(%w[degree institution location period], item.keys.sort)
    end
    portfolio_file("skills").each do |group|
      assert_equal(%w[items name], group.keys.sort)
      assert(group.fetch("items").all? { |item| item.is_a?(String) })
    end
  end

  def test_experience_schema_and_unique_ids
    roles = portfolio_file("experience")
    assert_equal(roles.length, roles.map { |role| role.fetch("id") }.uniq.length)
    roles.each do |role|
      assert_equal(
        %w[evidence id location organization period secondary_evidence summary technologies title],
        role.keys.sort
      )
      assert_kind_of(Array, role.fetch("evidence"))
      role.fetch("evidence").each do |item|
        assert_equal(%w[homepage text], item.keys.sort)
        assert_boolean(item.fetch("homepage"))
      end
    end
  end

  def test_featured_project_attribution_schema
    portfolio_file("projects").fetch("featured").each do |project|
      assert_equal(
        %w[accent context id links my_contribution project_results technologies title],
        project.keys.sort
      )
      assert_not_empty(project.fetch("my_contribution"))
      assert_not_empty(project.fetch("project_results"))
    end
  end

  def test_archive_groups_ids_and_link_shapes
    projects = portfolio_file("projects")
    assert_equal(
      %w[production_developer_tools systems_coursework research],
      projects.fetch("groups").map { |group| group.fetch("id") }
    )
    all_projects = projects.fetch("featured") + projects.fetch("archive")
    assert_equal(all_projects.length, all_projects.map { |project| project.fetch("id") }.uniq.length)
    projects.fetch("archive").each do |project|
      assert_equal(%w[group id links provenance summary technologies title], project.keys.sort)
      assert_kind_of(Array, project.fetch("technologies"))
    end
    all_projects.flat_map { |project| project.fetch("links") }.each do |link|
      assert_equal(%w[label url verified], link.keys.sort)
      assert_boolean(link.fetch("verified"))
      assert_match(%r{\A(?:https://|/)}, link.fetch("url"))
      URI.parse(link.fetch("url"))
    end
  end

  private

  def assert_boolean(value)
    assert([true, false].include?(value), "Expected boolean, got #{value.inspect}")
  end
end
