FROM cluster-base

# -- Layer: JupyterLab

ARG spark_version=3.0.1
ARG jupyterlab_version=2.2.8

RUN apt-get update -y && \
    apt-get install -y python3-pip && \
    pip3 install pyspark==${spark_version} jupyterlab==${jupyterlab_version} dockerspawner
    tljh-config add-item users.admin admin
    tljh-config reload
# -- Runtime

EXPOSE 8000
WORKDIR ${SHARED_WORKSPACE}
#ENTRYPOINT ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token="]
CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=

