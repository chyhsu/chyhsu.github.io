# frozen_string_literal: true

require "digest"
require "nokogiri"
require "pathname"
require "test/unit"
require "yaml"

ROOT = Pathname(__dir__).parent.expand_path
SITE_DIR = ROOT.join("_site")

module PortfolioTestSupport
  def yaml_file(relative_path)
    YAML.safe_load_file(ROOT.join(relative_path), permitted_classes: [], aliases: false)
  end

  def portfolio_file(name)
    yaml_file("_data/portfolio/#{name}.yml")
  end

  def rendered(path)
    SITE_DIR.join(path).read
  end

  def document(path)
    Nokogiri::HTML5(rendered(path))
  end

  def assert_built_site!
    assert_path_exist(SITE_DIR.join("index.html"), "Run ./script/build before ./script/test")
  end

  # Compatibility for the existing tests until each suite is replaced below.
  def build_site!
    assert_built_site!
  end

  def portfolio_data
    @portfolio_data ||= {
      "identity" => portfolio_file("profile").fetch("identity"),
      "contact" => portfolio_file("profile").fetch("contact"),
      "experience" => portfolio_file("experience"),
      "featured_projects" => portfolio_file("projects").fetch("featured"),
      "project_archive" => portfolio_file("projects").fetch("archive"),
      "skill_groups" => portfolio_file("skills"),
      "education" => portfolio_file("education")
    }
  end
end
