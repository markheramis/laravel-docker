# Setup script

This document will show you how to configure your setup script in case you need to do something before your application starts.

First of, in the [start-container](/start-container#13) file, you'll see that the script will look for a certain `setup` file, if it exists within your project's **root** directory, it will run it, else it will do nothing.

If you need to do something before your Laravel Application truely starts, all you need to do is to create a `setup` file

```
touch setup
```

and then fill in your desired commands within...


For example:

Say you want to run database migration and seeding before your application starts, all you need is do the following:

```
touch setup
```

and then append the following inside `setup` file:

```
php artisan migrate
php artisan db:seed
```

**Note**: you don't need to make changes in the Dockerfile, the `start-container` will immediatly try to look for a certain `setup` file and run it if it is found else does nothing instead.