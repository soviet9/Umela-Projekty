#!/bin/bash

if py -3.11 --version >/dev/null 2>&1; then
    echo "Python 3.11 is installed"
else
    echo "Python 3.11 is not installed"
    exit 1
fi

if [ !  -d ".venv" ]; then
    echo Creating Virtual
    py -3.11 -m venv ".venv"
    echo "Virtual created"
fi

source .venv/Scripts/activate

mkdir -p dataset/train/images
mkdir -p dataset/train/labels
mkdir -p dataset/val/images
mkdir -p dataset/val/labels
mkdir -p obrazky

url1=""
url2=""
url3=""
name1=""
name2=""
name3=""

read -p "Url Prvej Veci: " url1
read -p "Meno: " name1
read -p "Url Druhej Veci: " url2
read -p "Meno: " name2
read -p "Url Tretej Veci: " url3
read -p "Meno: " name3

git clone $url1 repo1
git clone $url2 repo2
git clone $url3 repo3

sed -i "s/^  0: .*/  0: $name1/" data.yaml
sed -i "s/^  1: .*/  1: $name2/" data.yaml
sed -i "s/^  2: .*/  2: $name3/" data.yaml

mkdir -p obrazky/$name1
mkdir -p obrazky/$name2
mkdir -p obrazky/$name3

find repo1 -type f \( \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.png" -o \
    -iname "*.bmp" -o \
    -iname "*.webp" \
\) -exec mv {} obrazky/$name1 \;

find repo2 -type f \( \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.png" -o \
    -iname "*.bmp" -o \
    -iname "*.webp" \
\) -exec mv {} obrazky/$name2 \;

find repo3 -type f \( \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.png" -o \
    -iname "*.bmp" -o \
    -iname "*.webp" \
\) -exec mv {} obrazky/$name3 \;

rm -rf repo1
rm -rf repo2
rm -rf repo3

pip install pyqt5==5.15.10 labelImg lxml ultralytics opencv-python

python konverzia.py

sed -i '526c\            p.drawRect(int(left_top.x()), int(left_top.y()), int(rect_width), int(rect_height))' .venv/Lib/site-packages/libs/canvas.py
sed -i '530c\            p.drawLine(int(self.prev_point.x()), 0, int(self.prev_point.x()), int(self.pixmap.height()))' .venv/Lib/site-packages/libs/canvas.py
sed -i '531c\            p.drawLine(0, int(self.prev_point.y()), int(self.pixmap.width()), int(self.prev_point.y()))' .venv/Lib/site-packages/libs/canvas.py

while true; do
    .venv/Scripts/labelImg.exe

    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        echo "Program finished successfully."
        break
    else
        echo "Program crashed (exit code $EXIT_CODE). Restarting in 5 seconds..."
        sleep 5
    fi
done

gpu=$(powershell.exe -Command "(Get-CimInstance Win32_VideoController).Name" | head -n 1 | tr -d '\r')
cpu=$(powershell.exe -Command "(Get-CimInstance Win32_Processor).Name" | head -n 1 | tr -d '\r')

read -p "Chces pouzit GPU ($gpu) namiesto CPU ($cpu)? [y/n]: " gc

if [[ "$gc" == "y" || "$gc" == "Y" ]]; then
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu117
    python train.py 0
else
    python train.py cpu
fi

python test.py