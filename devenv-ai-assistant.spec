# Macros (set by CI / COPR Makefile / rpmbuild --define):
#   devenv_ai_ver  — RPM Version  (default: from VERSION file baseline)
#   devenv_ai_rel  — RPM Release without dist tag (%%{?dist} appended below)
Name:           devenv-ai-assistant
Version:        %{?devenv_ai_ver}%{!?devenv_ai_ver:1.0.0}
Release:        %{?devenv_ai_rel}%{!?devenv_ai_rel:1}%{?dist}
Summary:        Shared AI editor configs for Vim/Neovim (devenv stack)

License:        MIT
URL:            https://github.com/dsedgmen/devenv-ai-assistant
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch
BuildRequires:  coreutils

%description
Shared configuration files for the devenv AI coding assistant editor
integration. Install devenv-ai-assistant-neovim and/or
devenv-ai-assistant-vim for editor-specific loaders.

Does not overwrite user ~/.vimrc or ~/.config/nvim/init.lua.

%package -n devenv-ai-assistant-neovim
Summary:        Neovim AI keymaps for devenv-ai-helper
Requires:       %{name} = %{version}-%{release}
Requires:       neovim
Requires:       devenv-ai-helper

%description -n devenv-ai-assistant-neovim
Loads devenv AI keymaps into Neovim via the site packpath
(usr/share/nvim/site/pack/...). Requires devenv-ai-helper on PATH.

%package -n devenv-ai-assistant-vim
Summary:        Vim AI keymaps for devenv-ai-helper
Requires:       %{name} = %{version}-%{release}
Requires:       vim-enhanced
Requires:       devenv-ai-helper

%description -n devenv-ai-assistant-vim
Loads devenv AI keymaps into Vim via vimfiles plugin
(usr/share/vim/vimfiles/plugin/). Requires devenv-ai-helper on PATH.

%prep
%autosetup -n %{name}-%{version}

%build
# no-op (config files only)

%install
install -d %{buildroot}%{_datadir}/devenv-ai-assistant
install -m 0644 nvim-init.lua %{buildroot}%{_datadir}/devenv-ai-assistant/nvim-init.lua
install -m 0644 vimrc %{buildroot}%{_datadir}/devenv-ai-assistant/vimrc
install -m 0644 QUICKREF.txt %{buildroot}%{_datadir}/devenv-ai-assistant/QUICKREF.txt
install -m 0644 README.md %{buildroot}%{_datadir}/devenv-ai-assistant/README.md

# Neovim packpath plugin
install -d %{buildroot}%{_datadir}/nvim/site/pack/devenv-ai/start/devenv-ai/plugin
install -m 0644 rpm/neovim-plugin.lua \
  %{buildroot}%{_datadir}/nvim/site/pack/devenv-ai/start/devenv-ai/plugin/devenv-ai.lua

# Vim vimfiles plugin
install -d %{buildroot}%{_datadir}/vim/vimfiles/plugin
install -m 0644 rpm/vim-plugin.vim \
  %{buildroot}%{_datadir}/vim/vimfiles/plugin/devenv-ai.vim

%files
%license LICENSE
%dir %{_datadir}/devenv-ai-assistant
%{_datadir}/devenv-ai-assistant/nvim-init.lua
%{_datadir}/devenv-ai-assistant/vimrc
%{_datadir}/devenv-ai-assistant/QUICKREF.txt
%{_datadir}/devenv-ai-assistant/README.md

%files -n devenv-ai-assistant-neovim
%{_datadir}/nvim/site/pack/devenv-ai/start/devenv-ai/plugin/devenv-ai.lua

%files -n devenv-ai-assistant-vim
%{_datadir}/vim/vimfiles/plugin/devenv-ai.vim

%changelog
* Thu Nov 05 2026 David Sedgmen <dsedgmen@users.noreply.github.com> - 1.0.0-1
- Initial RPM release with neovim and vim subpackages
