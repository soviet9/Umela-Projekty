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