Rails.application.routes.draw do
  root 'bulbs#index'

  put '/bulb', to: 'bulbs#update', defaults: { format: 'json' }
  get '/bulb', to: 'bulbs#show', defaults: { format: 'json' }

  get '/changes', to: 'changelog#recent', defaults: { format: 'json' }
  get '/pending', to: 'changelog#pending', defaults: { format: 'json' }

  # set ourselves up with some admin controls to get the server to the right
  # state
  constraints format: :json do
      get '/admin/queue_length', to: 'admin#queue_length'
      get '/admin/clear_queue', to: 'admin#clear_queue'

      get '/admin/toggle_sharding', to: 'admin#toggle_sharding'
      get '/admin/set_sharding', to: 'admin#set_sharding'
      get '/admin/get_sharding', to: 'admin#get_sharding'

      get '/admin/toggle_return_ids', to: 'admin#toggle_return_ids'
      get '/admin/set_return_ids', to: 'admin#set_return_ids'
      get '/admin/get_return_ids', to: 'admin#get_return_ids'

      get '/admin/toggle_enable_bulb', to: 'admin#toggle_enable_bulb'
      get '/admin/set_enable_bulb', to: 'admin#set_enable_bulb'
      get '/admin/get_enable_bulb', to: 'admin#get_enable_bulb'

      get '/admin/toggle_queue_changes', to: 'admin#toggle_queue_changes'
      get '/admin/set_queue_changes', to: 'admin#set_queue_changes'
      get '/admin/get_queue_changes', to: 'admin#get_queue_changes'

      get '/admin/set_queue_delay/:delay', to: 'admin#set_queue_delay', constraints: { delay: /[0-9.]+/ }
      get '/admin/get_queue_delay', to: 'admin#get_queue_delay'
  end
end

