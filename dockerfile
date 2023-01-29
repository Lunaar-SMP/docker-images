#
# Copyright (c) 2022 Copetan
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

FROM    python:3.11-slim-bullseye

ENV     LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

ARG     ZULU_REPO_VER=1.0.0-3

RUN     apt-get -qq update && \
        apt-get -qq -y --no-install-recommends install gnupg software-properties-common locales curl tzdata && \
        echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
        locale-gen en_US.UTF-8 && \
        apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9 && \
        curl -sLO https://cdn.azul.com/zulu/bin/zulu-repo_${ZULU_REPO_VER}_all.deb && dpkg -i zulu-repo_${ZULU_REPO_VER}_all.deb && \
        apt-get -qq update && \
        apt-get -qq -y dist-upgrade && \
        mkdir -p /usr/share/man/man1 && \
        echo "Package: zulu17-*\nPin: version 17.0.6-*\nPin-Priority: 1001" > /etc/apt/preferences && \
        apt-get -qq -y --no-install-recommends install zulu17-jdk=17.0.6-* && \
        apt-get -qq -y purge gnupg software-properties-common curl && \
        apt -y autoremove && \
        rm -rf /var/lib/apt/lists/* zulu-repo_${ZULU_REPO_VER}_all.deb

ENV     JAVA_HOME=/usr/lib/jvm/zulu17-ca-amd64

RUN     apt-get update -y \
    	&& apt-get install -y lsof curl ca-certificates openssl git tar sqlite3 fontconfig libfreetype6 tzdata iproute2 libstdc++6 \
        && useradd -d /home/container -m container

USER    container
ENV     USER=container HOME=/home/container
WORKDIR /home/container

COPY    ./entrypoint.sh /entrypoint.sh
CMD     [ "/bin/bash", "/entrypoint.sh" ]