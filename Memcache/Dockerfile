
#ckerfile to run Memcached Containers

FROM ubuntu


MAINTAINER Karthik Namburu <namburu.karthik@gmail.com>

RUN apt-get update

RUN apt-get install -y memcached



#port to expose

EXPOSE 11211


# Default Memcached run command aruguments

CMD ["-m", "1024"]

#set the user to run Memcached daemon

USER daemon


#Set the entrypoint to memcached binary
ENTRYPOINT memcached

