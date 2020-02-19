FROM alpine:3.9.5

LABEL maintainer="Kalléo Pinheiro <windson.rocha@zup.com.br>"

##### Instalar OpenJDK JRE
RUN apk --update add openjdk8-jre

##### Variaveis de ambiente do Java JRE e Pentaho
ENV JAVA_HOME=/usr/lib/jvm/default-jvm/jre \
    JRE_HOME=${JAVA_HOME} \
    PATH=${PATH}:${JAVA_HOME}/bin:${JRE_HOME}/bin \
    PENTAHO_JAVA_HOME=${JAVA_HOME} \
    PENTAHO_DEST_DIR=/opt/pentaho \
    FILE_NAME=pdi-ce-9.0.0.0-423.zip \
    PENTAHO_USERNAME=pentaho \
    PDI_HOME=/opt/pentaho/data-integration/

##### Adicione um usuário e criar o diretório inicial do pentaho.
RUN adduser -h ${PENTAHO_DEST_DIR} -s /bin/false -D -u 555 ${PENTAHO_USERNAME}

WORKDIR ${PENTAHO_DEST_DIR}

##### Baixar o arquivo ZIP para o container e extrair arquivos
RUN wget https://sourceforge.net/projects/pentaho/files/Pentaho%209.0/client-tools/${FILE_NAME} && unzip ${FILE_NAME} && rm -rf ${FILE_NAME}

# Utilizado em development para testes rápidos
#COPY pdi-ce-9.0.0.0-423.zip .
# RUN unzip ${FILE_NAME} && rm -rf ${FILE_NAME}

##### Limpeza de plugins desnecessários para tornar o processo mais ágil em: https://blog.twineworks.com/improving-startup-time-of-pentaho-data-integration-78d0803c559b
RUN cd ${PDI_HOME} && \
    rm -rfv \
        classes/kettle-lifecycle-listeners.xml \
        classes/kettle-registry-extensions.xml \
        lib/mondrian-*.jar \
        lib/postgresql-* \
        lib/monetdb-jdbc* \
        lib/org.apache.karaf.*.jar \
        lib/pdi-engine-api-*.jar \
        lib/pdi-engine-spark-*.jar \
        lib/pdi-osgi-bridge-core-*.jar \
        lib/pdi-spark-driver-*.jar \
        lib/pentaho-connections-*.jar \
        lib/pentaho-cwm-*.jar \
        lib/pentaho-hadoop-shims-api-*.jar \
        lib/pentaho-osgi-utils-api-*.jar \
        plugins/kettle5-log4j-plugin \
        plugins/pentaho-big-data-plugin \
        system/karaf \
        system/mondrian \
        system/osgi&& \
    # postgres jdbc
    wget -O ${PDI_HOME}/lib/postgresql-42.2.10.jar https://jdbc.postgresql.org/download/postgresql-42.2.10.jar

##### Copiar arquivos do projeto para o container
COPY jobs/* ${PDI_HOME}

COPY transformations/* ${PDI_HOME}

COPY run.sh ${PDI_HOME}

#### Ajustando permissoes dos scripts
RUN chmod 755 ${PDI_HOME}*.sh

WORKDIR ${PDI_HOME}

##### Executar script para executar o Pentaho
CMD ["./run.sh"]