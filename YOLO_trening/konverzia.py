import os
from PIL import Image

root_folder = r"obrazky"


target_folder = r"dataset/images/train"

os.makedirs(target_folder, exist_ok=True)

supported = (".jpg", ".jpeg", ".png", ".bmp", ".webp", ".tiff")

for class_name in os.listdir(root_folder):
    class_path = os.path.join(root_folder, class_name)

    if not os.path.isdir(class_path):
        continue

    index = 1

    for filename in os.listdir(class_path):
        if not filename.lower().endswith(supported):
            continue

        source_path = os.path.join(class_path, filename)

        try:
            img = Image.open(source_path).convert("RGB")

            new_name = f"{class_name}{index}.png"
            target_path = os.path.join(target_folder, new_name)

            img.save(target_path, "PNG")

            index += 1

        except Exception as e:
            print(f"Chyba pri {filename}: {e}")

print("Konverzia dokončená.")