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
    failures = broken_internal_hrefs
    assert_empty(failures, "Broken internal links:\n#{failures.join("\n")}")
  end

  def test_every_generated_internal_image_source_resolves
    failures = broken_internal_images
    assert_empty(failures, "Broken internal images:\n#{failures.join("\n")}")
  end

  def test_missing_internal_image_is_reported
    html_path = SITE_DIR.join("missing-image-regression.html")
    missing_image = "/portfolio/assets/images/does-not-exist.jpg"
    File.write(html_path, %(<img src="#{missing_image}" alt="Regression fixture">))

    assert_include(broken_internal_images, "#{html_path}: #{missing_image}")
  ensure
    html_path&.delete if html_path&.exist?
  end

  def test_missing_internal_srcset_candidate_is_reported
    html_path = SITE_DIR.join("missing-srcset-regression.html")
    missing_image = "/portfolio/assets/images/does-not-exist-2x.jpg"
    File.write(
      html_path,
      %(<img src="/portfolio/assets/images/IMG_5239.png" srcset="/portfolio/assets/images/IMG_5239.png 1x, #{missing_image} 2x" alt="Regression fixture">)
    )

    assert_include(broken_internal_images, "#{html_path}: #{missing_image}")
  ensure
    html_path&.delete if html_path&.exist?
  end

  def test_missing_internal_fragment_is_reported
    html_path = SITE_DIR.join("missing-fragment-regression.html")
    missing_fragment = "#does-not-exist"
    File.write(html_path, %(<main id="present"></main><a href="#{missing_fragment}">Regression fixture</a>))

    assert_include(broken_internal_hrefs, "#{html_path}: #{missing_fragment}")
  ensure
    html_path&.delete if html_path&.exist?
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

  def test_internal_href_resolver_handles_same_page_fragments
    html_path = SITE_DIR.join("about/index.html")

    assert_equal(html_path, resolve_internal_href("#main-content", html_path, site_baseurl))
    assert(fragment_target_exists?(html_path, "main-content"))
    assert_not_predicate(fragment_target_exists?(html_path, "does-not-exist"), :itself)
  end

  def test_internal_image_resolver_handles_baseurl_externals_and_containment
    html_path = SITE_DIR.join("nested/page.html")

    assert_equal(
      SITE_DIR.join("assets/images/IMG_5239.png"),
      resolve_internal_image("/portfolio/assets/images/IMG_5239.png?width=1600#preview", html_path, "/portfolio")
    )
    assert_nil(resolve_internal_image("/assets/images/IMG_5239.png", html_path, "/portfolio"))
    assert_nil(resolve_internal_image("https://cdn.example.com/image.jpg", html_path, "/portfolio"))
    assert_nil(resolve_internal_image("data:image/svg+xml;base64,AAAA", html_path, "/portfolio"))
    assert_nil(resolve_internal_image("../../../Gemfile", html_path, "/portfolio"))
  end

  private

  def broken_internal_hrefs
    failures = []
    Dir[SITE_DIR.join("**/*.html")].sort.each do |html_path|
      html = File.read(html_path)
      html.scan(/href=["']([^"']+)["']/).flatten.each do |raw_href|
        href = CGI.unescapeHTML(raw_href)
        next if href.empty? || external_href?(href)

        candidate = resolve_internal_href(href, html_path, site_baseurl)
        unless candidate&.exist?
          failures << "#{html_path}: #{href}"
          next
        end

        fragment = href.split("#", 2)[1]
        if fragment && !fragment.empty? && !fragment_target_exists?(candidate, fragment)
          failures << "#{html_path}: #{href}"
        end
      end
    end
    failures
  end

  def broken_internal_images
    failures = []
    Dir[SITE_DIR.join("**/*.html")].sort.each do |html_path|
      internal_image_sources(File.read(html_path)).each do |raw_source|
        source = CGI.unescapeHTML(raw_source)
        next if source.empty? || external_href?(source)

        candidate = resolve_internal_image(source, html_path, site_baseurl)
        failures << "#{html_path}: #{source}" unless candidate&.exist?
      end
    end
    failures
  end

  def internal_image_sources(html)
    html.scan(/<img\b[^>]*>/i).flat_map do |tag|
      sources = tag.scan(/(?:\A|\s)src\s*=\s*["']([^"']+)["']/i).flatten
      tag.scan(/(?:\A|\s)srcset\s*=\s*["']([^"']+)["']/i).flatten.each do |srcset|
        sources.concat(srcset_candidates(srcset))
      end
      sources
    end
  end

  def srcset_candidates(srcset)
    return [srcset] if srcset.lstrip.start_with?("data:")

    srcset.split(",").filter_map do |candidate|
      candidate.strip.split(/\s+/, 2).first
    end
  end

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

    candidate = if path.empty?
                  Pathname(html_path)
                elsif path.start_with?("/")
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

  def resolve_internal_image(source, html_path, baseurl)
    resolve_internal_href(source, html_path, baseurl)
  end

  def fragment_target_exists?(html_path, fragment)
    decoded_fragment = URI::DEFAULT_PARSER.unescape(fragment)
    File.read(html_path).match?(/\b(?:id|name)=["']#{Regexp.escape(decoded_fragment)}["']/)
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
