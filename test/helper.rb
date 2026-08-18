# frozen_string_literal: true

require "open3"
require "pathname"
require "test/unit"
require "yaml"

ROOT = Pathname(__dir__).parent.expand_path
SITE_DIR = ROOT.join("_site")

module PortfolioTestSupport
  def portfolio_data
    @portfolio_data ||= YAML.safe_load_file(
      ROOT.join("_data/portfolio.yml"),
      permitted_classes: [],
      aliases: false
    )
  end

  def build_site!
    return if self.class.class_variable_defined?(:@@site_built)

    stdout, stderr, status = Open3.capture3(
      "bundle", "exec", "jekyll", "build", chdir: ROOT.to_s
    )
    assert(status.success?, "Jekyll build failed:\n#{stdout}\n#{stderr}")
    self.class.class_variable_set(:@@site_built, true)
  end

  def rendered(path)
    SITE_DIR.join(path).read
  end
end
