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
end
