# Cookbook:: :: rb-alarm-engine
#
# Resource:: config
#

unified_mode true
actions :add, :remove
default_action :add

attribute :user, kind_of: String, default: 'redborder-alarm-engine'
attribute :group, kind_of: String, default: 'redborder-alarm-engine'

attribute :rb_alarm_engine_config_dir, kind_of: String, default: '/etc/redborder-alarm-engine'

attribute :redis_password, kind_of: String
