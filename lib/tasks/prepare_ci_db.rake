require 'active_record'

DATABASE_NUM = ENV['CI_DATABASE_NUM'] || 2

namespace :ci do
  task :test_environment => :environment do
    ENV['RAILS_ENV'] = Rails.env = ActiveRecord::Tasks::DatabaseTasks.env = 'test'
  end

  namespace :db do
    desc "Create databases for ci"
    task :create => [:test_environment, 'db:load_config'] do
      begin
        orig_database = ActiveRecord::Base.configurations['test']['database'].dup
        DATABASE_NUM.to_i.times do |num|
          ActiveRecord::Base.configurations['test']['database'] = orig_database + (num+1).to_s
          Rake::Task['db:create'].invoke
          Rake::Task['db:create'].reenable
        end
      ensure
        ActiveRecord::Base.configurations['test']['database'] = orig_database
      end
    end

    desc "Drop databases for ci"
    task :drop => [:test_environment, 'db:load_config'] do
      begin
        orig_database = ActiveRecord::Base.configurations['test']['database'].dup
        DATABASE_NUM.to_i.times do |num|
          ActiveRecord::Base.configurations['test']['database'] = orig_database + (num+1).to_s
          Rake::Task['db:drop'].invoke
          Rake::Task['db:drop'].reenable
        end
      ensure
        ActiveRecord::Base.configurations['test']['database'] = orig_database
      end
    end

    desc "Migrate databases for ci"
    task :migrate => [:test_environment, 'db:load_config'] do
      begin
        orig_database = ActiveRecord::Base.configurations['test']['database'].dup
        DATABASE_NUM.to_i.times do |num|
          ActiveRecord::Base.configurations['test']['database'] = orig_database + (num+1).to_s
          ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[Rails.env])
          Rake::Task['db:migrate'].invoke
          Rake::Task['db:migrate'].reenable
        end
      ensure
        ActiveRecord::Base.configurations['test']['database'] = orig_database
      end
    end

    desc "Setup databases for ci"
    task :setup => [:create, :migrate]

    desc "Reset databases for ci"
    task :reset => [:drop, :create, :migrate]
  end
end
