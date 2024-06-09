FROM alpine:latest AS build
ARG FTE_CONFIG=fortressone
RUN apk update \
 && apk upgrade \
 && apk add --update \
    curl \
    gcc \
    git \
    gnutls-dev \
    libpng-dev \
    make \
    mesa \
    musl-dev \
    subversion \
    zlib
RUN git clone https://github.com/FortressOne/fteqw.git
WORKDIR fteqw/engine
RUN make sv-rel -j$(nproc)
RUN mkdir dats && cd dats \
 && curl \
    --location \
    --remote-name-all \
    https://github.com/FortressOne/server-qwprogs/releases/latest/download/{qwprogs,csprogs,menu}.dat

FROM alpine:latest
RUN apk update && apk upgrade
COPY . /fortressonesv/
COPY --from=build /fteqw/engine/release/fortressone-sv /fortressonesv/fortressone-sv
COPY --from=build /fteqw/engine/dats /fortressonesv/fortress/dats
WORKDIR /fortressonesv
EXPOSE 27500/udp
ENTRYPOINT ["/fortressonesv/fortressone-sv"]
CMD ["-ip", "localhost", \
     "+set", "hostname", "FortressOne", \
     "+exec", "fo_pubmode.cfg", \
     "+map", "2fort5r"]
