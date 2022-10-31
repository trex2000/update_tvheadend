#!/bin/sh 
#configure area
work_dir="/mnt/local/work/tvheadend"
tvheadend_url="https://github.com/tvheadend/"
libdvbcsa_url="https://github.com/glenvt18/"
#script area
DIRECTORY_TVHEADEND="${work_dir}/tvheadend"
DIRECTORY_LIBDVBCSA="${work_dir}/libdvbcsa"
cd $work_dir


echo "Started LibDvbCSA update"
if curl -s -m 5 --head  --request GET $libdvbcsa_url | grep "200" > /dev/null; then 
    if [ ! -d "$DIRECTORY_LIBDVBCSA" ]; then
	echo "New installation of LibDvbCSA. Cloning git"
	sudo apt update
    sudo apt-get purge libdvbcsa-dev -y
	git clone --recursive "${libdvbcsa_url}libdvbcsa.git"
	cd $DIRECTORY_LIBDVBCSA
    else	
	echo "Existing installation of LibDvbCSA. Fetching updates"
	cd $DIRECTORY_LIBDVBCSA
	git fetch  "${libdvbcsa_url}libdvbcsa.git"
    fi
else
    echo Github is down, cannot update LibDvbCSA
    exit
fi
git config apply.whitespace nowarn
git apply $work_dir/libdvbcsa.patch
./bootstrap
./configure
make install

echo "Started tvheadend update"
if curl -s -m 5 --head  --request GET $tvheadend_url | grep "200" > /dev/null; then 
    if [ ! -d "$DIRECTORY_TVHEADEND" ]; then
	echo "New installation of Tvheadend. Cloning git"
	sudo apt update
	sudo apt autoremove -y
	sudo apt install build-essential git ccache libpcre3-dev pkg-config libssl-dev bzip2 wget unzip libavahi-client-dev zlib1g-dev libavcodec-dev libavutil-dev libavformat-dev libswscale-dev libavresample-dev gettext cmake libiconv-hook-dev liburiparser-dev debhelper libcurl4-gnutls-dev python2-minimal libdvbcsa-dev python3-requests libx264-dev libx265-dev libvpx-dev libopus-dev dvb-apps libva-dev libva-drm2 libva-x11-2 libsystemd-dev ffmpeg libavcodec-extra libavcodec-extra58 libavdevice-dev libavfilter-dev libavfilter-extra libpcre2-dev libpcre2-16-0 libpcre2-32-0 librecode0 recode libhdhomerun-dev libx264-142 libx264-dev libvpx-dev  libtheora-dev libopus-dev libva-dev -y
	git clone --recursive "${tvheadend_url}tvheadend.git"
	cd $DIRECTORY_TVHEADEND
	#end of tvheadend new configuration
    else	
	echo "Existing installation of Tvheadend. Fetching updates"
	cd $DIRECTORY_TVHEADEND
	git fetch  
    fi
else
    echo Github is down, cannot update tvheadend
    exit
fi
echo "Patching tvheadend"
git config apply.whitespace nowarn
git apply $work_dir/tvheadend43.patch
./configure --disable-libfdkaac_static --disable-libtheora_static --disable-libopus_static --disable-libvorbis_static --disable-libvpx_static --disable-libx264_static --disable-libx265_static --disable-libfdkaac --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265  --disable-dbus_1 --disable-bintray_cache  --disable-hdhomerun_static --disable-hdhomerun_client --enable-libav --enable-pngquant --enable-trace --enable-vaapi --infodir=/usr/share/info   --cc=cc --arch=x86_x64 --platform=linux --python=python3 
make -j$(nproc)
exit
./bootstrap
./configure
make
make install
systemctl daemon-reload
systemctl restart tvheadend
