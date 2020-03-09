FROM continuumio/anaconda3

RUN apt update && apt install -y --no-install-recommends unzip gnupg wget zlib1g-dev build-essential cmake libboost-dev google-perftools libgoogle-perftools-dev gcc g++ sudo

RUN pip install --upgrade pip

# Create Jupyter Notebook config file
RUN mkdir -p /root/.jupyter \
  && echo "c.NotebookApp.allow_root = True" >> /root/.jupyter/jupyter_notebook_config.py \
  && echo "c.NotebookApp.ip = '*'" >> /root/.jupyter/jupyter_notebook_config.py \
  && echo "c.NotebookApp.token = ''" >> /root/.jupyter/jupyter_notebook_config.py

EXPOSE 8888

# Install gensim
RUN pip install gensim

# Install MeCab
RUN apt install -y --no-install-recommends mecab libmecab-dev mecab-ipadic-utf8 \
  && pip install mecab-python3

# Install mecab-ipadic-NEologd
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git /tmp/neologd \
  && /tmp/neologd/bin/install-mecab-ipadic-neologd -n -a -y \
  && sed -i -e "s|^dicdir.*$|dicdir = /usr/lib/mecab/dic/mecab-ipadic-neologd|" /etc/mecabrc \
  && rm -rf /tmp/neologd

# Install neologdn
RUN pip install neologdn

# Install CRF++
RUN wget -O /tmp/CRF++-0.58.tar.gz "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7QVR6VXJ5dWExSTQ" \
  && cd /tmp \
  && tar zxf CRF++-0.58.tar.gz \
  && cd CRF++-0.58 \
  && ./configure \
  && make \
  && make install \
  && cd / \
  && rm /tmp/CRF++-0.58.tar.gz \
  && rm -rf /tmp/CRF++-0.58 \
  && ldconfig

# Install CaboCha
RUN cd /tmp \
  && curl -c cabocha-0.69.tar.bz2 -s -L "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7SDd1Q1dUQkZQaUU" \
    | grep confirm | sed -e "s/^.*confirm=\(.*\)&amp;id=.*$/\1/" \
    | xargs -I{} curl -b  cabocha-0.69.tar.bz2 -L -o cabocha-0.69.tar.bz2 \
      "https://drive.google.com/uc?confirm={}&export=download&id=0B4y35FiV1wh7SDd1Q1dUQkZQaUU" \
  && tar jxf cabocha-0.69.tar.bz2 \
  && cd cabocha-0.69 \
  && export CPPFLAGS=-I/usr/local/include \
  && ./configure --with-mecab-config=`which mecab-config` --with-charset=utf8 \
  && make \
  && make install \
  && cd python \
  && python setup.py build \
  && python setup.py install \
  && cd / \
  && rm /tmp/cabocha-0.69.tar.bz2 \
  && rm -rf /tmp/cabocha-0.69 \
  && ldconfig
  
# Install juman++
RUN wget https://github.com/ku-nlp/jumanpp/releases/download/v2.0.0-rc3/jumanpp-2.0.0-rc3.tar.xz \
  && tar xvf jumanpp-2.0.0-rc3.tar.xz \
  && cd jumanpp-2.0.0-rc3/ \
  && mkdir build \
  && cd build/ \
  && cmake .. -DCMAKE_BUILD_TYPE=Release \
  && make \
  && make install

# Install fastText
RUN pip install git+https://github.com/facebookresearch/fastText.git

# Install Janome
RUN pip install janome

# Install spaCy
RUN pip install spacy

# Install pykakasi
RUN pip install pykakasi

# Install ginza
RUN pip install ginza

WORKDIR /Project
ADD requirements.txt /Project/
RUN pip install -r requirements.txt

# Install crawling
RUN pip install selenium tweepy lxml joblib twitter_api pathlib cssselect

# install google chrome
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list && \
    apt -yqq update && \
    apt -yqq install google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# install chromedriver
RUN CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` && \
    mkdir -p /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    curl -sS -o /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip && \
    unzip -qq /tmp/chromedriver_linux64.zip -d /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    rm /tmp/chromedriver_linux64.zip && \
    chmod +x /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver && \
    ln -fs /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver /usr/local/bin/chromedriver

