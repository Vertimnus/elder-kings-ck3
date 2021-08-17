import os
import shutil

if __name__ == "__main__":
    print("Creating temporary folders...")
    if os.path.isdir("./temp"):
        shutil.rmtree("./temp")
    os.mkdir("./temp")
    os.mkdir("./temp/step1_backup")
    os.mkdir("./temp/step2_backup")
    print("Backing up original heightmap.png...")
    shutil.copy2("../map_data/heightmap.png", "./temp/step1_backup/heightmap.png")
    print("Complete!")
    
    