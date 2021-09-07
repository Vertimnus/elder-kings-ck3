SETUP:

If you don't want to do this, or already have python installed and know how to use it, just make sure you have Pillow and tqdm installed.

Step 1. install Python 3.8 from here https://www.python.org/downloads/release/python-383/
Step 2. run the pip_install.bat file.
Step 3. Put the ck3_map_merge_tool folder in the base of your mod's folder.

USAGE:

1. Run step_1_backups.py.
2. Boot up CK3, do map changes in editor and all that stuff, then save it.
3. Run step_2_register_changes.py.
4. Update from master, let it override all your changes to the terrain and heightmap. They've been backed up.
5. Run merge .py file.
6. Go into CK3 and repack the heightmap.
7. Commit changed map files.

NOTES:

Will merge all changes to Terrain and the Heightmap!

Does not currently handle locators. Support may be added for this, I need to research how locators work first.