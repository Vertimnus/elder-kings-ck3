;layer size to selection bounds + 2*outer_feather & offset for better performance

(define (script-fu-ck3-bm-border-overlay image layer merge border_size_inner feather_inner border_size_outer feather_outer)

    ;new layer group
    ;copy selection to new layer in group
    ;new layer w/ inner fade + layer mask
    ;new layer w/ outer fade + layer mask

    (gimp-image-undo-group-start image)
    (gimp-context-push)

    (if (= FALSE (car (gimp-item-is-valid (car (gimp-image-get-layer-by-name image "Paper Map")))))
        (script-fu-ck3-bm-init image)
    )
    (if (= FALSE (car (gimp-drawable-has-alpha layer)))
        (gimp-layer-add-alpha layer)
    )

    (let*
        (
            (layer_group (car (gimp-layer-group-new image)))
            (layer_base (car (gimp-layer-new image (car (gimp-image-width image)) (car (gimp-image-height image)) RGBA-IMAGE "Base" 33 LAYER-MODE-NORMAL )))
            (layer_in (car (gimp-layer-new image (car (gimp-image-width image)) (car (gimp-image-height image)) RGBA-IMAGE "In" 80 LAYER-MODE-NORMAL )))
            (layer_out (car (gimp-layer-new image (car (gimp-image-width image)) (car (gimp-image-height image)) RGBA-IMAGE "Out" 80 LAYER-MODE-NORMAL )))
            (layer_in_mask (car (gimp-layer-create-mask layer_in ADD-MASK-BLACK)))
            (layer_out_mask (car (gimp-layer-create-mask layer_out ADD-MASK-WHITE)))
            (layer_group_map (car (gimp-image-get-layer-by-name image "Paper Map")))
            (layer_group_overlay (car (gimp-image-get-layer-by-name image "Map Overlay")))
            (layer_group_borders (car (gimp-image-get-layer-by-name image "Map Borders")))
        )

        (gimp-image-insert-layer image layer_group 0 0)
        (gimp-image-insert-layer image layer_base layer_group 0)
        (gimp-image-insert-layer image layer_in layer_group 0)
        (gimp-image-insert-layer image layer_out layer_group 0)

        (gimp-edit-copy layer)
        (gimp-floating-sel-anchor (car (gimp-edit-paste layer_base TRUE)))
        (gimp-image-select-item image CHANNEL-OP-REPLACE layer_base)
        (script-fu-ck3-bm-color-sel image layer_base)

        ;(gimp-selection-shrink image shrink_size)
        (gimp-selection-border image border_size_inner)
        (gimp-selection-feather image feather_inner)

        (gimp-edit-bucket-fill layer_in BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)

        (gimp-image-select-item image CHANNEL-OP-REPLACE layer_base)

        ;(gimp-selection-shrink image shrink_size)
        (gimp-selection-border image (/ border_size_outer 2))
        (gimp-selection-feather image feather_outer)

        (gimp-edit-bucket-fill layer_out BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)
        (gimp-edit-bucket-fill layer_out BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)

        (gimp-image-select-item image CHANNEL-OP-REPLACE layer_base)
        (gimp-selection-invert image)

        ;(gimp-selection-shrink image shrink_size)
        (gimp-selection-border image (/ border_size_outer 2))
        (gimp-selection-feather image feather_outer)

        (gimp-edit-bucket-fill layer_out BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)
        (gimp-edit-bucket-fill layer_out BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)

        (gimp-layer-add-mask layer_in layer_in_mask)
        (gimp-layer-add-mask layer_out layer_out_mask)

        (gimp-image-select-item image CHANNEL-OP-REPLACE layer_base)
        (gimp-context-set-background '(255 255 255))
        (gimp-edit-bucket-fill layer_in_mask BUCKET-FILL-BG LAYER-MODE-NORMAL 100 0 FALSE 0 0)
        (gimp-context-set-background '(0 0 0))
        (gimp-edit-bucket-fill layer_out_mask BUCKET-FILL-BG LAYER-MODE-NORMAL 100 0 FALSE 0 0)

        (gimp-selection-all image)
        (gimp-brightness-contrast layer_in -32 0)
        (gimp-brightness-contrast layer_out -32 0)
        (gimp-image-select-item image CHANNEL-OP-REPLACE layer_base)

        (let*
            (
                (layer_overlay (car (gimp-layer-new image (car (gimp-image-width image)) (car (gimp-image-height image)) RGBA-IMAGE "Overlay" 50 LAYER-MODE-NORMAL )))
                (layer_border (car (gimp-layer-new image (car (gimp-image-width image)) (car (gimp-image-height image)) RGBA-IMAGE "Border" 100 LAYER-MODE-NORMAL )))
            )
            (gimp-image-insert-layer image layer_overlay layer_group_overlay 1) ;borders are in 0 position
            (gimp-image-insert-layer image layer_border layer_group_borders 0)

            (gimp-selection-all image)
            (gimp-edit-copy layer_base)
            (gimp-floating-sel-anchor (car (gimp-edit-paste layer_overlay TRUE)))
            (plug-in-gauss-rle RUN-NONINTERACTIVE image layer_overlay 5 TRUE TRUE)
            (gimp-selection-all image)
            (gimp-edit-copy layer_out)
            (gimp-floating-sel-anchor (car (gimp-edit-paste layer_border TRUE)))
            (gimp-drawable-colorize-hsl layer_border 0 0 -100)
        )

        (gimp-image-select-item image CHANNEL-OP-REPLACE layer_base)
        (gimp-image-set-active-layer image layer)

    )
    (gimp-context-pop)
    (gimp-image-undo-group-end image)

    (gimp-displays-flush)
)

(define (script-fu-ck3-bm-border image layer merge border_size_outer feather_outer)

    ;new layer group
    ;copy selection to new layer in group
    ;new layer w/ inner fade + layer mask
    ;new layer w/ outer fade + layer mask

    (gimp-image-undo-group-start image)
    (gimp-context-push)
    (gimp-context-set-sample-threshold 0)

    (if (= FALSE (car (gimp-item-is-valid (car (gimp-image-get-layer-by-name image "Paper Map")))))
        (script-fu-ck3-bm-init image merge)
    )
    (if (= FALSE (car (gimp-drawable-has-alpha layer)))
        (gimp-layer-add-alpha layer)
    )

    (let*
        (
            (boundaries (gimp-selection-bounds image))
            ;; non-empty INT32 TRUE if there is a selection
            (selection (car boundaries))
            (x1 (cadr boundaries))
            (y1 (caddr boundaries))
            (x2 (cadr (cddr boundaries)))
            (y2 (caddr (cddr boundaries)))
            (gauss 5)
            (layer_overlay (car (gimp-layer-new image (+ (- x2 x1) (* 4 gauss)) (+ (- y2 y1) (* 4 gauss)) RGBA-IMAGE "Overlay" 100 LAYER-MODE-NORMAL )))
            (layer_border (car (gimp-layer-new image (+ (- x2 x1) (* 2 (+ border_size_outer feather_outer))) (+ (- y2 y1) (* 2 (+ border_size_outer feather_outer))) RGBA-IMAGE "Border" 100 LAYER-MODE-NORMAL )))
            (layer_group_map (car (gimp-image-get-layer-by-name image "Paper Map")))
            (layer_group_overlay (car (gimp-image-get-layer-by-name image "Map Overlay")))
            (layer_group_borders (car (gimp-image-get-layer-by-name image "Map Borders")))
            (layer_group_colors (car (gimp-image-get-layer-by-name image "Map Colors")))
        )

        (gimp-image-insert-layer image layer_overlay layer_group_colors 0)
        (gimp-image-insert-layer image layer_border layer_group_borders 0)
        (gimp-layer-set-offsets layer_overlay (- x1 (* 2 gauss)) (- y1 (* 2 gauss)))
        (gimp-layer-set-offsets layer_border (- x1 (* 1 (+ border_size_outer feather_outer))) (- y1 (* 1 (+ border_size_outer feather_outer))))
        (gimp-layer-resize-to-image-size layer_group_map)

        (gimp-edit-copy layer)
        (gimp-floating-sel-anchor (car (gimp-edit-paste layer_overlay TRUE)))
        (gimp-image-select-item image CHANNEL-OP-REPLACE layer_overlay)
        (gimp-context-set-foreground '(0 0 0))

        ;(gimp-selection-shrink image shrink_size)
        (gimp-selection-border image (/ border_size_outer 2))
        (gimp-selection-feather image feather_outer)

        (gimp-edit-bucket-fill layer_border BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)
        (gimp-edit-bucket-fill layer_border BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)

        (gimp-image-select-item image CHANNEL-OP-REPLACE layer_overlay)
        (gimp-selection-invert image)

        ;(gimp-selection-shrink image shrink_size)
        (gimp-selection-border image (/ border_size_outer 2))
        (gimp-selection-feather image feather_outer)

        (gimp-edit-bucket-fill layer_border BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)
        (gimp-edit-bucket-fill layer_border BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)

        (gimp-selection-all image)
        
        (if (= FALSE merge)
            (plug-in-gauss-rle RUN-NONINTERACTIVE image layer_overlay gauss TRUE TRUE)
        )

        (gimp-image-select-item image CHANNEL-OP-REPLACE layer_overlay)
        (gimp-image-set-active-layer image layer)

        (if (and (= TRUE merge) (< 1 (car(gimp-item-get-children (car (gimp-image-get-layer-by-name image "Map Borders"))))))
            (begin
                (gimp-image-merge-down image layer_border EXPAND-AS-NECESSARY)
                (gimp-image-merge-down image layer_overlay EXPAND-AS-NECESSARY)
            )
        )

    )
    (gimp-context-pop)
    (gimp-image-undo-group-end image)

    (gimp-displays-flush)
)

(define (script-fu-ck3-bm-init image)
    (let*
        (
            (layer_group_map (car (gimp-layer-group-new image)))
            (layer_group_overlay (car (gimp-layer-group-new image)))
            (layer_group_borders (car (gimp-layer-group-new image)))
            (layer_group_colors (car (gimp-layer-group-new image)))
            ;(layer_overlay (car (gimp-layer-new image (car (gimp-image-width image)) (car (gimp-image-height image)) RGBA-IMAGE "Overlay Merge" 50 LAYER-MODE-NORMAL )))
            ;(layer_border (car (gimp-layer-new image (car (gimp-image-width image)) (car (gimp-image-height image)) RGBA-IMAGE "Border Merge" 100 LAYER-MODE-NORMAL )))
        )
        (gimp-image-undo-group-start image)
        (gimp-context-push)

        (gimp-image-insert-layer image layer_group_map 0 0)
        (gimp-image-insert-layer image layer_group_overlay layer_group_map 0)
        (gimp-image-insert-layer image layer_group_borders layer_group_overlay 0)
        (gimp-image-insert-layer image layer_group_colors layer_group_overlay 1)
        ;(gimp-image-insert-layer image layer_overlay layer_group_overlay 1) ;borders are in 0 position
        ;(gimp-image-insert-layer image layer_border layer_group_borders 0)

        (gimp-image-lower-item-to-bottom image layer_group_map)
        (gimp-item-set-name layer_group_map "Paper Map")
        (gimp-layer-set-mode layer_group_overlay LAYER-MODE-SOFTLIGHT)
        (gimp-item-set-name layer_group_overlay "Map Overlay")
        (gimp-layer-set-opacity layer_group_borders 80)
        (gimp-item-set-name layer_group_borders "Map Borders")
        (gimp-layer-set-opacity layer_group_colors 50)
        (gimp-item-set-name layer_group_colors "Map Colors")

        (if (= TRUE (car (gimp-item-is-valid (car (gimp-image-get-layer-by-name image "flatmap.dds")))))
            (gimp-image-reorder-item image (car (gimp-image-get-layer-by-name image "flatmap.dds")) layer_group_map 1)
        )

        (gimp-context-pop)
        (gimp-image-undo-group-end image)
    )
)

(define (script-fu-ck3-bm-color-sel image layer)

    (let*
        (
            (index 0)
            (color_init (color2number (car (gimp-context-get-foreground))))
            (boundaries (gimp-selection-bounds image))
            ;; non-empty INT32 TRUE if there is a selection
            (selection (car boundaries))
            (x1 (cadr boundaries))
            (y1 (caddr boundaries))
            (x2 (cadr (cddr boundaries)))
            (y2 (caddr (cddr boundaries)))
        )

        (while (and (< index (- x2 x1)) (= color_init (color2number (car (gimp-context-get-foreground))))) ;go along the top until you find a pixel in the selection
        ;(while (< index (- x2 x1)) ;go along the top until you find a pixel in the selection
            (let*
                (
                    (pixel (gimp-drawable-get-pixel layer (- (+ x1 index) (car (gimp-drawable-offsets layer))) (- y1 (cadr (gimp-drawable-offsets layer)))))
                    (rgba (cadr pixel))
                    ;(alpha (aref rgba 3))
                    (alpha (aref rgba (- (car pixel) 1)))
                )
                (if (not (= alpha 0))
                    (gimp-context-set-foreground (car (gimp-image-pick-color image layer (+ x1 index) y1 FALSE FALSE 0)))
                )
            )
            (set! index (+ index 1))
        )
    )

)

(define (color2number color) ;horible solution lol
    (let*
        ((number (car color)))
        (set! number (+ number (* (cadr color) 100)))
        (set! number (+ number (* (caddr color) 10000)))
    )
)

(define (script-fu-ck3-bm-border-batch image layer merge abort)

    ;start select image
    ;selection now contains all areas to be done
    ;use color sel along top, when get a color break & cut paste to new layer
    ;process the new layer
    ;select image again, now missing processed part
    ;repeat until no new areas

    ;add option for borders or borders + overlay
    ;add option to merge layers in borders/overlay

    (gimp-image-undo-disable image)
    ;(gimp-image-undo-group-start image)
    (gimp-context-push)
    (gimp-context-set-sample-threshold 0)

    (if (= FALSE (car (gimp-item-is-valid (car (gimp-image-get-layer-by-name image "Paper Map")))))
        (script-fu-ck3-bm-init image)
    )
    (if (= FALSE (car (gimp-drawable-has-alpha layer)))
        (gimp-layer-add-alpha layer)
    )

    (let*
        (
            (temp_layer (car (gimp-layer-new image (car (gimp-image-width image)) (car (gimp-image-height image)) RGBA-IMAGE "Temp" 100 LAYER-MODE-NORMAL ))) ;store destructable copy of layer
            (work_layer (car (gimp-layer-new image 1 1 RGBA-IMAGE "Temp 2" 100 LAYER-MODE-NORMAL ))) ;input layer for other functions
            (index 0)
        )

        (gimp-image-select-item image CHANNEL-OP-REPLACE layer)
        (gimp-image-insert-layer image temp_layer 0 0)
        (gimp-image-insert-layer image work_layer 0 0)
        
        (gimp-edit-copy layer)
        (gimp-floating-sel-anchor (car (gimp-edit-paste temp_layer TRUE)))
        (gimp-image-select-item image CHANNEL-OP-REPLACE temp_layer)

        
        (let*
            (
                (x0 (car (gimp-drawable-offsets temp_layer)))
                (y0 (cadr (gimp-drawable-offsets temp_layer)))
                (boundaries (gimp-selection-bounds image))
                ;; non-empty INT32 TRUE if there is a selection
                (selection (car boundaries))
                (x1 (cadr boundaries))
                (y1 (caddr boundaries))
                (x2 (cadr (cddr boundaries)))
                (y2 (caddr (cddr boundaries)))
            )
            (gimp-layer-resize temp_layer (- x2 x1) (- y2 y1) (- x0 x1) (- y0 y1))
            ;(gimp-layer-resize work_layer (- x2 x1) (- y2 y1) x1 y1)
        )

        (while (and (= FALSE (car (gimp-selection-is-empty image))) (< index abort))
            ;(gimp-image-select-item image CHANNEL-OP-REPLACE layer)
            (script-fu-ck3-bm-color-sel image temp_layer)
            (gimp-image-select-color image CHANNEL-OP-REPLACE temp_layer (car (gimp-context-get-foreground)))
            (let*
                (
                    (x0 (car (gimp-drawable-offsets work_layer)))
                    (y0 (cadr (gimp-drawable-offsets work_layer)))
                    (boundaries (gimp-selection-bounds image))
                    ;; non-empty INT32 TRUE if there is a selection
                    (selection (car boundaries))
                    (x1 (cadr boundaries))
                    (y1 (caddr boundaries))
                    (x2 (cadr (cddr boundaries)))
                    (y2 (caddr (cddr boundaries)))
                )
                ;(gimp-layer-resize temp_layer (- x2 x1) (- y2 y1) x1 y1)
                (gimp-layer-resize work_layer (- x2 x1) (- y2 y1) (- x0 x1) (- y0 y1))
            )
            (gimp-edit-cut temp_layer)
            (gimp-floating-sel-anchor (car (gimp-edit-paste work_layer TRUE)))
            (gimp-image-select-item image CHANNEL-OP-REPLACE work_layer)
            ;do stuff on it
            (script-fu-ck3-bm-border image work_layer merge 2 3)
            (gimp-selection-all image)
            (gimp-drawable-edit-clear work_layer)
            (gimp-image-select-item image CHANNEL-OP-REPLACE temp_layer)
            (let*
                (
                    (x0 (car (gimp-drawable-offsets temp_layer)))
                    (y0 (cadr (gimp-drawable-offsets temp_layer)))
                    (boundaries (gimp-selection-bounds image))
                    ;; non-empty INT32 TRUE if there is a selection
                    (selection (car boundaries))
                    (x1 (cadr boundaries))
                    (y1 (caddr boundaries))
                    (x2 (cadr (cddr boundaries)))
                    (y2 (caddr (cddr boundaries)))
                )
                (gimp-layer-resize temp_layer (- x2 x1) (- y2 y1) (- x0 x1) (- y0 y1))
                ;(gimp-layer-resize work_layer (- x2 x1) (- y2 y1) x1 y1)
            )
            (set! index (+ index 1))
        )
        
        (gimp-image-remove-layer image temp_layer)
        (gimp-image-remove-layer image work_layer)
        (gimp-drawable-set-visible layer FALSE)
        (if (= TRUE merge)
            (plug-in-gauss-rle RUN-NONINTERACTIVE image (aref (cadr (gimp-item-get-children (car (gimp-image-get-layer-by-name image "Map Colors")))) 0) 5 TRUE TRUE)
        )
    )
        
    (gimp-context-pop)
    ;(gimp-image-undo-group-end image)
    (gimp-image-undo-enable image)

    (gimp-displays-flush)

)

(define (script-fu-ck3-bm-border-edge-detect image layer border_size border_contrast)

    (gimp-image-undo-group-start image)
    (gimp-context-push)
    (gimp-context-set-sample-threshold 0)

    (let*
        (
            (layer_group_map (car (gimp-layer-group-new image)))
            (layer_group_overlay (car (gimp-layer-group-new image)))
            (layer_color (car (gimp-layer-new image (car (gimp-image-width image)) (car (gimp-image-height image)) RGBA-IMAGE "Colors" 50 LAYER-MODE-NORMAL )))
            (layer_border (car (gimp-layer-new image (car (gimp-image-width image)) (car (gimp-image-height image)) RGBA-IMAGE "Borders" border_contrast LAYER-MODE-NORMAL )))
        )
        (gimp-image-insert-layer image layer_group_map 0 0)
        (gimp-image-insert-layer image layer_group_overlay layer_group_map 0)
        (gimp-image-insert-layer image layer_border layer_group_overlay 0)
        (gimp-image-insert-layer image layer_color layer_group_overlay 1)

        (gimp-image-lower-item-to-bottom image layer_group_map)
        (gimp-item-set-name layer_group_map "Paper Map")
        (gimp-layer-set-mode layer_group_overlay LAYER-MODE-SOFTLIGHT)
        (gimp-item-set-name layer_group_overlay "Map Overlay")

        (if (= TRUE (car (gimp-item-is-valid (car (gimp-image-get-layer-by-name image "flatmap.dds")))))
            (gimp-image-reorder-item image (car (gimp-image-get-layer-by-name image "flatmap.dds")) layer_group_map 1)
        )

        (gimp-selection-all image)
        (gimp-edit-copy layer)
        (gimp-floating-sel-anchor (car (gimp-edit-paste layer_color TRUE)))
        (gimp-floating-sel-anchor (car (gimp-edit-paste layer_border TRUE)))

        (plug-in-edge RUN-NONINTERACTIVE image layer_border 2 0 0)
        (gimp-image-select-color image CHANNEL-OP-REPLACE layer_border '(0 0 0))
        (gimp-drawable-edit-clear layer_border)
        (gimp-selection-invert image)
        (gimp-drawable-colorize-hsl layer_border 0 0 -100)
        (gimp-image-select-color image CHANNEL-OP-REPLACE layer_border '(0 0 0))
        (gimp-selection-feather image border_size)

        (gimp-context-set-foreground '(0 0 0))
        (gimp-edit-bucket-fill layer_border BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)
        (gimp-edit-bucket-fill layer_border BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)
        (gimp-edit-bucket-fill layer_border BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)

        (gimp-image-select-item image CHANNEL-OP-REPLACE layer_color)
        (gimp-selection-grow image 1)
        (gimp-selection-border image 1)
        (gimp-selection-feather image border_size)

        (gimp-edit-bucket-fill layer_border BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)
        (gimp-edit-bucket-fill layer_border BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)
        (gimp-edit-bucket-fill layer_border BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)

        (gimp-selection-all image)
        (plug-in-gauss-rle RUN-NONINTERACTIVE image layer_color 5 TRUE TRUE)
    )
        
    (gimp-context-pop)
    (gimp-image-undo-group-end image)

    (gimp-displays-flush)
)

(script-fu-register
    "script-fu-ck3-bm-border-overlay"
    "<Image>/Filters/Crusader Kings III/BM Border + Highlight"
    "Generates a colored overlay and border for paper map & a colored highlight as a separate group.\n\nUse select by color on a map screenshot with 0 threshold.\n\n'flatmap.dds' should be placed in the 'Paper Map' group under the 'Overlay' group."
    "Varlatra"
    "copyright"
    "July 2021"
    "RGB*, GRAY*"
    SF-IMAGE "image" 0
    SF-DRAWABLE "layer" 0
    SF-TOGGLE "Merge layers?" TRUE
    ;SF-ADJUSTMENT "Shrink Size" '(0 0 10 1 1 0 SF-SLIDER) ;default, min, max, size, click size
    SF-ADJUSTMENT "Border Size Inner" '(3 1 10 1 1 0 SF-SLIDER)
    SF-ADJUSTMENT "Feather Inner" '(8 0 10 1 1 0 SF-SLIDER)
    SF-ADJUSTMENT "Border Size Outer" '(2 1 10 2 2 0 SF-SLIDER)
    SF-ADJUSTMENT "Feather Outer" '(3 0 10 1 1 0 SF-SLIDER)
)

(script-fu-register
    "script-fu-ck3-bm-border"
    "<Image>/Filters/Crusader Kings III/BM Border"
    "Generates a colored overlay and border for paper map.\n\nUse select by color on a map screenshot with 0 threshold.\n\n'flatmap.dds' should be placed in the 'Paper Map' group under the 'Overlay' group."
    "Varlatra"
    "copyright"
    "July 2021"
    "RGB*, GRAY*"
    SF-IMAGE "image" 0
    SF-DRAWABLE "layer" 0
    SF-TOGGLE "Merge layers?" FALSE
    ;SF-ADJUSTMENT "Shrink Size" '(0 0 10 1 1 0 SF-SLIDER) ;default, min, max, size, click size
    SF-ADJUSTMENT "Border Size Outer" '(2 1 10 2 2 0 SF-SLIDER)
    SF-ADJUSTMENT "Feather Outer" '(3 0 10 1 1 0 SF-SLIDER)
)

(script-fu-register
    "script-fu-ck3-bm-border-batch"
    "<Image>/Filters/Crusader Kings III/BM Border (Batch)"
    "Batch version of BM Border"
    "Varlatra"
    "copyright"
    "July 2021"
    "RGB*, GRAY*"
    SF-IMAGE "image" 0
    SF-DRAWABLE "layer" 0
    SF-TOGGLE "Merge layers?" TRUE
    SF-ADJUSTMENT "Abort After Tries" '(50 1 500 1 10 0 SF-SLIDER) ;default, min, max, size, click size
    ;SF-ADJUSTMENT "Border Size Outer" '(2 1 10 2 2 0 SF-SLIDER)
    ;SF-ADJUSTMENT "Feather Outer" '(3 0 10 1 1 0 SF-SLIDER)
)

(script-fu-register
    "script-fu-ck3-bm-border-edge-detect"
    "<Image>/Filters/Crusader Kings III/BM Edge Detect Border (Fast)"
    "Use edge detection instead of individually processing"
    "Varlatra"
    "copyright"
    "July 2021"
    "RGB*, GRAY*"
    SF-IMAGE "image" 0
    SF-DRAWABLE "layer" 0
    SF-ADJUSTMENT "Border Size" '(3 1 10 1 1 0 SF-SLIDER) ;default, min, max, size, click size
    SF-ADJUSTMENT "Border Opacity" '(80 0 100 1 10 0 SF-SLIDER) ;default, min, max, size, click size
    ;SF-ADJUSTMENT "Border Size Outer" '(2 1 10 2 2 0 SF-SLIDER)
    ;SF-ADJUSTMENT "Feather Outer" '(3 0 10 1 1 0 SF-SLIDER)
)

