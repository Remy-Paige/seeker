# seeker

##Seeker

This project is an under development proof of concept for a research aid. It uses OCR to scan reports from the European Charter for Regional or Minority Languages and then indexes them into a database searchable with elasticsearch.

##Tech/framework

This project is built with ruby on rails 4.2.8 and is deployed using passenger

## Installation

before starting, you will need the following packages on your machine. Note that the docsplit gem will succeed in installing without its dependanices, but it won't work when you try to use it.

###ubuntu:
- curl gpg gcc gcc-c++ make git openjdk-8-jre-headless 
- libcairo2-dev
- libgtk2.0-dev
- libmagic-dev
- tesseract-ocr
- ghostscript
- gobject-introspection
- poppler-utiils 
- poppler-data
- graphicsmagick
cairo goobject

###redhat\centos:
- curl gpg gcc gcc-c++ make pygpgme git openjdk-8-jre-headless 
- cairo-devel 
- gtk2-devel 
- file-devel
- tesseract
- graphicsmagick 
- ghostscript
- gobject-introspection
- poppler-utiils 
- poppler-data
- poppler-glib-devel    
- cairo-gobject
- cairo-gobject-devel
- gobject-introspection-devel 

node.js is also required, commands can be found in the passenger tutorial in the deployment section.

The database used is postgres, 9.2 works on redhet/centos and 10 works on ubuntu, also install the libpq-dev package

http://yallalabs.com/linux/how-to-install-and-use-postgresql-10-on-ubuntu-16-04/

As well as this, an elasticsearch 2.3 instance must be running for the project to work properly. Make sure that your system is using java 8.

https://www.elastic.co/downloads/past-releases/elasticsearch-2-3-2
	 



###setup

the [passenger tutorial](https://www.phusionpassenger.com/library/walkthroughs/deploy/ruby/ownserver/integration_mode.html) is a very useful guide for setting up both the development and production environments.
1. Install ruby and node.js. You may want to use rbenv instead of rvm in your development environment.

```
rvm install 2.4.0
rvm use 2.4.0@seeker --create
gem install bundler --no-rdoc --no-ri
bundle install
```
2. Don't worry about passenger in the development environment, we'll be using rails serve not apache

3. Setup application

clone project into the target folder

Next configure database.yml, something similar to
	
```	
adapter: postgresql
encoding: unicode
database: seeker
host: localhost
pool: 5
```

should work, but you will probably need to fiddle with database users. This is honestly the most annoying part of the whole installation.

install your gems

If you are using an IDE that manages your gems like rubymine, make sure that it is set up to use the seeker gemset, not default.

configure secrets.yml

```
chmod 700 config db
chmod 600 config/database.yml config/secrets.yml
```

if webpacker asks to overwrite the yml file, that's fine. Make sure that the compile variables are set as true in the correct environment.

```
bundle exec rake assets:precompile db:setup 
rake searchkick:reindex CLASS=Section
```

I recommend not doing db:migrate, db:setup will run db:schema:load instead. Nothing bad should happen it will just take longer.

###running

Make sure that elastic search and ./bin/webpack-dev-server are running before rails serve happens 
deployment

##production

Once you have the development environment working correctly, you should be able to deploy the project in production as well. 

SecRequestBodyNoFilesLimit will need to be 1MB, as the text files submitted sometimes are quite large. 
	
If you are using the university of edinburgh's servers, there is a document in my thesis which explains some of the peculiarities of that system. 


##Tests

Unfortunately, tests are sparse and out of date at the moment, however the rspec framework is present.

##Credits

Credit goes to Rick Daniel at https://github.com/araishikeiwai for devloping the first version, and Kyriakos Kalorkoti at the University of Edinburgh for proposing and supervising this project.
