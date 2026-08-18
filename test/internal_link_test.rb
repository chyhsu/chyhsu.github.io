# frozen_string_literal: true

require "cgi"
require "pathname"
require "uri"
require_relative "helper"

class InternalLinkTest < Test::Unit::TestCase
  include PortfolioTestSupport

  def setup
    build_site!
  end

  def test_every_generated_internal_href_resolves
    failures = []
    Dir[SITE_DIR.join("**/*.html")].sort.each do |html_path|
      html = File.read(html_path)
      html.scan(/href=["']([^"']+)["']/).flatten.each do |raw_href|
        href = CGI.unescapeHTML(raw_href)
        next if href.empty? || href.start_with?("#") || external_href?(href)

        candidate = resolve_internal_href(href, html_path, site_baseurl)
        failures << "#{html_path}: #{href}" unless candidate&.exist?
      end
    end
    assert_empty(failures, "Broken internal links:\n#{failures.join("\n")}")
  end

  def test_internal_href_resolver_handles_baseurl_externals_and_containment
    assert(self.respond_to?(:resolve_internal_href, true))

    html_path = SITE_DIR.join("nested/page.html")
    assert_equal(
      SITE_DIR.join("about/index.html"),
      resolve_internal_href("/portfolio/about/", html_path, "/portfolio")
    )
    assert_equal(
      SITE_DIR.join("about/index.html"),
      resolve_internal_href("/portfolio/about/", html_path, "portfolio")
    )
    assert_nil(resolve_internal_href("/about/", html_path, "/portfolio"))
    assert_nil(resolve_internal_href("//cdn.example.com/app.css", html_path, "/portfolio"))
    assert_nil(resolve_internal_href("javascript:void(0)", html_path, "/portfolio"))
    assert_nil(resolve_internal_href("../../../Gemfile", html_path, "/portfolio"))
  end

  private

  def external_href?(href)
    uri = URI.parse(href)
    uri.scheme || uri.host
  rescue URI::InvalidURIError
    false
  end

  def resolve_internal_href(href, html_path, baseurl)
    return if external_href?(href)

    path = URI::DEFAULT_PARSER.unescape(href.split(/[?#]/, 2).first)
    baseurl = normalized_baseurl(baseurl)
    return if path.start_with?("/") && !baseurl.empty? && path != baseurl && !path.start_with?("#{baseurl}/")

    candidate = if path.start_with?("/")
                  SITE_DIR.join(path.delete_prefix(baseurl).delete_prefix("/"))
                else
                  Pathname(html_path).dirname.join(path)
                end
    candidate = candidate.expand_path
    return unless contained_in_site?(candidate)

    candidate = candidate.join("index.html") if path.end_with?("/")
    candidate = Pathname("#{candidate}.html") if candidate.extname.empty? && !candidate.directory?
    candidate
  end

  def normalized_baseurl(baseurl)
    baseurl = baseurl.to_s.delete_prefix("/").delete_suffix("/")
    return "" if baseurl.empty?

    "/#{baseurl}"
  end

  def contained_in_site?(path)
    site_dir = SITE_DIR.expand_path
    path == site_dir || path.to_s.start_with?("#{site_dir}/")
  end

  def site_baseurl
    @site_baseurl ||= YAML.safe_load_file(ROOT.join("_config.yml"), permitted_classes: [], aliases: false).fetch("baseurl", "")
  end
end
