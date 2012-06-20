# encoding: utf-8

require 'bundler/setup'
require 'capybara'
require 'capybara/poltergeist'
require 'set'


class Topp
  def setup!
    Capybara.run_server = false
    Capybara.register_driver(:poltergeist) do |app|
      Capybara::Poltergeist::Driver.new(app, :debug => false)
    end
  end

  def top_pages(seed_url, options={})
    setup!

    logger_io = options[:logger_io] || $stderr
    visit_depth = options[:visit_depth] || 10
    num_pages = options[:num_pages] || 10

    seen_urls = Hash.new(0)
    visited_urls = Set.new
    error_urls = Set.new
    visit_queue = []

    browser = Capybara::Session.new(:poltergeist)

    visit_queue = [seed_url]

    last_visit_at = Time.now

    while visited_urls.size < visit_depth
      begin
        sleep(1.0) if Time.now - last_visit_at < 1.0
        url = visit_queue.sample
        logger_io.puts("Visiting #{url}")
        browser.visit(url)
        canonical_url = browser.evaluate_script('window.location.href')
        logger_io.puts("Got to #{canonical_url}")
        canonical_prefix ||= browser.evaluate_script('window.location.protocol + "//" + window.location.host')
        if canonical_url.start_with?(canonical_prefix)
          links = browser.evaluate_script(ALL_LINKS_JS)
          links.each do |url|
            if url.start_with?(canonical_prefix)
              url = url.split('#').first
              seen_urls[url] += 1
            end
          end
          top_links = seen_urls.sort_by(&:last).reverse.take(10).map(&:first)
          visit_queue.concat(top_links)
          visit_queue.reject! { |url| visited_urls.include?(url) || error_urls.include?(url) }
          visited_urls << url
          visited_urls << canonical_url
          logger_io.puts("#{visited_urls.size} URLs visited")
          logger_io.puts(visited_urls.to_a.join("\n"))
          logger_io.puts('---')
        end
      rescue Capybara::Poltergeist::TimeoutError, Capybara::Poltergeist::JavascriptError
        logger_io.puts("Error, trying next")
        error_urls << canonical_url
      end
    end

    seen_urls.sort_by(&:last).reverse.take(num_pages).map(&:first)
  end

  private

  ALL_LINKS_JS = <<-END
  (function () {
    var urls = []
    var anchors = document.getElementsByTagName("a")
    for (var i = 0; i < anchors.length; i++) {
      urls.push(anchors[i].href)
    }
    return urls
  })()
  END
end