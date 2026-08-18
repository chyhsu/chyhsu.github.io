# frozen_string_literal: true

require_relative "helper"

class SecondaryPagesTest < Test::Unit::TestCase
  include PortfolioTestSupport

  def setup
    build_site!
  end

  def test_about_is_present_day_and_preserves_personal_history
    html = rendered("about/index.html")
    assert_include(html, "Tainan")
    assert_include(html, "civil engineering")
    assert_include(html, "University of Michigan")
    assert_include(html, "TSMC")
    assert_include(html, "US Taiwan Watch")
    assert_include(html, "Linear Algebra")
    assert_include(html, "Linux ricing")
    assert_not_include(html, "pack my bags")
    assert_not_include(html, "incoming MDS")
  end

  def test_blog_archive_has_semantic_articles
    html = rendered("blog/index.html")
    assert_include(html, '<div class="posts-container">')
    assert_operator(html.scan('<article class="post-card">').length, :>=, 10)
    assert_include(html, "Machine Learning Project")
  end

  def test_post_has_one_h1_and_a_dated_article
    post_path = Dir[SITE_DIR.join("2026/05/25/*Machine-Learning-Project.html")].first
    assert_not_nil(post_path, "Machine Learning Project output was not generated")
    html = File.read(post_path)
    assert_equal(1, html.scan(/<h1\b/).length)
    assert_match(/<article class="[^"]*\bpost-article\b[^"]*">/, html)
    assert_include(html, '<time datetime="2026-05-25')
  end
end
