FROM ubuntu:14.04
MAINTAINER Karthik Namburu <namburu.karthik@gmail.com>
 
RUN apt-get -y update

#Install ruby dependencies
RUN apt-get install -y wget curl \
    build-essential git git-core \
    libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev

#Install the Proj4 lib for rgeo gem
RUN curl -fSL -o proj.tar.gz "http://download.osgeo.org/proj/proj-4.8.0.tar.gz" \
      && mkdir -p /tmp/proj4 \
      && tar -xzf proj.tar.gz -C /tmp/proj4/ \
      && rm proj.tar.gz \
      && curl -fSL -o proj-datumgrid.tar.gz "http://download.osgeo.org/proj/proj-datumgrid-1.5.tar.gz" \
      && tar -xzf proj-datumgrid.tar.gz -C /tmp/proj4/proj-4.8.0/nad \
      && rm proj-datumgrid.tar.gz \
      && cd /tmp/proj4/proj-4.8.0 \
      && ./configure \
      && make \
      && make install \
      && rm -r /tmp/proj4

RUN apt-get -y update

# Intall software-properties-common for add-apt-repository and Image Magick
RUN apt-get install --no-install-recommends --force-yes  -y software-properties-common
RUN apt-get install --no-install-recommends --force-yes  -y imagemagick
RUN apt-get install --no-install-recommends --force-yes  -y libmagickwand-dev

RUN apt-get update

# Install ruby-install
RUN cd /tmp &&\
  wget -O ruby-install-0.6.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.6.0.tar.gz \
  && tar -xzvf ruby-install-0.6.0.tar.gz \
  && cd ruby-install-0.6.0/ \
  && make install

# Install MRI Ruby
RUN ruby-install ruby 2.2.2

# Add Ruby binaries to $PATH
ENV PATH /opt/rubies/ruby-2.2.2/bin:$PATH

# Add options to gemrc
RUN echo "install: --no-document\nupdate: --no-document" > ~/.gemrc


RUN gem install bundler

RUN apt-get -y update

# Install nodejs
RUN apt-get install -qq -y nodejs


#Install Passenger GEM
RUN gem install passenger

RUN apt-get -y update

#Install Apache2
RUN apt-get install -y apache2

#Install Passenger
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
RUN apt-get install -y apt-transport-https ca-certificates

RUN echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main >> /etc/apt/sources.list.d/passenger.list

RUN chmod 600 /etc/apt/sources.list.d/passenger.list

RUN apt-get install  -y libcurl4-openssl-dev apache2-mpm-worker apache2-threaded-dev libapr1-dev libaprutil1-dev

RUN apt-get -y update

RUN apt-get install -y libapache2-mod-passenger

#Enabling the passenger module
RUN a2enmod passenger

RUN apache2ctl restart

# Install the latest postgresql lib for pg gem
RUN apt-get -y update
RUN apt-get install -y --force-yes postgresql postgresql-contrib
RUN apt-get install -y --force-yes libpq-dev

#Set the TimeZone
RUN ln -f -s /usr/share/zoneinfo/America/New_York /etc/localtime

#Adding the configuration files to start Passenger and Apache
ADD apache2.conf /etc/apache2/
ADD sims.conf /etc/apache2/sites-available/
#ADD passenger.conf /etc/apache2/mods-available/
#ADD passenger.load /etc/apache2/mods-available/

RUN apt-get -y update

RUN a2ensite sims

RUN a2dissite 000-default

#Change the user to root
USER root

#create an user app
RUN useradd -ms /bin/bash app


#ENV BUNDLE_DISABLE_SHARED_GEMS 1
#ENV BUNDLE_PATH /var/www/sims/vendor/bundle

WORKDIR /var/www/sims
ENV RAILS_ENV development

# Install Gems
ADD Gemfile /var/www/sims/Gemfile
ADD Gemfile.lock /var/www/sims/Gemfile.lock
RUN bundle --deployment




#RUN apt-get -y update

# Adding SIMS code
ADD . /var/www/sims

RUN chown -R app:app /var/www/sims


#Install Bundler
RUN gem install bundler

# Install foreman
#RUN gem install foreman

# Precompiling SIMS assets
RUN bundle exec rake assets:precompile

# Expose port numbers
EXPOSE 80 443

USER root

#RUN service apache2 start
#CMD foreman start -f Procfile


#Adding Dev DB Environmnet varialbles.

ENV DB_ADAPTER postgis
ENV DB_ENCODING utf8
ENV DB_PORT 5432
ENV DB_POOL_SIZE 5
ENV APPLICATION_TITLE SIMS (Dev)
ENV AWS_S3_ENDPOINT http://transam-sims-dev.dot.tcd.nyc.s3-website-us-east-1.amazonaws.com
ENV AWS_S3_BUCKET transam-sims-dev.dot.tcd.nyc
ENV DB_SCHEMA simsdata-5
ENV DB_USER_NAME app
ENV DB_PASSWORD dotsims2015
ENV DB_HOST sims-test.c4hhvnlgssle.us-east-1.rds.amazonaws.com
ENV RAILS_ENV development
ENV SECRET_KEY_BASE 76e1012cfd9a96d30cbe018933158258b7f246de715727c6626c60f01c941fcdc45105c3c6a09b4c36c64e66587e2c880384fb342d6d9278b7e26bdf2202d84d


ENTRYPOINT service apache2 start && tail -f /var/log/apache2/error.log
