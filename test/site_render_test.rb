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

  def test_homepage_has_one_h1_and_approved_section_order
    doc = document("index.html")
    assert_equal(["Chun-Yuan Hsu"], doc.css("h1").map { |node| node.text.strip })
    ids = %w[intro experience selected-work more-work profile writing contact]
    source = rendered("index.html")
    positions = ids.map do |id|
      position = source.index(%(id="#{id}"))
      assert_not_nil(position, "Missing homepage section ##{id}")
      position
    end
    assert_equal(positions.sort, positions)
  end

  def test_homepage_cta_role_and_project_order
    doc = document("index.html")
    actions = doc.css(".hero__actions a").map { |link| link.text.strip }
    assert_equal(["About Me", "Download CV"], actions)
    assert_equal(%w[tsmc qnap], doc.css(".experience-row").map { |row| row["data-role-id"] })
    doc.css(".experience-row").each do |row|
      assert_operator(row.css(".experience-row__primary li").length, :<=, 2)
    end
    assert_equal(
      %w[lilac brain_age_ad vizthinker],
      doc.css("#selected-work .evidence-row").map { |row| row["data-project-id"] }
    )
  end

  def test_homepage_is_compact_without_archive_card_wall
    doc = document("index.html")
    assert_equal(8, doc.css("#more-work .more-work__link").length)
    assert_equal(2, doc.css("#writing .post-row").length)
    assert_empty(doc.css(".experience-card, .featured-card, .archive-card, .post-card"))
    assert_equal("mailto:chyhsu@umich.edu", doc.at_css("#contact a")["href"])
  end

  def test_homepage_exposes_attribution_and_secondary_experience
    doc = document("index.html")
    assert_operator(doc.css("#selected-work dt").count { |node| node.text.strip == "My contribution" }, :==, 3)
    assert_operator(doc.css("#selected-work dt").count { |node| node.text.strip == "Project result" }, :==, 3)
    assert_include(doc.at_css(".experience-row[data-role-id='qnap'] details").text, "MCP-based Jira search server")
    assert_include(doc.at_css(".experience-row[data-role-id='qnap'] details").text, "Konnyaku")
  end
end
