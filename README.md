#Rebuild
docker build --no-cache -t gst-mprtp:debian13 .

#Run the gst-launch-1.0 command in a Docker container.
docker run --rm -it gst-mprtp:debian13 bash

#To container
gst-inspect-1.0 | grep -i mprtp

#Container run
gst-launch-1.0 -v \
  videotestsrc is-live=true ! \
  x264enc tune=zerolatency bitrate=1000 speed-preset=ultrafast ! \
  rtph264pay pt=96 ! \
  "application/x-rtp,media=video,encoding-name=H264,payload=96" ! \
  mprtpscheduler name=sch ! \
  mprtpsender name=send \
  send.src_0 ! queue ! udpsink host=127.0.0.1 port=5000 sync=false async=false \
  send.src_1 ! queue ! udpsink host=127.0.0.1 port=5002 sync=false async=false
