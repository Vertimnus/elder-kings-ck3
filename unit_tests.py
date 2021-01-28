from tqdm import tqdm
from glob import glob
from PIL import Image,ImageChops
import re
import os

def is_greyscale(im):
    """
    Check if image is monochrome (1 channel or 3 identical channels)
    """
    if im.mode not in ("L", "RGB"):
        raise ValueError("Unsuported image mode")

    if im.mode == "RGB":
        rgb = im.split()
        if ImageChops.difference(rgb[0],rgb[1]).getextrema()[1]!=0: 
            return False
        if ImageChops.difference(rgb[0],rgb[2]).getextrema()[1]!=0: 
            return False
    return True

def test_map():
    unit_test_failed = False
    print("Unit Test: Map")
    print("Loading rivers.png...")
    im = Image.open("./map_data/rivers.png", "r")
    print("Completed!")
    print("Getting all colors in rivers.png...")
    colors_in_river_map = im.getcolors(19)
    if colors_in_river_map == None:
        print("ERROR: River map invalid! Over 19 colors in the map, meaning the color indexing is incorrect!")
        unit_test_failed = True
    print("Completed!")
    print("Loading heightmap.png...")
    im = Image.open("./map_data/heightmap.png", "r").convert('RGB')
    print("Completed!")
    print("Checking if heightmap is greyscale...")
    if is_greyscale(im):
        print("Completed!")
    else:
        print("ERROR: Heightmap is not greyscale and is invalid!")
        unit_test_failed = True
    print("Loading provinces.png...")
    im = Image.open("./map_data/provinces.png", "r")
    print("Completed!")
    print("Getting all colors in provinces.png...")
    colors_in_map = im.getcolors(16777216)
    print("Found " + str(len(colors_in_map)) + " unique colors in provinces.png.")
    print("Completed!")

    print("Loading and parsing definition.csv...")
    definitions = open("./map_data/definition.csv", "r")
    definition_regex = r'(\d+);(\d{1,3});(\d{1,3});(\d{1,3});(.+);x;'
    province_count = 0
    bad_provinces = 0
    for line in tqdm(definitions):
        if line[0] == "#":
            continue
        if line == "0;0;0;0;x;x;":
            continue
        province_info = re.search(definition_regex, line)
        if province_info:
            province_rgb = (int(province_info.group(2)), int(province_info.group(3)), int(province_info.group(4)))
            bad_rgb = True
            for color in colors_in_map:
                if color[1] == province_rgb:
                    bad_rgb = False
                    break
            if bad_rgb:
                print("\nERROR: Province defined in definition.csv not present in provinces.png!")
                print(line)
                bad_provinces += 1
                unit_test_failed = True
                continue
            province_count += 1
        else:
            print("ERROR: Malformed province line in definition.csv!")
            print(line)
            bad_provinces += 1
            unit_test_failed = True
    print("Completed!")
    print(str(province_count) + " provinces loaded, " + str(bad_provinces) + " bad provinces found.")
    return unit_test_failed
    
if __name__ == "__main__":
    map_test_results = test_map()
    if map_test_results:
        print("Unit test failed! Resolve issues before shipping!")