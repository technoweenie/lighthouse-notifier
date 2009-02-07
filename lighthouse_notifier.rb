require 'sinatra'
require 'json'
require 'tinder'

# todo, send some valid json data like user name, project name, and url!
post '/update' do
  target  = JSON.parse env["rack.input"].read
  message = \
    case target.keys.first
      when 'version'
        data = target['version']
        %(#{data['user_name']} updated the ticket '#{data['title']}' (#{data['state']}): #{data['url']})
      when 'ticket'
        data = target['ticket']
        %(#{data['user_name']} created the ticket '#{data['title']}' (#{data['state']}): #{data['url']})
      when 'message'
        data = target['message']
        if data['parent_id'].blank? || data['parent_id'] == data['id']
          %(#{data['user_name']} created a message '#{data['title']}': #{data['url']})
        else
          %(#{data['user_name']} commented on '#{data['title']}': #{data['url']})
        end
      when 'milestone'
        data = target['milestone']
        %(#{data['user_name']} updated a milestone '#{data['title']}': #{data['url']})
    end

  LighthouseNotifier::Campfire.speak message
end

# todo, specify ssl and room!
module LighthouseNotifier
  module Campfire
    class << self
      attr_accessor :domain, :login, :password, :room
    end

    def self.speak(msg)
      cf = Tinder::Campfire.new domain, :ssl => true
      cf.login login, password
      room   = LighthouseNotifier::Campfire.room && cf.rooms.detect { |r| r.name == LighthouseNotifier::Campfire.room }
      room ||= cf.rooms[0]
      room.speak msg
      room.leave
      nil
    end
  end
end

LighthouseNotifier::Campfire.domain   ||= ARGV.shift
LighthouseNotifier::Campfire.login    ||= ARGV.shift
LighthouseNotifier::Campfire.password ||= ARGV.shift
LighthouseNotifier::Campfire.room     ||= ARGV.shift

if LighthouseNotifier::Campfire.domain.nil?
  puts "You need to specify the campfire domain, login, and password:"
  puts
  puts "  ruby -rubygems lighthouse_notifier.rb spacemonkey tylerdurden@project-mayhem.com khakis [roomname]"
  exit
end