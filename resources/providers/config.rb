# Cookbook:: rb-alarm-engine
#
# Provider:: config
#
include RbAlarmEngine::Helpers

action :add do
  begin
    user = new_resource.user
    group = new_resource.group
    rb_alarm_engine_config_dir = new_resource.rb_alarm_engine_config_dir
    redis_password = '{{ with secret "secret/data/redis" }}{{ .Data.data.pass }}{{ end }}'
    # same HMAC as rb_internal_api_token
    internal_api_token = OpenBao.expr('webui_secret', %(hmacSHA256Hex "#{RbAlarmEngine::Helpers::INTERNAL_API_TOKEN_CONTEXT}" .Data.data.secret))

    execute 'create_group' do
      command "/usr/sbin/groupadd -r #{group}"
      ignore_failure true
      not_if "getent group #{group}"
    end

    user user do
      gid group
      shell '/sbin/nologin'
      system true
      action :create
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

    openbao_secret_file 'redborder-alarm-engine-config' do
      source 'config.yml.erb'
      cookbook 'rb-alarm-engine'
      variables(
        redis_password: redis_password,
        internal_api_token: internal_api_token
      )
      destination '/run/rb-secrets/redborder-alarm-engine/config.yml'
      owner 'root'
      group group
      mode '0640'
      unit 'redborder-alarm-engine'
    end

    link "#{rb_alarm_engine_config_dir}/config.yml" do
      to '/run/rb-secrets/redborder-alarm-engine/config.yml'
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
