#!/bin/bash

# Hadoop https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html
# Terasort, teragen, teravalidate https://support.oracle.com/knowledge/Oracle%20Database%20Products/2037949_1.html
sudo apt-get install ssh pdsh wget -y
cd ~/Downloads/
wget https://apache.claz.org/hadoop/common/hadoop-3.3.0/CHANGELOG.md

wget https://apache.claz.org/hadoop/common/hadoop-3.3.0/CHANGELOG.md
wget https://apache.claz.org/hadoop/common/hadoop-3.3.0/RELEASENOTES.md
wget https://apache.claz.org/hadoop/common/hadoop-3.3.0/hadoop-3.3.0.tar.gz

# Modify ./etc/hadoop/hadoop-env.sh
# # set to the root of your Java installation
#  export JAVA_HOME=/usr/java/latest

# MODIFY
#etc/hadoop/core-site.xml:

#<configuration>
#    <property>
#        <name>fs.defaultFS</name>
#        <value>hdfs://localhost:9000</value>
#    </property>
#</configuration>

# MODIFY
# etc/hadoop/hdfs-site.xml:

#<configuration>
#    <property>
#        <name>dfs.replication</name>
#        <value>1</value>
#    </property>
#</configuration>

#ssh localhost
#If you cannot ssh to localhost without a passphrase, execute the following commands:

#ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
#cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
#chmod 0600 ~/.ssh/authorized_keys

# RUN MAP REDUCE JOB LOCALLY
# Format the filesystem
# bin/hdfs namenode -format

# Start NameNode daemon and DataNode daemon:

#  $ sbin/start-dfs.sh
#The hadoop daemon log output is written to the $HADOOP_LOG_DIR directory (defaults to $HADOOP_HOME/logs).

#Browse the web interface for the NameNode; by default it is available at:

#NameNode - http://localhost:9870/
#Make the HDFS directories required to execute MapReduce jobs:

#  $ bin/hdfs dfs -mkdir /user
#  $ bin/hdfs dfs -mkdir /user/<username>
#Copy the input files into the distributed filesystem:

#  $ bin/hdfs dfs -mkdir input
#  $ bin/hdfs dfs -put etc/hadoop/*.xml input
#Run some of the examples provided:

#  $ bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-3.2.1.jar grep input output 'dfs[a-z.]+'
#Examine the output files: Copy the output files from the distributed filesystem to the local filesystem and examine them:

#  $ bin/hdfs dfs -get output output
#  $ cat output/*
#or

#View the output files on the distributed filesystem:

#  $ bin/hdfs dfs -cat output/*
# When you’re done, stop the daemons with:

#  $ sbin/stop-dfs.sh

# RUN YARN ON A SINGLE NODE
#Configure parameters as follows:

#etc/hadoop/mapred-site.xml:

#<configuration>
#    <property>
#        <name>mapreduce.framework.name</name>
#        <value>yarn</value>
#    </property>
#    <property>
#        <name>mapreduce.application.classpath</name>
#        <value>$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/*:$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/lib/*</value>
#    </property>
#</configuration>
#etc/hadoop/yarn-site.xml:
#
#<configuration>
#    <property>
#        <name>yarn.nodemanager.aux-services</name>
#        <value>mapreduce_shuffle</value>
#    </property>
#    <property>
#        <name>yarn.nodemanager.env-whitelist</name>
#        <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>
#    </property>
#</configuration>
#Start ResourceManager daemon and NodeManager daemon:

#  $ sbin/start-yarn.sh
#Browse the web interface for the ResourceManager; by default it is available at:

#ResourceManager - http://localhost:8088/
#Run a MapReduce job.
#
#When you’re done, stop the daemons with:
#
#  $ sbin/stop-yarn.sh
