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
        next if href.empty? || href.start_with?("#", "mailto:", "tel:", "http://", "https://")

        path = URI::DEFAULT_PARSER.unescape(href.split(/[?#]/, 2).first)
        candidate = if path.start_with?("/")
                      SITE_DIR.join(path.delete_prefix("/"))
                    else
                      Pathname(html_path).dirname.join(path)
                    end
        candidate = candidate.join("index.html") if path.end_with?("/")
        candidate = Pathname("#{candidate}.html") if candidate.extname.empty? && !candidate.directory?
        failures << "#{html_path}: #{href}" unless candidate.exist?
      end
    end
    assert_empty(failures, "Broken internal links:\n#{failures.join("\n")}")
  end
end
