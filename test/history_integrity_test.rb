# frozen_string_literal: true

require_relative "helper"

class HistoryIntegrityTest < Test::Unit::TestCase
  include PortfolioTestSupport

  EXPECTED_POST_ROUTES = %w[
    2025/07/02/welcome-to-myblog.html
    2025/07/04/new-project.html
    2025/07/11/mongodb-devday.html
    2025/07/15/the-last-day.html
    2025/07/23/Vizthinker.html
    2025/08/01/Launch.html
    2025/09/07/Umich.html
    2025/11/26/Fall-end.html
    2025/12/31/cse599-report.html
    2026/05/25/Machine-Learning-Project.html
  ].freeze

  def setup
    assert_built_site!
  end

  def test_approved_source_and_artifact_checksums_are_unchanged
    manifest = yaml_file("test/fixtures/content_checksums.yml")
    manifest.fetch("posts").merge(manifest.fetch("artifacts")).each do |relative_path, expected|
      path = ROOT.join(relative_path)
      assert_path_exist(path)
      assert_equal(expected, Digest::SHA256.file(path).hexdigest, relative_path)
    end
  end

  def test_all_historical_post_routes_are_preserved_case_sensitively
    actual = Dir[SITE_DIR.join("20??/**/*.html")].map do |path|
      Pathname(path).relative_path_from(SITE_DIR).to_s
    end.sort
    assert_equal(EXPECTED_POST_ROUTES.sort, actual)
  end

  def test_all_public_artifacts_exist_in_the_built_artifact
    manifest = yaml_file("test/fixtures/content_checksums.yml")
    manifest.fetch("artifacts").each_key do |relative_path|
      next unless relative_path.start_with?("assets/")

      assert_path_exist(SITE_DIR.join(relative_path), relative_path)
    end
  end

  def test_required_config_profile_duplication_is_guarded
    config = yaml_file("_config.yml")
    profile = portfolio_file("profile")
    assert_equal(profile.dig("identity", "name"), config.fetch("author"))
    assert_equal(profile.dig("contact", "email"), config.fetch("email"))
    assert_equal("#{profile.dig('identity', 'name')} | Portfolio", config.fetch("title"))
    assert_equal(profile.dig("identity", "seo_description"), config.fetch("description"))
    assert_equal("https://chyhsu.com", config.fetch("url"))
    assert_equal("chyhsu.com", ROOT.join("CNAME").read)
  end
end
