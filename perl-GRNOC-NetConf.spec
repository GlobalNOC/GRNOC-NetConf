Summary: GRNOC NetConf Perl Libraries
Name: perl-GRNOC-NetConf
Version: 0.0.1
Release: 1%{?dist}
License: APL 2.0
Group: Network
URL: http://globalnoc.iu.edu
Source0: %{name}-%{version}.tar.gz
BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:noarch

BuildRequires: perl
BuildRequires: perl-Test-Pod
BuildRequires: perl-Test-Pod-Coverage
Requires: perl-XML-Writer
Requires: perl-Moo
Requires: perl-Net-SSH2
Requires: perl-GRNOC-Log
Requires: perl-Devel-Cover
Requires: perl-Event-Lib
Requires: perl-JSON-XS
Requires: perl-JSON-Schema
Requires: perl-autovivification
Requires: perl(GRNOC::WebService::Regex)
Requires: perl-Proc-Daemon
Requires: uuid-perl

%description
The GRNOC::NetConf collection is a set of perl modules which are used to
communicate with network devices via the netconf.

%prep
%setup -q -n perl-GRNOC-NetConf-%{version}

%build
%{__perl} Makefile.PL PREFIX="%{buildroot}%{_prefix}" INSTALLDIRS="vendor"
make

%install
rm -rf $RPM_BUILDR_ROOT
make pure_install

# clean up buildroot
find %{buildroot} -name .packlist -exec %{__rm} {} \;

%{_fixperms} $RPM_BUILD_ROOT/*

%check
make test

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644, root, root, -)
%{perl_vendorlib}/GRNOC/NetConf/Device.pm
%{perl_vendorlib}/GRNOC/NetConf/Device
%{perl_vendorlib}/GRNOC/NetConf/Device/Brocade.pm
%{perl_vendorlib}/GRNOC/NetConf/Device/Brocade/
%{perl_vendorlib}/GRNOC/NetConf/Device/Brocade/MLXe.pm
%{perl_vendorlib}/GRNOC/NetConf/Device/Brocade/MLXe/
%{perl_vendorlib}/GRNOC/NetConf/Device/Brocade/MLXe/5_8_0.pm
%{perl_vendorlib}/GRNOC/NetConf/Device/JUNOS.pm
%{perl_vendorlib}/GRNOC/NetConf/Device/JUNOS/
%{perl_vendorlib}/GRNOC/NetConf/Device/JUNOS/13_3R1_6.pm

%doc %{_mandir}/man3/GRNOC::NetConf::Device.3pm.gz
%doc %{_mandir}/man3/GRNOC::NetConf::Device::Brocade.3pm.gz
%doc %{_mandir}/man3/GRNOC::NetConf::Device::Brocade::MLXe.3pm.gz
%doc %{_mandir}/man3/GRNOC::NetConf::Device::Brocade::MLXe::5_8_0.3pm.gz
%doc %{_mandir}/man3/GRNOC::NetConf::Device::JUNOS.3pm.gz
%doc %{_mandir}/man3/GRNOC::NetConf::Device::JUNOS::13_3R1_6.3pm.gz

%changelog

