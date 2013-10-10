AndroidSmartUpdatesServer
===================
Android Smart Updates is an Open Source library that make patch way update(using [bsdiff][1])  in android easily.<br>
And server is base on Ruby on Rails.<br>
Link to library source code [AndroidSmartUpdates][2]

Demo
----------
Demo link 

How to Install
----------
1.  install the rails 3.2.13 and ruby 2.0
2.  exec these command in terminal

> \$ cd your_application_root_path  <br>
> \$ bundle install <br>
> \$ rake db:migrate<br>
> \$ cd lib/differ/c_code <br>
> \$ ruby extconf.rb <br>
> \$ make <br>

if tips that "bzlib.h" is not existed, you need to install bzip2 develop package 
by your self.<br>
for example, in CentOS:<br>
> yum install bzip2-devel
<br>

Usage
----------
exec 
> \$ rails s

in the application root path.

About Author
----------
A student from SCAU China.<br>
Email: specialcyci#gmail.com


  [1]: http://www.daemonology.net/bsdiff/
  [2]: https://github.com/SpecialCyCi/AndroidSmartUpdates