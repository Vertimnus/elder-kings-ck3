import os
import shutil
from glob import glob
from tqdm import tqdm
from PIL import Image
from PIL import ImageFile
ImageFile.LOAD_TRUNCATED_IMAGES = True

if __name__ == "__main__":
    print("Creating temporary folders...")
    if os.path.isdir("./temp"):
        shutil.rmtree("./temp")
    os.mkdir("./temp")
    os.mkdir("./temp/step1_backup")
    os.mkdir("./temp/step1_backup/masks")
    os.mkdir("./temp/step2_backup")
    os.mkdir("./temp/step2_backup/masks")
    print("Backing up original heightmap.png...")
    shutil.copy2("../map_data/heightmap.png", "./temp/step1_backup/heightmap.png")
    print("Backing up masks...")
    for map_image in tqdm(glob("../gfx/map/terrain/*.png", recursive=False)):
        map_img = Image.open(map_image, "r")
        width, height = map_img.size
        if width == 8192 and height == 5120:
            print("Copied " + os.path.basename(map_image))
            shutil.copy2(map_image, "./temp/step1_backup/masks/" + os.path.basename(map_image))
    print("Backing up original detail_index.tga...")
    shutil.copy2("../gfx/map/terrain/detail_index.tga", "./temp/step1_backup/detail_index.tga")
    print("Backing up original detail_intensity.tga...")
    shutil.copy2("../gfx/map/terrain/detail_intensity.tga", "./temp/step1_backup/detail_intensity.tga")
    print("Completed!")

    
    