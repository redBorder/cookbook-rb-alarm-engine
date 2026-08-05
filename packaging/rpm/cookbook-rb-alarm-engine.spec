Name: cookbook-rb-alarm-engine
Version: %{__version}
Release: %{__release}%{?dist}
BuildArch: noarch
Summary: Cookbook to install and configure redborder alarm engine in the redborder platform

License: AGPL 3.0
URL: https://github.com/redBorder/cookbook-rb-alarm-engine
Source0: %{name}-%{version}.tar.gz

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/var/chef/cookbooks/rb-alarm-engine
cp -f -r  resources/* %{buildroot}/var/chef/cookbooks/rb-alarm-engine
chmod -R 0755 %{buildroot}/var/chef/cookbooks/rb-alarm-engine
install -D -m 0644 README.md %{buildroot}/var/chef/cookbooks/rb-alarm-engine/README.md

%pre
if [ -d /var/chef/cookbooks/rb-alarm-engine ]; then
    rm -rf /var/chef/cookbooks/rb-alarm-engine
fi

%post
case "$1" in
  1)
    # This is an initial install.
    :
  ;;
  2)
    # This is an upgrade.
    su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload rb-alarm-engine'
  ;;
esac

%postun
# Deletes directory when uninstall the package
if [ "$1" = 0 ] && [ -d /var/chef/cookbooks/rb-alarm-engine ]; then
  rm -rf /var/chef/cookbooks/rb-alarm-engine
fi

%files
%defattr(0644,root,root)
%attr(0755,root,root)
/var/chef/cookbooks/rb-alarm-engine
%defattr(0644,root,root)
/var/chef/cookbooks/rb-alarm-engine/README.md


%doc

%changelog
* Wed Jul 29 2026 David Vanhoucke <dvanhoucke@redborder.com>
- first version
