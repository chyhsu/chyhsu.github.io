# frozen_string_literal: true

require_relative "helper"

class ReleaseToolingTest < Test::Unit::TestCase
  include PortfolioTestSupport

  def setup
    assert_built_site!
  end

  def test_browser_gate_covers_every_standalone_page_action
    browser_check = ROOT.join("script/release-browser-check.mjs").read
    assert_include(browser_check, '".skip-link"')
    assert_include(browser_check, '".records-list a"')
    assert_include(browser_check, '".llm-page .page-content a"')
    assert_match(/box\.width < 44 \|\| box\.height < 44/, browser_check)

    css = SITE_DIR.join("assets/main.css").read
    assert_match(/\.records-list a,.llm-page \.page-content a\{[^}]*min-height:2\.75rem;min-width:2\.75rem/, css)
    assert_equal(7, document("about/index.html").css(".records-list a").length)
    assert_not_nil(document("llm/index.html").at_css("body.llm-page"))
    assert_operator(document("llm/index.html").css(".page-content a").length, :>, 0)
  end

  def test_browser_gate_uses_an_explicit_context_for_axe
    browser_check = ROOT.join("script/release-browser-check.mjs").read

    context = browser_check.index("const context = await browser.newContext();")
    first_page = browser_check.index("context.newPage(")
    axe = browser_check.index("new AxeBuilder({ page })")
    last_page = browser_check.rindex("context.newPage(")
    context_close = browser_check.index("await context.close();")
    browser_close = browser_check.index("await browser.close();")

    [context, first_page, axe, last_page, context_close, browser_close].each { |position| assert_not_nil(position) }
    assert_not_include(browser_check, "browser.newPage(")
    assert_operator(context, :<, first_page)
    assert_operator(first_page, :<, axe)
    assert_operator(axe, :<=, last_page)
    assert_operator(last_page, :<, context_close)
    assert_operator(context_close, :<, browser_close)
  end

  def test_live_gate_checks_each_html_routes_canonical_and_stylesheet
    live_check = ROOT.join("script/verify-live").read
    assert_include(live_check, "html_routes=(")
    assert_include(live_check, 'for route in "${html_routes[@]}"')
    assert_include(live_check, 'expected_canonical="$base_url$route"')
    assert_include(live_check, 'href=\"$expected_canonical\"')
    assert_include(live_check, 'href="/assets/main.css"')
  end

  def test_external_gate_fails_closed_without_a_build_or_urls
    external_check = ROOT.join("script/check-external-links").read
    assert_include(external_check, '[[ ! -f _site/index.html ]]')
    assert_include(external_check, '[[ ! -s "$url_file" ]]')
  end
end
