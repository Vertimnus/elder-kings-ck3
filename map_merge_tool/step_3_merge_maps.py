import os
import shutil
import pickle
import json
from tqdm import tqdm
from PIL import Image

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
    print("Complete! Make sure to repack your heightmap in the map editor.")  
    