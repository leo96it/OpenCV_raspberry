#!/bin/bash
set -e
install_opencv () {
echo ""
case `cat /etc/debian_version` in
10*) echo "Detecting Debian 10, Buster. "
	;;
11*) echo "Detecting Debian 11, Bullseye. "
	;;
12*) echo "Detecting Debian 12, Bookworm. "
	;;
esac
echo ""
echo "Installing OpenCV 4.8.0 on your Raspberry Pi 32-bit OS"
echo "It will take minimal 2.5 hour !"
cd ~
# remove unused applications -> LEO
sudo apt-get purge wolfram-engine
sudo apt-get purge libreoffice*
sudo apt-get clean
sudo apt-get autoremove
# install the dependencies
sudo apt-get install -y build-essential cmake git unzip pkg-config
sudo apt-get install -y libjpeg-dev libtiff-dev libpng-dev
sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev
sudo apt-get install -y libgtk2.0-dev libcanberra-gtk* libgtk-3-dev
sudo apt-get install -y libgstreamer1.0-dev gstreamer1.0-gtk3
sudo apt-get install -y libgstreamer-plugins-base1.0-dev gstreamer1.0-gl
sudo apt-get install -y libxvidcore-dev libx264-dev
#get python
case `cat /etc/debian_version` in
10*) sudo apt-get install -y python-dev python-numpy python-pip
	;;
11*)
	;;
12*)
	;;
esac
sudo apt-get install -y python3-dev python3-numpy python3-pip
sudo apt-get install -y libtbb2 libtbb-dev libdc1394-22-dev
sudo apt-get install -y libv4l-dev v4l-utils
sudo apt-get install -y libopenblas-dev libatlas-base-dev libblas-dev
sudo apt-get install -y liblapack-dev gfortran libhdf5-dev
sudo apt-get install -y libprotobuf-dev libgoogle-glog-dev libgflags-dev
sudo apt-get install -y protobuf-compiler

# download the latest version
cd ~ 
sudo rm -rf opencv*
git clone --depth=1 https://github.com/opencv/opencv.git
git clone --depth=1 https://github.com/opencv/opencv_contrib.git

# check python version -> LEO
python3 --version
# python3 location -> LEO
which python3 3.9
# merge VIRTUALENVWRAPPER_PYTHON=location/version -> LEO
echo “export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3” >> ~/.bashrc
# reload profile -> LEO
source ~/.bashrc
# install the virtual environment -> LEO
sudo pip3 install virtualenv
sudo pip3 install virtualenvwrapper
# append these line at the end of the file .bashrc -> LEO
echo “export WORKON_HOME=$HOME/.virtualenvs” >> ~/.bashrc
echo “source /usr/local/bin/virtualenvwrapper.sh” >> ~/.bashrc
source ~/.bashrc
# create virtual environment -> LEO
mkvirtualenv cv -p python3
# install numpy e picamera -> LEO
pip3 install numpy
sudo pip3 install “picamera[array]”

# set install dir
cd ~/opencv
mkdir build
cd build

# run cmake
cmake -D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_INSTALL_PREFIX=/usr/local \
-D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
-D ENABLE_NEON=ON \
-D WITH_OPENMP=ON \
-D WITH_OPENCL=OFF \
-D BUILD_TIFF=ON \
-D WITH_FFMPEG=ON \
-D WITH_TBB=ON \
-D BUILD_TBB=ON \
-D WITH_GSTREAMER=ON \
-D BUILD_TESTS=OFF \
-D WITH_EIGEN=OFF \
-D WITH_V4L=ON \
-D WITH_LIBV4L=ON \
-D WITH_VTK=OFF \
-D WITH_QT=ON \
-D WITH_PROTOBUF=OFF \
-D OPENCV_ENABLE_NONFREE=ON \
-D INSTALL_C_EXAMPLES=OFF \
-D INSTALL_PYTHON_EXAMPLES=OFF \
-D OPENCV_FORCE_LIBATOMIC_COMPILER_CHECK=1 \
-D PYTHON3_PACKAGES_PATH=/usr/lib/python3/dist-packages \
-D OPENCV_GENERATE_PKGCONFIG=ON \
-D BUILD_EXAMPLES=OFF ..

# run make
make -j4
sudo make install
sudo ldconfig

# cleaning (frees 320 MB)
make clean
sudo apt-get update

# link the OpenCV with the virtual environment -> LEO
cd ~/.virtualenvs/cv/lib/python3.9/site-packages
ln -s /usr/local/lib/python3.9/site-packages/cv2/python-3.9/cv2.cpython-37m-arm-linux-gnueabihf.so cv2.so
cd ~

echo "Congratulations!"
echo "You've successfully installed OpenCV 4.8.0 on your Raspberry Pi 32-bit OS"
}

cd ~
if [ -d ~/opencv/build ]; then
  echo " "
  echo "You have a directory ~/opencv/build on your disk."
  echo "Continuing the installation will replace this folder."
  echo " "
  
  printf "Do you wish to continue (Y/n)?"
  read answer

  if [ "$answer" != "${answer#[Nn]}" ] ;then 
      echo "Leaving without installing OpenCV"
  else
      install_opencv
  fi
else
    install_opencv
fi
