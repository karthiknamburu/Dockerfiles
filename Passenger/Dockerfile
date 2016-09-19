FROM phusion/passenger-ruby22
MAINTAINER Karthik Namburu <namburu.karthik@gmail.com>


#Update the system
RUN apt-get update
RUN apt-get install -qq -y software-properties-common
#RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"

#Install the postgresql lib for pg gem
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --force-yes libpq-dev

#Install git
RUN apt-get install git

#Install Newrelic
#RUN apt-get install newrelic-sysmond

#Set the TimeZone
RUN ln -f -s /usr/share/zoneinfo/America/New_York /etc/localtime


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

# Set correct environment variables.
ENV HOME /root

## Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Start Nginx / Passenger
RUN rm -f /etc/service/nginx/down

# Remove the default site
RUN rm /etc/nginx/sites-enabled/default

# Add the nginx info
ADD nginx.conf /etc/nginx/sites-enabled/webapp.conf

# Prepare folders
RUN mkdir /home/app/webapp

# Add the rails app
ADD . /home/app/webapp
RUN chown -R app:app /home/app/webapp


## Run Bundle in a cache efficient way
WORKDIR /tmp
ADD Gemfile /tmp/
ADD Gemfile.lock /tmp/
ENV BUNDLE_DISABLE_SHARED_GEMS 1
#ENV BUNDLE_PATH vendor/bundle

#WORKDIR /home/app/webapp
RUN bundle install
#RUN bundle install --path vendor/bundle 
RUN bundle --deployment

ENV ELASTICACHE_ENDPOINT 54.164.213.72:45001

WORKDIR /home/app/webapp
RUN bundle exec rake assets:precompile


ENV RAILS_ENV production
#ENV PASSENGER_COMPILE_NATIVE_SUPPORT_BINARY=0

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
