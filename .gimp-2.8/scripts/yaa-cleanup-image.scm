;
; yaa-cleanup-image - remove continuous-tone details from an image
;
; Copyright (C) 2018 Alexander Yermolenko <yaa.mbox@gmail.com>
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;

(define (yaa-cleanup-image image
                           drawable
                           levels-stretch
                           brightness
                           contrast
                           posterization-levels)
  (let* ((bounds (gimp-selection-bounds image))
         (selection-exists (car bounds)))
    (when (equal? selection-exists TRUE)
          (let* ((x1 (cadr bounds))
                 (y1 (caddr bounds))
                 (x2 (cadddr bounds))
                 (y2 (cadddr (cdr bounds))))
            (gimp-image-crop image (- x2 x1) (- y2 y1) x1 y1))))
  (when (equal? levels-stretch TRUE)
        (gimp-levels-stretch drawable))
  (gimp-brightness-contrast drawable brightness contrast)
  (gimp-posterize drawable posterization-levels)
  (gimp-displays-flush))

(define (yaa-cleanup-and-overwrite-image image
                                         drawable
                                         levels-stretch
                                         brightness
                                         contrast
                                         posterization-levels)
  (yaa-cleanup-image image drawable
                     levels-stretch brightness contrast posterization-levels)
  (let* ((filename (car (gimp-image-get-filename image))))
    (when (not (equal? filename ""))
          (gimp-file-save RUN-INTERACTIVE
                          image drawable filename filename)
          (gimp-image-clean-all image))))

(define (yaa-cleanup-images-batch pattern
                                  levels-stretch
                                  brightness
                                  contrast
                                  posterization-levels)
  (let* ((filelist (cadr (file-glob pattern 1))))
    (while (not (null? filelist))
           (let* ((filename (car filelist))
                  (image (car (gimp-file-load RUN-NONINTERACTIVE
                                              filename filename)))
                  (drawable (car (gimp-image-get-active-layer image))))
             (when (equal? levels-stretch TRUE)
                   (gimp-levels-stretch drawable))
             (gimp-brightness-contrast drawable brightness contrast)
             (gimp-posterize drawable posterization-levels)
             (gimp-file-save RUN-NONINTERACTIVE
                             image drawable filename filename)
             (gimp-image-delete image))
           (set! filelist (cdr filelist)))))

(script-fu-register
 "yaa-cleanup-image"
 "Cleanup Image..."
 "Cleanups image by removing continuous-tone details"
 "Alexander Yermolenko"
 "Alexander Yermolenko <yaa.mbox@gmail.com>"
 "2018"
 "RGB*, GRAY*"
 SF-IMAGE    "Image"      0
 SF-DRAWABLE "Drawable"   0
 SF-TOGGLE     "Levels stretch"       TRUE
 SF-ADJUSTMENT "Brightness increase"  '(30 0 127 1 10 0 0)
 SF-ADJUSTMENT "Contrast increase"    '(30 0 127 1 10 0 0)
 SF-ADJUSTMENT "Posterization levels" '(3 2 256 1 10 0 1))

(script-fu-menu-register "yaa-cleanup-image" "<Image>/YAA")

(script-fu-register
 "yaa-cleanup-and-overwrite-image"
 "Cleanup and Overwrite Image..."
 "Cleanups image by removing continuous-tone details and overwrites its origin"
 "Alexander Yermolenko"
 "Alexander Yermolenko <yaa.mbox@gmail.com>"
 "2018"
 "RGB*, GRAY*"
 SF-IMAGE    "Image"      0
 SF-DRAWABLE "Drawable"   0
 SF-TOGGLE     "Levels stretch"       TRUE
 SF-ADJUSTMENT "Brightness increase"  '(30 0 127 1 10 0 0)
 SF-ADJUSTMENT "Contrast increase"    '(30 0 127 1 10 0 0)
 SF-ADJUSTMENT "Posterization levels" '(3 2 256 1 10 0 1))

(script-fu-menu-register "yaa-cleanup-and-overwrite-image" "<Image>/YAA")
