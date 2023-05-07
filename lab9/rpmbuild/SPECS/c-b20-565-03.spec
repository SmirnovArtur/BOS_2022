Name:		c-b20-565-03
Version:	1.0
Release:	1%{?dist}
Summary:	Программа студента Смирнова Артура группы Б20-565

Group:		Testing
License:	GPL
URL:		https://github.com/SmirnovArtur/BOS_2022
Source0:	%{name}-%{version}.tar.gz

BuildRequires:	gcc

%description
A test package

Requires: b20-565-03

%define debug_package %{nil}

%prep
%setup -q


%build
gcc -O2 -o c-b20-565-03 c-b20-565-03.c

%install
mkdir -p %{buildroot}%{_bindir}
cp c-b20-565-03 %{buildroot}%{_bindir}

%files
%{_bindir}/c-b20-565-03


%changelog
* Sun May 07 2023 Smirnov
- Added %{_bindir}/c-b20-565-03
