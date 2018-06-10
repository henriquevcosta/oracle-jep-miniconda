FROM centos:centos7

MAINTAINER "Henrique Costa" henrique.costa@gmail.com

WORKDIR /tmp/

#Install JAVA
RUN curl -L -O -H 'Cookie: oraclelicense=accept-securebackup-cookie'  'http://download.oracle.com/otn-pub/java/jdk/8u172-b11/a58eab1ec242421181065cdc37240b08/jdk-8u172-linux-x64.rpm' \
 && yum install -y /tmp/jdk-8u172-linux-x64.rpm \
                   bzip2 \
                   maven \
                   git \
 && yum groupinstall -y 'Development Tools'

#Java environment
ENV JAVA_HOME  /usr/java/jdk1.8.0_172-amd64
RUN alternatives --set java $JAVA_HOME/jre/bin/java \
 && alternatives --set javac $JAVA_HOME/bin/javac

#Environment setup related to Python+JEP
ENV CONDA_HOME /root/miniconda3
ENV PATH $CONDA_HOME/bin:$PATH
ENV CONDA_ENVIRONMENT conda-environment
ENV JEP_LOCATION ${CONDA_HOME}/envs/${CONDA_ENVIRONMENT}/lib/python3.6/site-packages/jep
ENV JEP_JAR ${JEP_LOCATION}/jep-3.7.1.jar

# Most software that requires JEP will probably need to point to the dyn libs generated by the command above
ENV LD_LIBRARY_PATH ${JEP_LOCATION}:${LD_LIBRARY_PATH}

# Processes that must see the correct python must add this variable to LD_PRELOAD
# We don't do it here since that breaks yum
ENV TO_PRELOAD ${CONDA_HOME}/envs/${CONDA_ENVIRONMENT}/lib/libpython3.6m.so

WORKDIR /root/

# Install python+conda and H2O
RUN echo "Installing Miniconda..." \
    && curl -L -O 'https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh'  \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && echo "Done." \
    && echo "Creating environment..." \
    && conda create -y -n ${CONDA_ENVIRONMENT} python=3 numpy scipy pandas scikit-learn \
    && echo "Done." \
    && source activate ${CONDA_ENVIRONMENT} \
    && cd /opt \
    && git clone https://github.com/ninia/jep.git \
    && cd jep \
    && echo "Installing JEP..." \
    && python setup.py build install \
    && conda clean -y -a \
    && yum clean all

