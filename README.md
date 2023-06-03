# Updated scripts for converting smartphone spherical panoramas into hemispherical images 

This repo contains scripts to process smartphone spherical panoramas into upward facing hemispherical images for estimating forest canopy metrics.

This repo is an update to my earlier analysis [pipeline](https://github.com/andisa01/Arietta2021_Forestry) from [Arietta, A.Z.A. (2021) Estimation of forest canopy structure and understory light using spherical panorama images from smartphone photography. _Forestry._ DOI: 10.1093/forestry/cpab034](https://academic.oup.com/forestry/advance-article-abstract/doi/10.1093/forestry/cpab034/6320703?redirectedFrom=fulltext) to process smartphone spherical panoramas into upward facing hemispherical images for estimating forest canopy metrics.

### Vingette

The easiest way to convert all of your spherical panos to hemispherical projections is to source the function from my github:

```
source("https://raw.githubusercontent.com/andisa01/Spherical-Pano-UPDATE/main/Spheres_to_Hemis.R")
```

When you source the script, it will install and load all necessary packages. It also downloads the [masking file](https://github.com/andisa01/Spherical-Pano-UPDATE/blob/main/HemiPhotoMask.svg) that we will use to black out the periphery of the images.

The script contains the function ```convert_spheres_to_hemis()```, which does exactly what is says. You'll need to put all of your raw spherical panos into a subdirectory within your working directory. We can then pass the path to the directory as an argument to the function.

```
convert_spheres_to_hemis(focal_path = "./raw_panos/")
```

This function will loop through all of your raw panos, convert them to masked, north-oriented upward-facing hemispherical images and put them all in a folder called "masked_hemispheres" in your working directory. It will also output a csv file called "canopy_output.csv" that contains information about the image.

Please see my [blog post](https://www.azandisresearch.com/2023/05/20/update-smartphone-hemispherical-image-analysis/) for a detailed walk-though of how the function works.

![Example a spherical panorama that has been converted into a masked hemispherical projection.](https://github.com/andisa01/Spherical-Pano-UPDATE/blob/main/masked_hemispheres/PXL_20230519_164804198.PHOTOSPHERE_smallhemi_masked.jpg?raw=true" Example a spherical panorama that has been converted into a masked hemispherical projection.")

### Please take a look at my other blog posts that detail:
[Tips for taking better spherical panorama images](https://www.azandisresearch.com/2021/07/16/tips-for-taking-spherical-panoramas/)

[Using spherical panoramas form smartphones](http://www.azandisresearch.com/2020/12/16/smartphone-hemispherical-photography/)

[Analyzing hemispherical photos](http://www.azandisresearch.com/2019/02/03/analyzing-hemispherical-photos/)

[Hemispherical light estimates](http://www.azandisresearch.com/2018/02/16/hemispherical-light-estimates/)

[Taking traditional hemispherical canopy photos](http://www.azandisresearch.com/2018/07/24/taking-hemispherical-canopy-photos/)

[Hardware for traditional hemispherical photos](http://www.azandisresearch.com/2018/03/01/hardware-for-hemispherical-photos/)
