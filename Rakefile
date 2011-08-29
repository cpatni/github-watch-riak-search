namespace :riak do
  desc 'status'
  task :status do
    system 'riak-admin status'
  end

  desc 'rekon web ui'
  task :rekon do
    #system 'curl -s rekon.basho.com | sh'
    system 'rekon/install.sh'
  end

end