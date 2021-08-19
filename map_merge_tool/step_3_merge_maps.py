import os
import shutil
import pickle
import json
import hashlib
from tqdm import tqdm
from PIL import Image
from glob import glob
from PIL import ImageFile
ImageFile.LOAD_TRUNCATED_IMAGES = True

if __name__ == "__main__":
    changed_pixels = {}
    print("Loading config...")
    config_file = json.load(open("./config.json", "r"))
    conflict_resolution_use_upstream_over_local = config_file["conflict_resolution_use_upstream_over_local"]
    print("Loading heightmap backup...")
    original_heightmap = Image.open("./temp/step1_backup/heightmap.png", "r")
    print("Loading changed pixels...")
    changed_pixels = pickle.load(open("./temp/step2_backup/heightmap.pickle", "rb"))
    print("Loading latest heightmap...")
    heightmap = Image.open("../map_data/heightmap.png", "r")

    print("Merging maps...")
    for k, v in tqdm(changed_pixels.items()):
        latest_height = heightmap.getpixel(k)
        backup_height = original_heightmap.getpixel(k)
        if latest_height != backup_height:
            if conflict_resolution_use_upstream_over_local:
                heightmap.putpixel(k, latest_height)
            else:
                heightmap.putpixel(k, v)
            continue
        heightmap.putpixel(k, v)
    print("Saving the merged map...")
    heightmap.save("../map_data/heightmap.png")
    
    print("Loading detail_index backup...")
    original_heightmap = Image.open("./temp/step1_backup/detail_index.tga", "r")
    print("Loading changed pixels...")
    changed_pixels = pickle.load(open("./temp/step2_backup/detail_index.pickle", "rb"))
    print("Loading latest detail_index...")
    heightmap = Image.open("../gfx/map/terrain/detail_index.tga", "r")

    print("Merging maps...")
    for k, v in tqdm(changed_pixels.items()):
        latest_height = heightmap.getpixel(k)
        backup_height = original_heightmap.getpixel(k)
        if latest_height != backup_height:
            if conflict_resolution_use_upstream_over_local:
                heightmap.putpixel(k, latest_height)
            else:
                heightmap.putpixel(k, v)
            continue
        heightmap.putpixel(k, v)
    print("Saving the merged detail_index...")
    heightmap.save("../gfx/map/terrain/detail_index.tga")
    
    print("Loading detail_intensity backup...")
    original_heightmap = Image.open("./temp/step1_backup/detail_intensity.tga", "r")
    print("Loading changed pixels...")
    changed_pixels = pickle.load(open("./temp/step2_backup/detail_intensity.pickle", "rb"))
    print("Loading latest detail_intensity...")
    heightmap = Image.open("../gfx/map/terrain/detail_intensity.tga", "r")

    print("Merging maps...")
    for k, v in tqdm(changed_pixels.items()):
        latest_height = heightmap.getpixel(k)
        backup_height = original_heightmap.getpixel(k)
        if latest_height != backup_height:
            if conflict_resolution_use_upstream_over_local:
                heightmap.putpixel(k, latest_height)
            else:
                heightmap.putpixel(k, v)
            continue
        heightmap.putpixel(k, v)
    print("Saving the merged detail_intensity...")
    heightmap.save("../gfx/map/terrain/detail_intensity.tga")
    
    print("Merging terrain masks...")
    for mask in glob("./temp/step2_backup/masks/*.pickle", recursive=False):
        file_name = os.path.splitext(os.path.basename(mask))[0]
        print("Loading " + file_name + " backup...")
        original_heightmap = Image.open("./temp/step1_backup/masks/" + file_name + ".png", "r")
        print("Loading changed pixels...")
        changed_pixels = pickle.load(open(mask, "rb"))
        print("Loading latest " + file_name + "...")
        heightmap = Image.open("../gfx/map/terrain/" + file_name + ".png", "r")

        print("Merging maps...")
        for k, v in tqdm(changed_pixels.items()):
            latest_height = heightmap.getpixel(k)
            backup_height = original_heightmap.getpixel(k)
            if latest_height != backup_height:
                if conflict_resolution_use_upstream_over_local:
                    heightmap.putpixel(k, latest_height)
                else:
                    heightmap.putpixel(k, v)
                continue
            heightmap.putpixel(k, v)
        print("Saving the merged " + file_name + "...")
        heightmap.save("../gfx/map/terrain/" + file_name + ".png")
    
    print("Complete! Make sure to repack your heightmap in the map editor.")  
    