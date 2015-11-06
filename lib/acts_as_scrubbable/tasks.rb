require 'rake'

namespace :scrub do

  desc "scrub all"
  task all: :environment do

    require 'highline/import'
    require 'term/ansicolor'
    require 'logger'

    @logger = Logger.new($stdout)

    answer = ask("Type SCRUB to continue.".red)
    unless answer == "SCRUB"
      puts "exiting ...".red
      exit
    end

    @logger.warn "Scrubbing classes".red

    Rails.application.eager_load! # make sure all the classes are loaded

    @total_scrubbed = 0

    ActiveRecord::Base.descendants.sort_by{|d| d.to_s }.each do |ar_class|
      next unless ar_class.scrubbable?

      scrubbed_count = 0
      ar_class.find_in_batches do |batch|
        batch.each do |obj|
          obj.scrub!
          scrubbed_count += 1
        end
      end
      @logger.info "Scrubbed #{scrubbed_count} #{ar_class} objects".green
      @total_scrubbed += scrubbed_count
    end

    ActsAsScrubbable.execute_after_hook

    @logger.info "#{@total_scrubbed} scrubbed objects".blue
    @logger.info "Scrub Complete!".white
  end
end

desc "Links to scrub:all"
task :scrub => ['scrub:all']
