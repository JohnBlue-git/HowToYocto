project('hellomeson', 'cpp', 
  default_options : ['cpp_std=c++11']
)

# Specify path
inc_dir = include_directories('include')

# Specify source files
sources = files(
  'source/echo.cpp',
  'source/hello.cpp'
)

# Add the executable
executable('hellomeson',
    sources,
    include_directories : inc_dir,
    install: true,
    install_dir : '/usr/bin'
)

# Install
#install_data('hellomeson',
#    install_dir : get_option('bindir')
#)
