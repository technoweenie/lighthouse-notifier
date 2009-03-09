$LOAD_PATH << File.dirname(__FILE__) + "/../"
require 'sinatra'
require 'json'

configure do
  require 'lighthouse_notifier'
  LighthouseNotifier::Config.connect(File.dirname(__FILE__) + '/../../config.tct', :mode => 'r')
end

get '/' do
  "Send your Lighthouse callbacks requests to #{env['rack.url_scheme']}://#{env['HTTP_HOST']}/update."
end

# todo, send some valid json data like user name, project name, and url!
post '/update' do
  target  = JSON.parse env["rack.input"].read
  message = \
    case target.keys.first
      when 'version'
        data       = target['version']
        project_id = data['project_id']
        %(#{data['user_name']} updated the ticket '#{data['title']}' (#{data['state']}): #{data['url']})
      when 'ticket'
        data       = target['ticket']
        project_id = data['project_id']
        %(#{data['user_name']} created the ticket '#{data['title']}' (#{data['state']}): #{data['url']})
      when 'message'
        data       = target['message']
        project_id = data['project_id']
        if data['parent_id'].blank? || data['parent_id'] == data['id']
          %(#{data['user_name']} created a message '#{data['title']}': #{data['url']})
        else
          %(#{data['user_name']} commented on '#{data['title']}': #{data['url']})
        end
      when 'milestone'
        data       = target['milestone']
        project_id = data['project_id']
        %(#{data['user_name']} updated a milestone '#{data['title']}': #{data['url']})
    end

  if project_id
    options = LighthouseNotifier::Config[project_id]
    LighthouseNotifier::Campfire.ping(options, data, "[#{options['name']}]" << message)
  end
end