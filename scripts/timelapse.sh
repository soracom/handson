#!/bin/bash
# 利用方法
usage_exit() {
  cat <<EOF
Usage: $0 [options] /full/path/to/output.mp4
Options:
 -d /path/to/images/ (default=/var/www/html/images/)
 -f filter_string (default=no filter)
 -s N (speed, default=30 frames per seconds)
EOF
  exit 1
}

# オプションのデフォルト値
DIR=/var/www/html/images/
FPS=30
FILTER=.

while getopts d:f:s:h OPT
do
  case $OPT in
    d) DIR=$OPTARG
      ;;
    f) FILTER=$OPTARG
      ;;
    s) FPS=$OPTARG
      ;;
    h) usage_exit
      ;;
    \?) usage_exit
      ;;
  esac
done

shift $((OPTIND - 1))

if [ "$1" = "" ]
then
  usage_exit
fi
OUTPUT=$1

# 作業用ディレクトリの作成
echo "-- 1. mkdir /var/tmp/time-lapse-$$ for workspace"
pushd . &> /dev/null
mkdir /var/tmp/time-lapse-$$
cd /var/tmp/time-lapse-$$

# ファイル名を必要に応じてフィルタして、連番JPEGファイルとするために symbolic link を作成
echo "-- 2. symlinking images as seqeuntial filename (it may take a while...)"
echo $(ls -1 $DIR | egrep $FILTER | wc -l) files found.
ls -1 $DIR | egrep $FILTER | perl -e '$i=0;while(<STDIN>){chomp; $_="ln -sf \"/var/www/html/images/".$_."\" ".sprintf("%08d",$i).".jpg\n" ; print ; $i++}' | bash
echo

# avconv を利用して、連番JPEG(MotionJPEG)をMPEG-4ビデオ形式に変換
echo "-- 3. converting jpeg files to MPEG-4 video (it may also take a while...)"
nice avconv -y -f image2 -r $FPS -i %08d.jpg -an -vcodec libx264 -pix_fmt yuv420p $OUTPUT
echo

# 作業用ディレクトリを削除
echo "-- 4. cleanup..."
popd &> /dev/null
rm -rf /var/tmp/time-lapse-$$
