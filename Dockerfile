# Use a base image
FROM ubuntu:22.04
LABEL maintainer="decloudlab@gmail.com"
LABEL description="Decloud Nodes Lab"
LABEL site="https://declab.pro"
# Set timezone
ENV TZ=Europe/London 
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary packages
RUN apt update && apt upgrade -y &&\
    apt install -y wget make curl libssl-dev libleveldb-dev gcc git tar unzip nano runit ssh lz4 zip jq build-essential nvme-cli pv nginx &&\
	wget -P /usr/lib/ https://github.com/CosmWasm/wasmvm/releases/download/v1.2.3/libwasmvm.x86_64.so &&\
	wget https://go.dev/dl/go1.20.1.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.20.1.linux-amd64.tar.gz &&\
	rm -rf /var/lib/apt/lists/* ./go1.20.1.linux-amd64.tar.gz 
	
RUN PATH=$PATH:/usr/local/go/bin && echo 'export PATH='$PATH:/usr/local/go/bin >> /root/.bashrc

# Copy the main script and set CMD
COPY ./main.sh /
COPY ./service.sh /
RUN sed -i 's/\r//' /service.sh && chmod +x /service.sh
RUN sed -i 's/\r//' /main.sh && chmod +x /main.sh
CMD ["/main.sh"]
