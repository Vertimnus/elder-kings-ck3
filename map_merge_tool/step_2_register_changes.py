import os
import shutil
import pickle
import hashlib
from tqdm import tqdm
from PIL import Image
from glob import glob
from PIL import ImageFile
ImageFile.LOAD_TRUNCATED_IMAGES = True

if __name__ == "__main__":
    changed_pixels = {}
    print("Loading heightmap backup...")
    original_heightmap = Image.open("./temp/step1_backup/heightmap.png", "r")
    print("Iterating over heightmap and registering changes...")
    heightmap = Image.open("../map_data/heightmap.png", "r")
    width, height = heightmap.size
    print(width)
    print(height)
    for x in tqdm(range(width)):
        for y in range(height):
            heightmap_height = heightmap.getpixel((x, y))
            o_height = original_heightmap.getpixel((x, y))
            if heightmap_height != o_height:
                changed_pixels[(x, y)] = heightmap_height
    print("Found " + str(len(changed_pixels)) + " changed pixels.")
    print("Pickling the changes...")
    with open('./temp/step2_backup/heightmap.pickle', 'wb') as heightmap_pickle:
        pickle.dump(changed_pixels, heightmap_pickle, protocol=pickle.HIGHEST_PROTOCOL)
        
    changed_pixels = {}
    print("Loading detail_index backup...")
    original_heightmap = Image.open("./temp/step1_backup/detail_index.tga", "r")
    print("Iterating over detail_index and registering changes...")
    heightmap = Image.open("../gfx/map/terrain/detail_index.tga", "r")
    width, height = heightmap.size
    print(width)
    print(height)
    for x in tqdm(range(width)):
        for y in range(height):
            heightmap_height = heightmap.getpixel((x, y))
            o_height = original_heightmap.getpixel((x, y))
            if heightmap_height != o_height:
                changed_pixels[(x, y)] = heightmap_height
    print("Found " + str(len(changed_pixels)) + " changed pixels.")
    print("Pickling the changes...")
    with open('./temp/step2_backup/detail_index.pickle', 'wb') as detailindex_pickle:
        pickle.dump(changed_pixels, detailindex_pickle, protocol=pickle.HIGHEST_PROTOCOL)
        
    changed_pixels = {}
    print("Loading detail_intensity backup...")
    original_heightmap = Image.open("./temp/step1_backup/detail_intensity.tga", "r")
    print("Iterating over detail_intensity and registering changes...")
    heightmap = Image.open("../gfx/map/terrain/detail_intensity.tga", "r")
    width, height = heightmap.size
    print(width)
    print(height)
    for x in tqdm(range(width)):
        for y in range(height):
            heightmap_height = heightmap.getpixel((x, y))
            o_height = original_heightmap.getpixel((x, y))
            if heightmap_height != o_height:
                changed_pixels[(x, y)] = heightmap_height
    print("Found " + str(len(changed_pixels)) + " changed pixels.")
    print("Pickling the changes...")
    with open('./temp/step2_backup/detail_intensity.pickle', 'wb') as detail_intensity_pickle:
        pickle.dump(changed_pixels, detail_intensity_pickle, protocol=pickle.HIGHEST_PROTOCOL)
        
        
    print("Iterating over masks...")
    for mask in tqdm(glob("./temp/step1_backup/masks/*.png", recursive=False)):
        print("./temp/step1_backup/masks/" + os.path.basename(mask))
        changed_pixels = {}
        mask_file = open(mask, "rb")
        current_mask_file = open("../gfx/map/terrain/" + os.path.basename(mask), "rb")
        mask_md5 = hashlib.md5(mask_file.read()).hexdigest()
        current_mask_md5 = hashlib.md5(current_mask_file.read()).hexdigest()
        print(mask_md5)
        print(current_mask_md5)
        if mask_md5 != current_mask_md5:
            print("Changes detected in " + os.path.basename(mask))
            print("Loading mask...")
            original_mask_img = Image.open(mask, "r")
            print("Iterating over mask and registering changes...")
            mask_img = Image.open("../gfx/map/terrain/" + os.path.basename(mask), "r")
            width, height = mask_img.size
            for x in tqdm(range(width)):
                for y in range(height):
                    mask_height = mask_img.getpixel((x, y))
                    o_mask_height = original_mask_img.getpixel((x, y))
                    if mask_height != o_mask_height:
                        changed_pixels[(x, y)] = mask_height
            print("Found " + str(len(changed_pixels)) + " changed pixels.")
            with open("./temp/step2_backup/masks/" + os.path.splitext(os.path.basename(mask))[0] + ".pickle", "wb") as mask_pickle:
                pickle.dump(changed_pixels, mask_pickle, protocol=pickle.HIGHEST_PROTOCOL)
            
    print("Complete!")
    
    