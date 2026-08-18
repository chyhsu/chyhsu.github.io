# frozen_string_literal: true

require_relative "helper"

class SourceStructureTest < Test::Unit::TestCase
  EXPECTED_PARTIALS = %w[
    _tokens.scss _base.scss _layout.scss _components.scss _pages.scss
  ].freeze

  def test_styles_are_split_by_responsibility
    EXPECTED_PARTIALS.each do |name|
      assert_path_exist(ROOT.join("_sass", name))
    end
    entrypoint = ROOT.join("assets/main.scss").read
    EXPECTED_PARTIALS.each do |name|
      assert_include(entrypoint, %(@use "#{name.delete_prefix("_").delete_suffix(".scss")}";))
    end
  end

  def test_old_monolith_and_theme_script_are_removed
    assert_path_not_exist(ROOT.join("_sass/custom.scss"))
    assert_path_not_exist(ROOT.join("assets/js/custom.js"))
  end

  def test_no_dark_mode_selectors_remain
    source = Dir[ROOT.join("_sass/*.scss")].map { |path| File.read(path) }.join("\n")
    assert_not_match(/dark-mode|light-mode/, source)
  end

  def test_lilac_feature_has_a_scoped_modifier
    components = ROOT.join("_sass/_components.scss").read
    assert_match(
      /\.featured-card--lilac\s*\{[^}]*var\(--color-lilac[^}]*\}/m,
      components
    )
    assert_not_match(
      /\.featured-card(?!-)[^{]*\{[^}]*--color-lilac/m,
      components
    )
  end

  def test_footer_focus_indicator_uses_a_contrasting_token
    components = ROOT.join("_sass/_components.scss").read
    assert_match(
      /\.site-footer\s+a:focus-visible\s*\{[^}]*outline-color:\s*var\(--color-white\);[^}]*\}/m,
      components
    )
  end

  def test_about_internal_assets_use_relative_url
    about = ROOT.join("about.md").read

    assert_include(about, "{{ '/assets/images/20200711_190244-web.jpg' | relative_url }}")
    assert_equal(5, about.scan("| relative_url").length)
  end

  def test_optional_portfolio_collections_are_guarded_before_emitting_lists
    experience = ROOT.join("_includes/sections/experience.html").read
    featured = ROOT.join("_includes/sections/featured-work.html").read
    archive = ROOT.join("_includes/sections/project-archive.html").read

    [experience, featured].each do |template|
      assert_match(/\{% if (?:role|project)\.highlights and (?:role|project)\.highlights != empty %\}/, template)
      assert_match(/\{% if (?:role|project)\.technologies and (?:role|project)\.technologies != empty %\}/, template)
    end
    assert_match(/\{% if project\.technologies and project\.technologies != empty %\}/, archive)
  end
end
