# frozen_string_literal: true

require_relative "helper"

class SecondaryPagesTest < Test::Unit::TestCase
  include PortfolioTestSupport

  def setup
    assert_built_site!
  end

  def test_about_preserves_personal_history_and_shared_facts
    doc = document("about/index.html")
    text = doc.text
    %w[Tainan TSMC QNAP baseball gym darts].each { |fact| assert_include(text, fact) }
    assert_include(text, "civil engineering")
    assert_include(text, "University of Michigan")
    assert_include(text, "US Taiwan Watch")
    assert_include(text, "Linear Algebra")
    assert_include(text, "Linux ricing")
    assert_equal(7, doc.css(".records-list a").length)
    image = doc.at_css("img.about-photo")
    assert_equal("/assets/images/20200711_190244-web.jpg", image["src"])
    assert_equal("lazy", image["loading"])
    assert_equal("async", image["decoding"])
  end

  def test_blog_groups_all_historical_posts_by_year
    doc = document("blog/index.html")
    assert_equal(["2026", "2025"], doc.css(".blog-year > h2").map { |node| node.text.strip })
    assert_equal(10, doc.css(".blog-year .post-row").length)
    assert_include(doc.text, "Machine Learning Project")
    assert_include(doc.text, "Welcome to My Blog!")
  end

  def test_every_post_renders_one_h1_and_a_timestamped_article
    post_paths = Dir[SITE_DIR.join("20??/**/*.html")].sort
    assert_equal(10, post_paths.length)
    post_paths.each do |path|
      doc = Nokogiri::HTML5(File.read(path))
      assert_equal(1, doc.css("h1").length, path)
      assert_equal(1, doc.css("article.post-article").length, path)
      assert_equal(1, doc.css("article.post-article time[datetime]").length, path)
    end
  end

  def test_llm_profile_renders_all_shared_factual_sections
    doc = document("llm/index.html")
    text = doc.text
    assert_include(text, "chyhsu@umich.edu")
    assert_include(text, "Digital Workflow Development Department Intern")
    assert_include(text, "May 2026 – Aug 2026")
    assert_include(text, "My contribution")
    assert_include(text, "Project result")
    assert_include(text, "0.873 diagnostic accuracy")
    assert_include(text, "0.966 R²")
    assert_include(text, "NTHU thesis and research project")
    assert_include(text, "Claude Agent SDK")
    assert_include(text, "US Taiwan Watch")
    assert_include(text, "QNAP Internship Certificate")
    profile = portfolio_file("profile")
    missing_claims = []
    identity_possessive = "#{profile.fetch("identity").fetch("name")}’s path"
    missing_claims << identity_possessive unless text.include?(identity_possessive)
    portfolio_file("experience").each do |role|
      summary = role.fetch("summary")
      missing_claims << "#{role.fetch("id")} summary" unless text.include?(summary)
    end
    portfolio_file("projects").fetch("archive").each do |project|
      project_row = doc.css(".page-content li").find { |node| node.text.include?(project.fetch("title")) }
      technologies = project.fetch("technologies").join(", ")
      missing_claims << "#{project.fetch("id")} technologies" unless project_row&.text&.include?(technologies)
    end
    assert_empty(missing_claims, "LLM profile omissions: #{missing_claims.join(", ")}")
  end
end
