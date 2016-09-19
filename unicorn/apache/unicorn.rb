app_dir = "/var/www/sims"
 
working_directory app_dir
 
pid "#{app_dir}/tmp/unicorn.pid"
 
stderr_path "#{app_dir}/log/unicorn.stderr.log"
stdout_path "#{app_dir}/log/unicorn.stdout.log"
 
worker_processes 2
preload_app true
listen 300, :backlog => 64
timeout 800
#check_client_connection false

before_fork do |_server, _worker|
  Signal.trap 'INT' do
    puts 'intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end
end
    
after_fork do |_server, _worker|
   Signal.trap 'INT' do
        puts 'Waiting for SIGQUIT from Unicorn master.'
   end
    
   if defined?(ActiveRecord::Base)
        ActiveRecord::Base.establish_connection
   end
 end