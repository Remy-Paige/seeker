# seeker

Seeker

    This project is an under devlopment proof of concept for a research aid. It uses OCR to scan reports from the European Charter for Regional or Minority Languages and then indexes them into a database searchable with elasticsearch.

Tech/framework

    This project is built with ruby on rails 4.2.8 and is deployed using passenger

installation

	before starting, you will need the following packages on your machine. Note that the docsplit gem will succeed in installing without its dependanices, but it won't work when you try to use it.

	ubuntu:
	curl gpg gcc gcc-c++ make git openjdk-8-jre-headless 
	libcairo2-dev
	libgtk2.0-dev
	libmagic-dev
	tesseract-ocr
	ghostscript
	gobject-introspection
	poppler-utiils 
	poppler-data

	PPA for graphicsmagick

	yum:
	curl gpg gcc gcc-c++ make pygpgme git openjdk-8-jre-headless 
	cairo-devel 
	gtk2-devel 
	file-devel
	tesseract
	graphicsmagick 
	ghostscript
	gobject-introspection
	poppler-utiils 
	poppler-data
    poppler-glib-devel     

	node.js is also required, commands can be found in the passenger tutorial in the deployment section.

	The database used is postgres - 9.2 works on redhet/centos and 10 works on ubuntu
	http://yallalabs.com/linux/how-to-install-and-use-postgresql-10-on-ubuntu-16-04/
	also install the libpq-dev package

	As well as this, an elasticsearch 2.3 instance must be running for the project to work properly. Make sure that your system is using java 8.
	https://www.elastic.co/downloads/past-releases/elasticsearch-2-3-2
	 
	Finally, install your choice of gem manager, I have been using rvm. Best to follow the rvm documentation guide with the passenger guide as supplemental.

setup

	rvm install 2.4.0
	rvm use 2.4.0@seeker --create
	gem install bundler --no-rdoc --no-ri
	bundle install

	cd into target folder and clone project
	configure database.yml, something similar to
		adapter: postgresql
		encoding: unicode
		database: seeker
		host: localhost
		pool: 5
	should work, but you will probably need to fiddle with database users

	configure secrets.yml

	chmod 700 config db
	chmod 600 config/database.yml config/secrets.yml

    if webpacker asks to overwrite the yml file, that's fine

	If you are using an IDE that manages your gems like rubymine, make sure that it is set up to use the seeker gemset, not default.

	bundle exec rake assets:precompile db:setup 
	rake searchkick:reindex CLASS=Section

	I reccomend *not* doing db:migrate, db:setup will run db:schema:load instead
running
    
    make sure that elastic search and ./bin/webpack-dev-server are running before rails serve happens 
deployment

	Once you have the development envrionment working correctly, you should be able to deploy the project using the passenger tutorial. I unfortunatly do not know how to install elasticsearch or postgres in production

	https://www.phusionpassenger.com/library/walkthroughs/deploy/ruby/ownserver/integration_mode.html

	SecRequestBodyNoFilesLimit will need to be 1MB, as the text files submitted sometimes are quite large. 
	
	If you are on a network and are not a local user, you can install rvm on a local machine and not in $HOME using --path argument and/or the $rvm_path environment variable

Tests

	Unfortunatly, tests are sparse and out of date at the moment, however the rspec framework is present

Credits

	Credit goes to Rick Daniel at https://github.com/araishikeiwai for devloping the first version, and Kyriakos Kalorkoti at the University of Edinburgh for proposing and supervising this project.
