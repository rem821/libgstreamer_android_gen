if [[ -z "${GSTREAMER_ROOT_ANDROID}" ]]; then
  printf "You must define an environment variable called GSTREAMER_ROOT_ANDROID and point it to the folder where you extracted the GStreamer binaries"
  exit 1
fi

VERSION=1.22.12
DATE=`date "+%Y%m%d-%H%M%S"`

rm -rf out
mkdir out

for TARGET in arm64
do
  NDK_APPLICATION_MK="jni/${TARGET}.mk"
  printf "\n\n=== Building GStreamer ${VERSION} for target ${TARGET} with ${NDK_APPLICATION_MK} ==="

  ndk-build NDK_APPLICATION_MK=$NDK_APPLICATION_MK

  if [ $TARGET = "armv7" ]; then
    LIB="armeabi-v7a"
  elif [ $TARGET = "arm64" ]; then
      LIB="arm64-v8a"
  elif [ $TARGET = "x86_64" ]; then
    LIB="x86_64"
  else
    LIB="x86"
  fi;

  GST_LIB="gst-build-${LIB}"
  rm -rf $GST_LIB

  exit

  mkdir -p ${GST_LIB}
  printf "still alive"
  cp -r libs/${LIB}/libgstreamer_android.a ${GST_LIB}
  cp -r $GSTREAMER_ROOT_ANDROID/${LIB}/lib/pkgconfig ${GST_LIB}

  echo 'Processing '$GST_LIB
  cd $GST_LIB
  sed -i -e 's?libdir=.*?libdir='`pwd`'?g' pkgconfig/*
  sed -i -e 's?.* -L${.*?Libs: -L${libdir} -lgstreamer_android?g' pkgconfig/*
  sed -i -e 's?Libs:.*?Libs: -L${libdir} -lgstreamer_android?g' pkgconfig/*
  sed -i -e 's?Libs.private.*?Libs.private: -lgstreamer_android?g' pkgconfig/*
  rm -rf pkgconfig/*pc-e*
  cd ..
  mkdir -p out/Gstreamer-$VERSION/$LIB/lib/
  cp -r $GST_LIB/libgstreamer_android.a  out/Gstreamer-$VERSION/$LIB/lib/
  rm -rf $GST_LIB
done

rm -rf libs obj src

printf "\n*** Done ***\n`ls out`"
