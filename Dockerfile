FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    openjdk-11-jre-headless unzip perl wget && \
    wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.12.1.zip && \
    unzip fastqc_v0.12.1.zip && \
    chmod +x FastQC/fastqc && \
    mv FastQC /usr/local/ && \
    ln -s /usr/local/FastQC/fastqc /usr/local/bin/fastqc && \
    apt-get clean && rm -rf /var/lib/apt/lists/* fastqc_v0.12.1.zip


ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH
ENV CLASSPATH=/usr/local/FastQC:/usr/local/FastQC/htsjdk.jar:/usr/local/FastQC/jbzip2-0.9.jar:/usr/local/FastQC/cisd-jhdf5.jar

ENTRYPOINT ["fastqc"]
CMD ["--help"]
