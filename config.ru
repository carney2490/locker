require './app.rb'
use Rack::Static, :urls => ['/css', '/js'], :root => 'public'
run App