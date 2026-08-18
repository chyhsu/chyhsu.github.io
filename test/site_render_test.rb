# frozen_string_literal: true

require_relative "helper"

class SiteRenderTest < Test::Unit::TestCase
  include PortfolioTestSupport

  def setup
    assert_built_site!
  end

  def test_every_page_uses_the_semantic_shell
    doc = document("about/index.html")
    assert_equal(1, doc.css("a.skip-link[href='#main-content']").length)
    assert_equal(1, doc.css("header.site-header").length)
    assert_equal(1, doc.css("nav[aria-label='Primary navigation']").length)
    assert_equal(1, doc.css("main#main-content").length)
    assert_equal(1, doc.css("footer.site-footer").length)
  end

  def test_navigation_exposes_the_approved_routes
    doc = document("about/index.html")
    links = doc.css(".site-nav a").to_h { |link| [link.text.strip, link["href"]] }
    assert_equal("/#experience", links.fetch("Experience"))
    assert_equal("/projects/", links.fetch("Projects"))
    assert_equal("/about/", links.fetch("About"))
    assert_equal("/blog/", links.fetch("Blog"))
    assert_equal("/assets/pdf/CV.pdf", links.fetch("CV"))
    assert_equal("page", doc.at_css(".site-nav a[href='/about/']")["aria-current"])
    assert_equal("/llm/", doc.at_css(".site-footer a[href='/llm/']")["href"])
  end

  def test_projects_page_has_ordered_featured_evidence
    doc = document("projects/index.html")
    rows = doc.css(".evidence-row")
    assert_equal(%w[lilac brain_age_ad vizthinker], rows.map { |row| row["data-project-id"] })
    rows.each do |row|
      labels = row.css("dt").map { |node| node.text.strip }
      assert_include(labels, "Context")
      assert_include(labels, "My contribution")
      assert_include(labels, "Project result")
    end
  end

  def test_projects_page_groups_every_archive_item_once
    doc = document("projects/index.html")
    assert_equal(
      ["Production / Developer Tools", "Systems / Coursework", "Research"],
      doc.css(".project-group > h2").map { |heading| heading.text.strip }
    )
    rows = doc.css(".project-index-row")
    assert_equal(8, rows.length)
    assert_equal(8, rows.map { |row| row["id"] }.uniq.length)
    assert_include(doc.at_css("#jira_issue_search").text, "QNAP internship work")
    assert_include(doc.at_css("#issue_search_mcp").text, "QNAP internship work")
    assert_include(doc.at_css("#quantum_event").text, "NTHU thesis and research project")
  end

  def test_shell_requires_no_site_javascript
    Dir[SITE_DIR.join("**/*.html")].each do |path|
      assert_empty(Nokogiri::HTML5(File.read(path)).css("script[src]"), path)
    end
  end
end
