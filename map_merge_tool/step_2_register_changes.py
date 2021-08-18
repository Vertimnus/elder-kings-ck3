import os
import shutil
import pickle
from tqdm import tqdm
from PIL import Image

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
    print("Complete!")
    
    