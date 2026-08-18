source "https://rubygems.org"

ruby File.read(File.expand_path(".ruby-version", __dir__)).strip

gem "jekyll", "4.3.4"
gem "jekyll-sass-converter", "3.1.0"
gem "sass-embedded", "~> 1.89"
gem "csv", "3.3.6"
gem "base64", "0.2.0"

group :jekyll_plugins do
  gem "jekyll-feed", "0.17.0"
  gem "jekyll-seo-tag", "2.8.0"
  gem "jekyll-sitemap", "1.4.0"
end

group :test do
  gem "nokogiri", "~> 1.18"
  gem "test-unit", "~> 3.6"
end
