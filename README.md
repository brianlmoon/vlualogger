# Logger for Apache virtual hosts written in Lua

The defacto standard for rotating Apache logs seems to be logrotate. However, this requires you to HUP Apache to start writing to a new file. I find this to be kind of messy.

I had used cronolog in the past. However, I did not like that I had to have one
cronolog process running per virtual host. I was using vlogger for a while. It was nice as it would allow you to use the virtual host name as part of the file name pattern. However, it was unmaintained.

So, I wrote vlualogger. It does the job nicely. Just one process for writing log files from Apache. It writes logs out to different files for different virtual hosts. It does not use a lot of resources.

