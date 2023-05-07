Name:		b20-565-03
Version:	1.0
Release:	1%{?dist}
Summary:	Программа студента Смирнова Артура группы Б20-565

Group:		Testing
License:	GPL
URL:		https://github.com/SmirnovArtur/BOS_2022
Source0:	%{name}-%{version}.tar.gz

BuildRequires:	/bin/rm, /bin/mkdir, /bin/cp
Requires:	/bin/bash, /usr/bin/date, gnuplot
BuildArch:      noarch

%description
A test package

%prep
%setup -q

%install
mkdir -p %{buildroot}%{_bindir}
install -m 755 b20-565-03 %{buildroot}%{_bindir}

%files
%{_bindir}/b20-565-03


%changelog
%changelog
* Sun May 07 2023 Smirnov
- Added %{_bindir}/b20-565-03
