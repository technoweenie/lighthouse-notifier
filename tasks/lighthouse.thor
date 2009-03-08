$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
require 'lighthouse_notifier'
LighthouseNotifier::Config.connect(File.dirname(__FILE__) + '/../config.tct', :mode => 'wc')

class LhNotifier < Thor
  desc "list", "List all project keys"
  def list
    LighthouseNotifier::Config.each do |key|
      show key
    end
  end

  desc "set PROJECT_ID", "Add campfire info for a project."
  method_options :domain => :required, :login => :required, :password => :required, :room => :optional, :ssl => true
  def set(project_id)
    LighthouseNotifier::Config[project_id] = options
    show project_id
  end

  desc "update PROJECT_ID", "Replace campfire info for a project."
  method_options :domain => :optional, :login => :optional, :password => :optional, :room => :optional, :ssl => true
  def update(project_id)
    LighthouseNotifier::Config[project_id] = LighthouseNotifier::Config[project_id].merge(options)
    show project_id
  end

  desc "clear PROJECT_ID", "clear info for a project."
  def clear(project_id)
    LighthouseNotifier::Config[project_id] = {}
    show project_id
  end

  desc "show PROJECT_ID", "show options for project."
  def show(project_id)
    puts "Project #{project_id}: #{LighthouseNotifier::Config[project_id].inspect}"
  end
end