;layer size to selection bounds + 2*outer_feather & offset for better performance

(define (script-fu-ck3-bm-border-overlay image layer border_size_inner feather_inner border_size_outer feather_outer)

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

(define (script-fu-ck3-bm-border image layer border_size_outer feather_outer)

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
    (layer_overlay (car (gimp-layer-new image (car (gimp-image-width image)) (car (gimp-image-height image)) RGBA-IMAGE "Overlay" 50 LAYER-MODE-NORMAL )))
    (layer_border (car (gimp-layer-new image (car (gimp-image-width image)) (car (gimp-image-height image)) RGBA-IMAGE "Border" 100 LAYER-MODE-NORMAL )))
    (layer_group_map (car (gimp-image-get-layer-by-name image "Paper Map")))
    (layer_group_overlay (car (gimp-image-get-layer-by-name image "Map Overlay")))
    (layer_group_borders (car (gimp-image-get-layer-by-name image "Map Borders")))
)

    (gimp-image-insert-layer image layer_overlay layer_group_overlay 1) ;borders are in 0 position
    (gimp-image-insert-layer image layer_border layer_group_borders 0)

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
    (plug-in-gauss-rle RUN-NONINTERACTIVE image layer_overlay 5 TRUE TRUE)

    (gimp-image-select-item image CHANNEL-OP-REPLACE layer_overlay)
    (gimp-image-set-active-layer image layer)

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
)
    (gimp-image-undo-group-start image)
    (gimp-context-push)

    (gimp-image-insert-layer image layer_group_map 0 0)
    (gimp-image-insert-layer image layer_group_overlay layer_group_map 0)
    (gimp-image-insert-layer image layer_group_borders layer_group_overlay 0)

    (gimp-image-lower-item-to-bottom image layer_group_map)
    (gimp-item-set-name layer_group_map "Paper Map")
    (gimp-layer-set-mode layer_group_overlay LAYER-MODE-SOFTLIGHT)
    (gimp-item-set-name layer_group_overlay "Map Overlay")
    (gimp-layer-set-opacity layer_group_borders 80)
    (gimp-item-set-name layer_group_borders "Map Borders")
    
    (gimp-context-pop)
    (gimp-image-undo-group-end image)
)
)

(define (script-fu-ck3-bm-color-sel image layer)

    (let*
        (
            (index 0)
            (boundaries (gimp-selection-bounds image))
            ;; non-empty INT32 TRUE if there is a selection
            (selection (car boundaries))
            (x1 (cadr boundaries))
            (y1 (caddr boundaries))
            (x2 (cadr (cddr boundaries)))
            (y2 (caddr (cddr boundaries)))
        )

        (while (< index (- x2 x1)) ;go along the top until you find a pixel in the selection
            (let*
                (
                    (pixel (gimp-drawable-get-pixel layer (+ x1 index) y1))
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
    ;SF-ADJUSTMENT "Shrink Size" '(0 0 10 1 1 0 SF-SLIDER) ;default, min, max, size, click size
    SF-ADJUSTMENT "Border Size Outer" '(2 1 10 2 2 0 SF-SLIDER)
    SF-ADJUSTMENT "Feather Outer" '(3 0 10 1 1 0 SF-SLIDER)
)