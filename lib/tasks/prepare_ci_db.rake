require 'active_record'

DATABASE_NUM = if ENV['CI_DATABASE_NUM']
                 ENV['CI_DATABASE_NUM']
               elsif File.exists?('/proc/cpuinfo')
                 File.read('/proc/cpuinfo').split("\n").grep(/processor/).size
               elsif RUBY_PLATFORM =~ /darwin/
                 `/usr/sbin/sysctl -n hw.activecpu`.to_i
               else
                 2
               end

namespace :ci do
  task :test_environment => :environment do
    ENV['RAILS_ENV'] = Rails.env = ActiveRecord::Tasks::DatabaseTasks.env = 'test'
  end

  namespace :db do
    desc "Create CI_DATABASE_NUM databases for ci. Default CI_DATABASE_NUM=2"
    task :create => [:test_environment, 'db:load_config'] do
      begin
        orig_database = ActiveRecord::Base.configurations['test']['database'].dup
        DATABASE_NUM.to_i.times do |num|
          ActiveRecord::Base.configurations['test']['database'] = num.zero? ? orig_database : orig_database + num.to_s
          Rake::Task['db:create'].invoke
          Rake::Task['db:create'].reenable
        end
      ensure
        ActiveRecord::Base.configurations['test']['database'] = orig_database
      end
    end

    desc "Drop CI_DATABASE_NUM databases for ci. Default CI_DATABASE_NUM=2"
    task :drop => [:test_environment, 'db:load_config'] do
      begin
        orig_database = ActiveRecord::Base.configurations['test']['database'].dup
        DATABASE_NUM.to_i.times do |num|
          ActiveRecord::Base.configurations['test']['database'] = num.zero? ? orig_database : orig_database + num.to_s
          Rake::Task['db:drop'].invoke
          Rake::Task['db:drop'].reenable
        end
      ensure
        ActiveRecord::Base.configurations['test']['database'] = orig_database
      end
    end

    desc "Migrate CI_DATABASE_NUM databases for ci. Default CI_DATABASE_NUM=2"
    task :migrate => [:test_environment, 'db:load_config'] do
      begin
        orig_database = ActiveRecord::Base.configurations['test']['database'].dup
        DATABASE_NUM.to_i.times do |num|
          ActiveRecord::Base.configurations['test']['database'] = num.zero? ? orig_database : orig_database + num.to_s
          ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[Rails.env])
          Rake::Task['db:migrate'].invoke
          Rake::Task['db:migrate'].reenable
        end
      ensure
        ActiveRecord::Base.configurations['test']['database'] = orig_database
      end
    end

    desc "Setup CI_DATABASE_NUM databases for ci. Default CI_DATABASE_NUM=2"
    task :setup => [:create, :migrate]

    desc "Reset CI_DATABASE_NUM databases for ci. Default CI_DATABASE_NUM=2"
    task :reset => [:drop, :create, :migrate]
  end
end
