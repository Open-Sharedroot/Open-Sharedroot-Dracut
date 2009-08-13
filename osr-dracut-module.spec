Name: osr-dracut-module
Version: 0.8
Release: 1
Summary: Dracut modules for open sharedroot
Group: System Environment/Base		
License: GPLv2+	
URL: http://www.open-sharedroot.org/development/osr-dracut-module/
Source0: http://www.open-sharedroot.org/development/osr-dracut-module/osr-dracut-module-%{version}.tar.bz2
BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires: dracut >= 0.8
BuildArch: noarch

%description
This is the open-sharedroot module for dracut.


%package cluster
Summary: Additional base cluster modules for shared booting with open-sharedroot
Release: 1
Requires: dracut >= 0.8
Requires: osr-dracut-module
Requires: comoonics-cluster-py

%description cluster
Additional base cluster modules for shared booting with open-sharedroot

%package chroot
Summary: Additional chroot modules for chroot required open-sharedroot
Release: 1
Requires: dracut >= 0.8
Requires: osr-dracut-module
Requires: comoonics-cluster-py

%description chroot
Additional chroot modules if chroot environment is needed for open-sharedroot

%prep
%setup -q

%build
make

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT sbindir=/sbin sysconfdir=/etc mandir=%{_mandir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,0755)
%doc README.txt COPYING AUTHORS
%{_datadir}/dracut/modules.d/96osr

%files cluster
%defattr(-,root,root,0755)
%{_datadir}/dracut/modules.d/95osr-cluster
%doc README.osr-cluster.txt COPYING AUTHORS

%files chroot
%defattr(-,root,root,0755)
%{_datadir}/dracut/modules.d/95osr-chroot
%doc README.osr-chroot.txt COPYING AUTHORS

%changelog
* Thu Aug 13 2009 Marc Grimme <grimme@atix.de> 0.8-1
- Dependent on dracut 0.8 and above.
- Some functions moved to lib dir
- Added chroot module
* Tue Jul 23 2009 Marc Grimme <grimme@atix.de> 0.7-2
- added COPYING, AUTHORS to osr-dracut-module-cluster
* Wed Jul 22 2009 Marc Grimme <grimme@atix.de> 0.7-1
- dependent on dracut >= 0.7
* Wed Jul 22 2009 Marc Grimme <grimme@atix.de> 0.6-1
- Initial build
