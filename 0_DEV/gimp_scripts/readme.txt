place at "AppData\Roaming\GIMP\2.10\scripts\ck3-bm-scripts.scm" or where ever you set the script directory

intended for use with paper map and map screenshots

BM Border just generates the border and colored overlay for the paper map, which should be placed at the bottom of the "Paper Map" group.
the layer tree should look like:
- "Paper Map"
    - "Overlay"
    - "flatmap.dds"

repeated use will not generate a second "Paper Map" group, but add to the first

BM Border + Highlight does the same as BM Border, but also generates a group containing a highlight for mouse over effects in ck3
repeated use will still add to "Paper Map", but will generate new highlight groups