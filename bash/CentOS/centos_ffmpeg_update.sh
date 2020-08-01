#!/bin/sh

# Update dependencies first
sudo yum install autoconf automake bzip2 bzip2-devel cmake freetype-devel gcc gcc-c++ git libtool make mercurial pkgconfig zlib-devel
# Update FFmpeg
rm -rf ~/ffmpeg_build ~/bin/{ffmpeg,ffprobe,lame,x264,x265}
# Update x264
cd ~/ffmpeg_sources/x264
make distclean
git pull
PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
make
make install
# Update x265
cd ~/ffmpeg_sources/x265
rm -rf ~/ffmpeg_sources/x265/build/linux/*
hg update
cd ~/ffmpeg_sources/x265/build/linux
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source
make
make install
# Update libfdk_aac
cd ~/ffmpeg_sources/fdk_aac
make distclean
git pull
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install
# Update libvpx
cd ~/ffmpeg_sources/libvpx
make distclean
git pull
./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm
make
make install
# Update FFmpeg
rm -rf ~/ffmpeg_sources/ffmpeg
cd ~/ffmpeg_sources
curl -O -L https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar xjvf ffmpeg-snapshot.tar.bz2
cd ffmpeg
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --extra-libs=-lpthread \
  --extra-libs=-lm \
  --bindir="$HOME/bin" \
  --enable-gpl \
  --enable-libfdk_aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree
make
make install
hash -d ffmpeg
