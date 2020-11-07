# Spark Cluster
This container will build:
- A spark cluster with 1 master/8 worker nodes
- JupyterLabs Environment
- PySpark

### Requirements
Docker 1.13.0+
Docker Compose 3.0+

### Create Images
#### Cluster Base Image
For the base image, we will be using a Linux distribution to install Java 8 (or 11), Apache Spark only requirement. We also need to install Python 3 for PySpark support and to create the shared volume to simulate the HDFS.
First, let’s choose the Linux OS. Apache Spark official GitHub repository has a Dockerfile for Kubernetes deployment that uses a small Debian image with a built-in Java 8 runtime environment (JRE). By choosing the same base image, we solve both the OS choice and the Java installation. Then, we get the latest Python release (currently 3.7) from Debian official package repository and we create the shared volume.
```
ARG debian_buster_image_tag=8-jre-slim
FROM openjdk:${debian_buster_image_tag}

# -- Layer: OS + Python 3.7

ARG shared_workspace=/opt/workspace

RUN mkdir -p ${shared_workspace} && \
    apt-get update -y && \
    apt-get install -y python3 && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    rm -rf /var/lib/apt/lists/*

ENV SHARED_WORKSPACE=${shared_workspace}

# -- Runtime

VOLUME ${shared_workspace}
CMD ["bash"]
```
#### Spark Base Image
For the Spark base image, we will get and setup Apache Spark in standalone mode, its simplest deploy configuration. In this mode, we will be using its resource manager to setup containers to run either as a master or a worker node. In contrast, resources managers such as Apache YARN dynamically allocates containers as master or worker nodes according to the user workload. Furthermore, we will get an Apache Spark version with Apache Hadoop support to allow the cluster to simulate the HDFS using the shared volume created in the base cluster image.
Let’s start by downloading the Apache Spark latest version (currently 3.0.0) with Apache Hadoop support from the official Apache repository. Then, we play a bit with the downloaded package (unpack, move, etc.) and we are ready for the setup stage. Lastly, we configure four Spark variables common to both master and workers nodes:

SPARK_HOME is the installed Apache Spark location used by the framework for setting up tasks;
SPARK_MASTER_HOST is the master node hostname used by worker nodes to connect;
SPARK_MASTER_PORT is the master node port used by worker nodes to connect;
PYSPARK_PYTHON is the installed Python location used by Apache Spark to support its Python API.
```
FROM cluster-base

# -- Layer: Apache Spark

ARG spark_version=3.0.0
ARG hadoop_version=2.7

RUN apt-get update -y && \
    apt-get install -y curl && \
    curl https://archive.apache.org/dist/spark/spark-${spark_version}/spark-${spark_version}-bin-hadoop${hadoop_version}.tgz -o spark.tgz && \
    tar -xf spark.tgz && \
    mv spark-${spark_version}-bin-hadoop${hadoop_version} /usr/bin/ && \
    mkdir /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/logs && \
    rm spark.tgz

ENV SPARK_HOME /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}
ENV SPARK_MASTER_HOST spark-master
ENV SPARK_MASTER_PORT 7077
ENV PYSPARK_PYTHON python3

# -- Runtime

WORKDIR ${SPARK_HOME}
```
#### Spark Master Image
For the Spark master image, we will set up the Apache Spark application to run as a master node. We will configure network ports to allow the network connection with worker nodes and to expose the master web UI, a web page to monitor the master node activities. In the end, we will set up the container startup command for starting the node as a master instance.
We start by exposing the port configured at SPARK_MASTER_PORT environment variable to allow workers to connect to the master node. Then, we expose the SPARK_MASTER_WEBUI_PORT port for letting us access the master web UI page. Finally, we set the container startup command to run Spark built-in deploy script with the master class as its argument.
```
FROM spark-base

# -- Runtime

ARG spark_master_web_ui=8080

EXPOSE ${spark_master_web_ui} ${SPARK_MASTER_PORT}
CMD bin/spark-class org.apache.spark.deploy.master.Master >> logs/spark-master.out
```

#### Spark Worker Image
For the Spark worker image, we will set up the Apache Spark application to run as a worker node. Similar to the master node, we will configure the network port to expose the worker web UI, a web page to monitor the worker node activities, and set up the container startup command for starting the node as a worker instance.
First, we expose the SPARK_WORKER_WEBUI_PORT port to allow access to the worker web UI page, as we did with the master node. Then, we set the container startup command to run Spark built-in deploy script with the worker class and the master network address as its arguments. This will make workers nodes connect to the master node on its startup process.
```
FROM spark-base

# -- Runtime

ARG spark_worker_web_ui=8081

EXPOSE ${spark_worker_web_ui}
CMD bin/spark-class org.apache.spark.deploy.worker.Worker spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT} >> logs/spark-worker.out
```

#### JupyterLab Image
For the JupyterLab image, we go back a bit and start again from the cluster base image. We will install and configure the IDE along with a slightly different Apache Spark distribution from the one installed on Spark nodes.
We start by installing pip, Python’s package manager, and the Python development tools to allow the installation of Python packages during the image building and at the container runtime. Then, let’s get JupyterLab and PySpark from the Python Package Index (PyPI). Finally, we expose the default port to allow access to JupyterLab web interface and we set the container startup command to run the IDE application.
```
FROM cluster-base

# -- Layer: JupyterLab

ARG spark_version=3.0.0
ARG jupyterlab_version=2.1.5

RUN apt-get update -y && \
    apt-get install -y python3-pip && \
    pip3 install pyspark==${spark_version} jupyterlab==${jupyterlab_version}

# -- Runtime

EXPOSE 8888
WORKDIR ${SHARED_WORKSPACE}
CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=
```

#### Building the Images
The Docker images are ready, let’s build them up. Note that since we used Docker arg keyword on Dockerfiles to specify software versions, we can easily change the default Apache Spark and JupyterLab versions for the cluster.
```
# -- Software Stack Version

SPARK_VERSION="3.0.0"
HADOOP_VERSION="2.7"
JUPYTERLAB_VERSION="2.1.5"

# -- Building the Images

docker build \
  -f cluster-base.Dockerfile \
  -t cluster-base .

docker build \
  --build-arg spark_version="${SPARK_VERSION}" \
  --build-arg hadoop_version="${HADOOP_VERSION}" \
  -f spark-base.Dockerfile \
  -t spark-base .

docker build \
  -f spark-master.Dockerfile \
  -t spark-master .

docker build \
  -f spark-worker.Dockerfile \
  -t spark-worker .

docker build \
  --build-arg spark_version="${SPARK_VERSION}" \
  --build-arg jupyterlab_version="${JUPYTERLAB_VERSION}" \
  -f jupyterlab.Dockerfile \
  -t jupyterlab .

```

#### Composing the Cluster
The Docker compose file contains the recipe for our cluster. Here, we will create the JuyterLab and Spark nodes containers, expose their ports for the localhost network and connect them to the simulated HDFS.
We start by creating the Docker volume for the simulated HDFS. Next, we create one container for each cluster component. The jupyterlab container exposes the IDE port and binds its shared workspace directory to the HDFS volume. Likewise, the spark-master container exposes its web UI port and its master-worker connection port and also binds to the HDFS volume.

We finish by creating two Spark worker containers named spark-worker-1 and spark-worker-2. Each container exposes its web UI port (mapped at 8081 and 8082 respectively) and binds to the HDFS volume. These containers have an environment step that specifies their hardware allocation:

SPARK_WORKER_CORE is the number of cores;
SPARK_WORKER_MEMORY is the amount of RAM.
By default, we are selecting one core and 512 MB of RAM for each container. Feel free to play with the hardware allocation but make sure to respect your machine limits to avoid memory issues. Also, provide enough resources for your Docker application to handle the selected values.
```
version: "3.6"
volumes:
  shared-workspace:
    name: "hadoop-distributed-file-system"
    driver: local
services:
  jupyterlab:
    image: jupyterlab
    container_name: jupyterlab
    ports:
      - 8888:8888
    volumes:
      - shared-workspace:/opt/workspace
  spark-master:
    image: spark-master
    container_name: spark-master
    ports:
      - 8080:8080
      - 7077:7077
    volumes:
      - shared-workspace:/opt/workspace
  spark-worker-1:
    image: spark-worker
    container_name: spark-worker-1
    environment:
      - SPARK_WORKER_CORES=1
      - SPARK_WORKER_MEMORY=512m
    ports:
      - 8081:8081
    volumes:
      - shared-workspace:/opt/workspace
    depends_on:
      - spark-master
  spark-worker-2:
    image: spark-worker
    container_name: spark-worker-2
    environment:
      - SPARK_WORKER_CORES=1
      - SPARK_WORKER_MEMORY=512m
    ports:
      - 8082:8081
    volumes:
      - shared-workspace:/opt/workspace
    depends_on:
      - spark-master
```

### Run Spark Cluster
```
docker-compose up
```

## Check Nodes
Once finished, check out the components web UI:

JupyterLab at localhost:8888;
Spark master at localhost:8080;
Spark worker I at localhost:8081;
Spark worker II at localhost:8082;
Spark worker III at localhost:8083;
Spark worker IV at localhost:8084;
Spark worker V at localhost:8085;
Spark worker VI at localhost:8086;
Spark worker VII at localhost:8087;
Spark worker VIII at localhost:8088;

## Create PySpark Application
Open the JupyterLab IDE and create a Python Jupyter notebook. Create a PySpark application by connecting to the Spark master node using a Spark session object with the following parameters:

appName is the name of our application;
master is the Spark master connection URL, the same used by Spark worker nodes to connect to the Spark master node;
config is a general Spark configuration for standalone mode. Here, we are matching the executor memory, that is, a Spark worker JVM process, with the provisioned worker node memory.
Run the cell and you will be able to see the application listed under “Running Applications” at the Spark master web UI. At last, we install the Python wget package from PyPI and download the iris data set from UCI repository into the simulated HDFS. Then we read and print the data with PySpark.
```
Connect the PySpark notebook to Spark master node

In [1]:
from pyspark.sql import SparkSession

spark = SparkSession.\
        builder.\
        appName("pyspark-notebook").\
        master("spark://spark-master:7077").\
        config("spark.executor.memory", "512m").\
        getOrCreate()
Learn and practice Apache Spark using PySpark

In [2]:
import wget

url = "https://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data"
wget.download(url)
In [3]:
data = spark.read.csv("iris.data")
In [4]:
data.show(n=5)
+---+---+---+---+-----------+
|_c0|_c1|_c2|_c3|        _c4|
+---+---+---+---+-----------+
|5.1|3.5|1.4|0.2|Iris-setosa|
|4.9|3.0|1.4|0.2|Iris-setosa|
|4.7|3.2|1.3|0.2|Iris-setosa|
|4.6|3.1|1.5|0.2|Iris-setosa|
|5.0|3.6|1.4|0.2|Iris-setosa|
+---+---+---+---+-----------+
only showing top 5 rows
```
### Tutorial
https://www.kdnuggets.com/2020/07/apache-spark-cluster-docker.html
