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
    ActiveRecord::Base.descendants.sort_by{|d| d.to_s }.each do |ar_class|
      next unless ar_class.scrubbable?

      @logger.info "Scrubbing #{ar_class}".green

      ar_class.find_in_batches do |batch|
        batch.each do |obj|
          obj.scrub!
        end
      end

    end
    @logger.info "Scrub Complete!".white
  end
end

desc "Links to scrub:all"
task :scrub => ['scrub:all']
