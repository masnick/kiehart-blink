require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'] || :development )

Dotenv.load unless ENV['RACK_ENV'] == "production"

set :force_ssl, (ENV['RACK_ENV'] == 'production')

set :protection, :except => :frame_options

before do
  if settings.force_ssl && !request.secure?
    halt 400, "Please use SSL."
  end
end

get '/' do
  request = Unirest.get(ENV['URL'])
  parsed = Nokogiri::HTML(request.body)

  # Get rid of image
  parsed.css(".icon-container").remove

  # Fix background color and border on widget
  parsed.css(".widget-container")[0].set_attribute("style", "background-color: transparent; border: none;")

  # Fix position of location in widget
  parsed.css(".location")[0].set_attribute("style", "margin-left: 0; padding-left: 0; font-family: 'Gentium Basic',serif;")

  # Make Photoshelter font available in widget
  font_url = "https://fonts.googleapis.com/css?family=Gentium+Basic:400,700|&subset=latin,latin-ext"
  span = Nokogiri::XML::Node.new "link", parsed
  span.set_attribute("rel", "stylesheet")
  span.set_attribute("type", 'text/css')
  span.set_attribute("href", font_url)
  parsed.css("head")[0].add_child(span)

  return parsed.to_s
end



