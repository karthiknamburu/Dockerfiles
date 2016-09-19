FROM ubuntu:14.04
MAINTAINER Karthik Namburu <namburu.karthik@gmail.com>

RUN apt-get update

# Install ruby dependencies
RUN apt-get install -y wget curl \
    build-essential git git-core \
    zlib1g-dev libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev

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

RUN apt-get update

# Intall software-properties-common for add-apt-repository and Image Magick
RUN apt-get install --no-install-recommends --force-yes  -y software-properties-common
RUN apt-get install --no-install-recommends --force-yes  -y imagemagick
RUN apt-get install --no-install-recommends --force-yes  -y libmagickwand-dev

RUN apt-get -y update

# Install rbenv
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
RUN echo '# rbenv setup' > /etc/profile.d/rbenv.sh
RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh
RUN echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
RUN chmod +x /etc/profile.d/rbenv.sh

# Install ruby-build
RUN mkdir /usr/local/rbenv/plugins
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build

ENV RBENV_ROOT /usr/local/rbenv

ENV PATH "$RBENV_ROOT/bin:$RBENV_ROOT/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
# does not work. PATH is set to
# $RBENV_ROOT/shims:$RBENV_ROOT/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Install ruby
RUN rbenv install 2.2.2
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc
RUN rbenv global 2.2.2
RUN gem install bundler

RUN apt-get update

# Install nodejs
RUN apt-get install -qq -y nodejs


# Install the latest postgresql lib for pg gem
RUN apt-get update
RUN apt-get install -y --force-yes postgresql postgresql-contrib
RUN apt-get install -y --force-yes libpq-dev

#Set the TimeZone
RUN ln -f -s /usr/share/zoneinfo/America/New_York /etc/localtime

RUN apt-get update

USER root

#create a user app
RUN useradd -ms /bin/bash app

WORKDIR /var/www/sims
ENV RAILS_ENV development

# Install Gems
ADD Gemfile /var/www/sims/Gemfile
ADD Gemfile.lock /var/www/sims/Gemfile.lock
RUN bundle --deployment

RUN gem install passenger

RUN apt-get install  -y libcurl4-openssl-dev apache2-mpm-worker apache2-threaded-dev libapr1-dev libaprutil1-dev

RUN passenger-install-apache2-module --auto

ENV BUNDLE_DISABLE_SHARED_GEMS 1
ENV BUNDLE_PATH /var/www/sims/vendor/bundle

RUN apt-get update


# Adding SIMS code 
ADD . /var/www/sims

#RUN chown -R app:app /var/www/sims

# Install foreman
RUN gem install foreman

# Add default unicorn config
ADD unicorn.rb /var/www/sims/config/unicorn.rb

RUN bundle exec rake assets:precompile

# Expose port numbers
EXPOSE 80 443

USER root

#Install Wicked_pdf and its dependent packages
RUN apt-get update

RUN apt-get install -y fontconfig fontconfig-config libaudio2 libavahi-client3 libavahi-common-data libavahi-common3 libfontconfig1 libgstreamer-plugins-base0.10-0 libgstreamer0.10-0 libice6 liblcms1 liborc-0.4-0 libqt4-dbus libqt4-declarative libqt4-network libqt4-script libqt4-xml libqt4-xmlpatterns libqtcore4 libqtgui4 libqtwebkit4 libsm6 libxi6 libxrender1 libxt6 qdbus ttf-dejavu-core x11-common \
  && cd /usr/local/bin \
  && curl -C - -O http://wkhtmltopdf.googlecode.com/files/wkhtmltopdf-0.9.9-static-amd64.tar.bz2 \
  && tar -xvjf wkhtmltopdf-0.9.9-static-amd64.tar.bz2 \
  && ln -s wkhtmltopdf-amd64 wkhtmltopdf

CMD bundle exec unicorn -c config/unicorn.rb -D

#CMD /usr/sbin/nginx -c /etc/nginx/nginx.conf

CMD foreman start -f Procfile



