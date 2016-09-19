IFROM sims-passenger
MAINTAINER Karthik Namburu <namburu.karthik@gmail.com>

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

#Update the system
RUN apt-get update
RUN apt-get install -qq -y software-properties-common
#RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"
RUN apt-get install -y libmagickwand-dev imagemagick


#Install Wicked_pdf and its dependent packages
RUN apt-get update
RUN apt-get install -y fontconfig fontconfig-config libaudio2 libavahi-client3 libavahi-common-data libavahi-common3 libfontconfig1 libgstreamer-plugins-base0.10-0 libgstreamer0.10-0 libice6 liblcms1 liborc-0.4-0 libqt4-dbus libqt4-declarative libqt4-network libqt4-script libqt4-xml libqt4-xmlpatterns libqtcore4 libqtgui4 libqtwebkit4 libsm6 libxi6 libxrender1 libxt6 qdbus ttf-dejavu-core x11-common \
  && cd /usr/local/bin \
  && curl -C - -O http://wkhtmltopdf.googlecode.com/files/wkhtmltopdf-0.9.9-static-amd64.tar.bz2 \
  && tar -xvjf wkhtmltopdf-0.9.9-static-amd64.tar.bz2 \
  && ln -s wkhtmltopdf-amd64 wkhtmltopdf

#Install the postgresql lib for pg gem
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --force-yes libpq-dev


#Install git
RUN apt-get install git

#Install Newrelic
#RUN apt-get install newrelic-sysmond

#install NodeJS
RUN apt-get -y install nodejs


# Set correct environment variables.
ENV HOME /root

## Use baseimage-docker's init system.
#CMD ["/sbin/my_init"]

# Start Nginx / Passenger
RUN rm -f /etc/service/nginx/down

# Remove the default site
RUN rm /etc/nginx/sites-enabled/default

# Add the nginx info
ADD webapp.conf /etc/nginx/sites-enabled/webapp.conf

ADD nginx.conf /etc/nginx/nginx.conf

USER root

#create user app
RUN adduser app

# Prepare folders
RUN mkdir /home/webapp

RUN chown -R app:app /home/webapp

# Add the rails app
ADD ./sims/ /home/webapp

WORKDIR /home/webapp

ENV BUNDLE_DISABLE_SHARED_GEMS 1

ENV BUNDLE_PATH /home/webapp/vendor/bundle

ADD Gemfile /home/webapp/Gemfile

ADD Gemfile.lock /home/webapp/Gemfile.lock

RUN bundle --deployment


#USER app

ENV RAILS_ENV development
ENV PASSENGER_COMPILE_NATIVE_SUPPORT_BINARY=0

# Assets precompiling
#RUN bundle exec rake assets:precompile

# Starting the Clockwork (Backend processes)
ONBUILD RUN bundle exec clockworkd -c bin/clock.rb restart

# Starting the delayed_job
ONBUILD RUN bundle exec bin/delayed_job restart

#
EXPOSE 80

USER root

#Set the TimeZone
RUN ln -f -s /usr/share/zoneinfo/America/New_York /etc/localtime

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV RAILS_ENV development

