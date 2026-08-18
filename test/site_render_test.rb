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

  def test_homepage_section_order
    html = rendered("index.html")
    ids = %w[intro work selected-work toolkit more-projects education writing]
    positions = ids.map do |id|
      position = html.index("id=\"#{id}\"")
      assert_not_nil(position, "Missing homepage section ##{id}")
      position
    end
    assert_equal(positions.sort, positions)
  end

  def test_homepage_leads_with_approved_experience_and_projects
    html = rendered("index.html")
    assert_operator(html.index("TSMC"), :<, html.index("QNAP"))
    assert_operator(html.index(">Lilac<"), :<, html.index("Brain Age Prediction"))
    assert_operator(html.index("Brain Age Prediction"), :<, html.index(">VizThinker<"))
    assert_include(html, "May 2026 – Present")
    assert_include(html, "50%")
    assert_include(html, "30%")
    assert_include(html, "0.873 diagnostic accuracy")
  end

  def test_homepage_preserves_the_project_archive
    html = rendered("index.html")
    portfolio_data.fetch("project_archive").each do |project|
      assert_include(html, project.fetch("title"))
    end
  end

  def test_about_is_the_first_hero_action
    html = rendered("index.html")
    about = html.index(">About me<")
    cv = html.index(">Download CV<")
    assert_not_nil(about)
    assert_not_nil(cv)
    assert_operator(about, :<, cv)
  end

  def test_about_photo_is_baseurl_safe_and_performance_annotated
    html = rendered("about/index.html")
    assert_match(
      /<img src="\/assets\/images\/20200711_190244-web\.jpg" alt="Sunset over a seawall and rocky shoreline" class="about-photo" width="1600" height="1200" loading="lazy" decoding="async"\s*\/?>/,
      html
    )
  end

  def test_homepage_has_a_nonredundant_recruiter_facing_title
    html = rendered("index.html")
    assert_include(html, "<title>AI &amp; Backend Engineer | Chun-Yuan Hsu Portfolio</title>")
    assert_not_include(html, "Chun-Yuan Hsu | Chun-Yuan Hsu")
  end
end
