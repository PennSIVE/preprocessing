#!/usr/bin/env Rscript
library(argparser)
library(neurobase)
library(ANTsR)
library(extrantsr)
library(fslr)
library(parallel)
library(WhiteStripe)

# create a parser
p <- arg_parser("Run typical preprocessing on a single subject")
# add command line arguments
p <- add_argument(p, "--out", help = "Output filename", default = "/out")
p <- add_argument(p, "--flair", help = "Output flair filename", default = "flair_n4_reg2t1n4_brain_ws.nii.gz")
p <- add_argument(p, "--t1", help = "Output T1 filename", default = "t1_n4_brain_ws.nii.gz")
p <- add_argument(p, "--skull-strip", help = "Skull strip method", default = "fsl_robust")
# parse the command line arguments
argv <- parse_args(p)


tmpdir <- tempdir()
# N4 bias correction
t1_orig = readnii("/T1.nii.gz") # read in original t1
t1_n4 = bias_correct(file = t1_orig, correction = "N4") # n4 bias correction
# writenii(t1_n4, paste0(tmpdir, "/t1_n4")) # write out n4 t1 image

flair_orig = readnii("/flair.nii.gz") # read in original flair
flair_n4 = bias_correct(file = flair_orig, correction = "N4") # n4 bias correction
# writenii(flair_n4, paste0(tmpdir, "/flair_n4")) # write out n4 flair image

# register FLAIR to T1
flair_n4_reg2t1n4 = registration(filename = flair_n4, template.file = t1_n4,
              typeofTransform = "Rigid", interpolator = "Linear")$outfile # register n4 flair to n4 t1
# writenii(flair_n4_reg2t1n4, paste0(tmpdir, "/flair_n4_reg2t1n4")) # write out registered flair image

# skull strip
if (argv$skull_strip == "fsl_robust") {
  t1_n4_brain = fslbet_robust(t1_n4, remover = "double_remove_neck", correct = TRUE, correction = "N4", recog = TRUE)
} else {
  t1_n4_brain = fslbet(infile = paste0(tmpdir, "/t1_n4.nii.gz"))
}
writenii(t1_n4_brain, paste0(argv$out, "/t1_n4_brain.nii.gz"))

# apply brain mask to registered flair
brainmask = t1_n4_brain > 0 # create brain mask
flair_n4_reg2t1n4_brain = flair_n4_reg2t1n4 * brainmask # multiply registered flair image by binary brain mask
writenii(flair_n4_reg2t1n4_brain, paste0(argv$out, "/flairn4_to_t1n4_brain.nii.gz")) # write out skull-stripped flair image

# WhiteStripe (intensity normalization)
t1_ind = whitestripe(t1_n4_brain, "T1")
t1_n4_brain_ws = whitestripe_norm(t1_n4_brain, t1_ind$whitestripe.ind)
writenii(t1_n4_brain_ws, paste0(argv$out, "/", argv$t1)) # write out white striped t1

flair_ind = whitestripe(flair_n4_reg2t1n4_brain, "T2")
flair_n4_reg2t1n4_brain_ws = whitestripe_norm(flair_n4_reg2t1n4_brain, flair_ind$whitestripe.ind)
writenii(flair_n4_reg2t1n4_brain_ws, paste0(argv$out, "/", argv$flair)) # write out white striped flair
