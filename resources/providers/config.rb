# Cookbook:: rb-alarm-engine
#
# Provider:: config
#
action :add do
  begin
    user = new_resource.user
    group = new_resource.group
    rb_alarm_engine_config_dir = new_resource.rb_alarm_engine_config_dir
    redis_password = new_resource.redis_password

    has_valid_password = !redis_password.nil? && !redis_password.to_s.strip.empty?

    unless has_valid_password
      Chef::Log.warn('Skipping redborder-alarm-engine deployment/start: redis_password is missing or blank.')
      return
    end

    execute 'create_group' do
      command "/usr/sbin/groupadd -r #{group}"
      ignore_failure true
      not_if "getent group #{group}"
    end
  
    execute 'create_user' do
      command "/usr/sbin/useradd -r -g #{group} #{user}"
      ignore_failure true
      not_if "getent passwd #{user}"
    end
  
    dnf_package 'redborder-alarm-engine' do
      action :upgrade
    end
  
    directory rb_alarm_engine_config_dir do
      owner user
      group group
      mode '0755'
      recursive true
    end

    service 'redborder-alarm-engine' do
      supports status: true, start: true, stop: true, restart: true
      action :nothing
    end

    template "#{rb_alarm_engine_config_dir}/config.yml" do
      source 'config.yml.erb'
      cookbook 'rb-alarm-engine'
      owner user
      group group
      mode '0640'
      variables(
        redis_password: redis_password
      )
      notifies :restart, 'service[redborder-alarm-engine]', :delayed
    end

    service 'start_redborder_alarm_engine' do
      service_name 'redborder-alarm-engine'
      action [:enable, :start]
    end

    Chef::Log.info('cookbook redborder-alarm-engine has been configured, started and enabled.')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    service 'redborder-alarm-engine' do
      service_name 'redborder-alarm-engine'
      supports status: true, restart: true, start: true, enable: true, disable: true
      action [:disable, :stop]
    end
    Chef::Log.info('cookbook redborder alarm engine has been stopped and disabled.')
  rescue => e
    Chef::Log.error(e.message)
  end
end