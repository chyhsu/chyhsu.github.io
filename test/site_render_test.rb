# frozen_string_literal: true

require_relative "helper"

class SiteRenderTest < Test::Unit::TestCase
  include PortfolioTestSupport

  def setup
    build_site!
  end

  def test_standard_page_has_semantic_shell
    html = rendered("about/index.html")
    assert_include(html, '<a class="skip-link" href="#main-content">Skip to content</a>')
    assert_include(html, '<nav class="site-nav" aria-label="Primary navigation">')
    assert_include(html, '<main id="main-content"')
    assert_include(html, 'href="/about/"')
    assert_include(html, 'href="/blog/"')
    assert_include(html, 'href="/assets/pdf/CV.pdf"')
  end

  def test_standard_page_has_no_theme_script_or_background_layer
    html = rendered("about/index.html")
    assert_not_include(html, "custom.js")
    assert_not_include(html, "background-image")
    assert_not_include(html, "dark-mode-toggle")
  end
end
